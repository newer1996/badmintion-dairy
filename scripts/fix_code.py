#!/usr/bin/env python3
"""
自动修复 GitHub Actions 构建失败的脚本
下载错误日志、调用 AI、生成修复代码
"""

import os
import requests
import re
import zipfile
import io

try:
    from github import Github
except ImportError:
    print("正在安装 PyGithub...")
    os.system("pip3 install PyGithub -q")
    from github import Github

# 1. 配置参数（从GitHub Action环境变量读取）
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN") or os.getenv("GITHUB_PAT")
REPO_NAME = os.getenv("GITHUB_REPOSITORY", "newer1996/badmintion-dairy")
RUN_ID = os.getenv("GITHUB_RUN_ID")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
AI_BASE_URL = os.getenv("AI_BASE_URL", "https://api.openai.com/v1")

# 2. 下载GitHub Action的错误日志Artifacts
def download_error_logs():
    """下载构建失败的error_summary.txt和build_logs.txt"""
    if not GITHUB_TOKEN:
        raise Exception("GITHUB_TOKEN 未设置")
    
    g = Github(GITHUB_TOKEN)
    repo = g.get_repo(REPO_NAME)
    
    # 获取最新的工作流运行
    if not RUN_ID:
        workflow_runs = repo.get_workflow_runs()
        if workflow_runs.totalCount == 0:
            raise Exception("没有找到工作流运行记录")
        run = workflow_runs[0]
    else:
        run = repo.get_workflow_run(int(RUN_ID))
    
    print(f"正在获取工作流运行: {run.id}")
    print(f"状态: {run.status}, 结果: {run.conclusion}")
    
    # 获取Artifacts列表
    artifacts = run.get_artifacts()
    log_content = ""
    summary_content = ""
    
    for artifact in artifacts:
        print(f"发现 Artifact: {artifact.name}")
        
        if artifact.name in ["build-logs", "build_logs"]:
            # 下载完整构建日志
            print(f"下载 {artifact.name}...")
            headers = {"Authorization": f"token {GITHUB_TOKEN}"}
            response = requests.get(artifact.archive_download_url, headers=headers)
            
            if response.status_code == 200:
                # 解压 zip
                with zipfile.ZipFile(io.BytesIO(response.content)) as z:
                    for filename in z.namelist():
                        if filename.endswith('.txt') or filename.endswith('.log'):
                            with z.open(filename) as f:
                                log_content = f.read().decode('utf-8', errors='ignore')
                                print(f"已读取日志: {filename} ({len(log_content)} 字符)")
            else:
                print(f"下载失败: {response.status_code}")
    
    # 如果没有找到 artifacts，尝试获取日志直接输出
    if not log_content:
        print("未找到构建日志 artifacts，尝试获取工作流日志...")
        try:
            # 获取工作流运行的日志
            logs_url = f"https://api.github.com/repos/{REPO_NAME}/actions/runs/{run.id}/logs"
            headers = {
                "Authorization": f"token {GITHUB_TOKEN}",
                "Accept": "application/vnd.github.v3+json"
            }
            response = requests.get(logs_url, headers=headers)
            if response.status_code == 200:
                log_content = response.text
                print(f"已获取工作流日志: {len(log_content)} 字符")
        except Exception as e:
            print(f"获取工作流日志失败: {e}")
    
    return summary_content, log_content

# 3. 分析错误日志（本地分析，不调用AI）
def analyze_errors(log_content):
    """分析错误日志，找出常见问题"""
    errors = []
    
    # 常见的 Flutter/Dart 错误模式
    error_patterns = [
        (r"error:\s*(.+?)(?:\n|$)", "Dart Error"),
        (r"FAILURE:\s*(.+?)(?:\n|$)", "Build Failure"),
        (r"Exception:\s*(.+?)(?:\n|$)", "Exception"),
        (r"undefined.*?'(.+?)'", "Undefined Reference"),
        (r"The getter '(.+?)' isn't defined", "Undefined Getter"),
        (r"Target of URI doesn't exist: '(.+?)'", "Missing Import"),
        (r"requires SDK version", "SDK Version Mismatch"),
        (r"Android resource linking failed", "Android Resource Error"),
        (r"Could not find", "Dependency Not Found"),
    ]
    
    for pattern, error_type in error_patterns:
        matches = re.findall(pattern, log_content, re.IGNORECASE)
        for match in matches[:5]:  # 只取前5个匹配
            errors.append({
                "type": error_type,
                "message": match.strip() if isinstance(match, str) else str(match)
            })
    
    return errors

# 4. 调用AI API生成修复代码
def call_ai_for_fix(errors, full_log):
    """调用AI API，解析错误并生成代码修复方案"""
    if not OPENAI_API_KEY:
        print("警告: OPENAI_API_KEY 未设置，使用本地修复规则")
        return generate_local_fix(errors)
    
    error_summary = "\n".join([f"- [{e['type']}] {e['message']}" for e in errors[:10]])
    
    prompt = f"""你是Flutter开发专家，需要修复以下Flutter应用构建失败的问题：

【错误摘要】
{error_summary}

【完整构建日志（关键部分）】
{full_log[-3000:]}

【项目结构】
这是一个Flutter项目，使用以下技术栈：
- Flutter 3.24.0
- Dart 3.0+
- SQLite (sqflite)
- Provider 状态管理

【要求】
1. 明确指出错误原因（1-2句话）；
2. 给出具体的代码修改方案（只输出可直接替换的代码，标注修改的文件路径）；
3. 只输出修改后的完整文件内容，不要多余解释；
4. 确保修改后能通过Flutter构建。

【输出格式】
文件路径: lib/screens/example.dart
```dart
// 完整代码内容
```
"""
    
    try:
        headers = {
            "Authorization": f"Bearer {OPENAI_API_KEY}",
            "Content-Type": "application/json"
        }
        data = {
            "model": "gpt-4",
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0.1
        }
        
        response = requests.post(f"{AI_BASE_URL}/chat/completions", headers=headers, json=data, timeout=60)
        
        if response.status_code == 200:
            result = response.json()
            return result["choices"][0]["message"]["content"]
        else:
            print(f"AI API调用失败: {response.status_code}")
            print(f"响应: {response.text}")
            return generate_local_fix(errors)
    except Exception as e:
        print(f"AI API调用异常: {e}")
        return generate_local_fix(errors)

def generate_local_fix(errors):
    """本地修复规则，处理常见问题"""
    fixes = []
    
    for error in errors:
        error_type = error['type']
        message = error['message']
        
        # 未定义的 getter
        if "Undefined Getter" in error_type:
            icon_name = re.search(r"'(.+?)'", message)
            if icon_name:
                icon = icon_name.group(1)
                fixes.append(f"修复 Icons.{icon} -> 使用有效的 Material Icon")
        
        # 未使用的变量
        elif "unused" in message.lower():
            fixes.append(f"移除未使用的变量: {message}")
        
        # 未使用的导入
        elif "Unused import" in message:
            import_path = re.search(r"'(.+?)'", message)
            if import_path:
                fixes.append(f"移除未使用的导入: {import_path.group(1)}")
    
    return "\n".join(fixes) if fixes else "未找到可自动修复的问题"

# 5. 解析AI输出，替换仓库中的代码
def apply_fix(ai_response):
    """解析AI返回的修复代码，替换对应文件"""
    # 匹配AI输出中的文件路径和代码
    file_pattern = r"文件路径[:：]\s*([\w/\.\-_]+)\n```[\w]*\n(.*?)\n```"
    matches = re.findall(file_pattern, ai_response, re.DOTALL)
    
    if not matches:
        # 尝试另一种格式
        file_pattern2 = r"([\w/\.\-_]+\.dart)\n```(?:dart)?\n(.*?)\n```"
        matches = re.findall(file_pattern2, ai_response, re.DOTALL)
    
    if not matches:
        print("AI未返回可解析的代码修改方案")
        print("AI响应:")
        print(ai_response[:500])
        return 0
    
    for file_path, code in matches:
        # 确保文件目录存在
        full_path = os.path.join(os.getcwd(), file_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        
        # 写入修复后的代码
        with open(full_path, "w", encoding="utf-8") as f:
            f.write(code)
        print(f"✅ 已修改: {file_path}")
    
    return len(matches)

# 6. 自动提交代码到GitHub（触发重新构建）
def commit_and_push():
    """提交修复后的代码，触发GitHub Action重新构建"""
    os.system("git config --global user.name 'AI Fix Bot'")
    os.system("git config --global user.email 'ai-fix-bot@example.com'")
    os.system("git add .")
    
    # 检查是否有代码变更
    status = os.popen("git status --porcelain").read()
    if not status:
        print("没有代码变更，无需提交")
        return False
    
    os.system("git commit -m '🔧 AI fix: 自动修复构建错误'")
    
    # 使用 token 推送
    remote_url = f"https://{GITHUB_TOKEN}@github.com/{REPO_NAME}.git"
    result = os.system(f"git push {remote_url} main")
    
    if result == 0:
        print("✅ 修复代码已提交，将重新触发构建")
        return True
    else:
        print("❌ 推送失败")
        return False

if __name__ == "__main__":
    try:
        print("🔧 自动修复脚本启动")
        print(f"仓库: {REPO_NAME}")
        print(f"Token: {'已设置' if GITHUB_TOKEN else '未设置'}")
        print(f"AI Key: {'已设置' if OPENAI_API_KEY else '未设置'}")
        print()
        
        # 步骤1：下载错误日志
        print("📥 步骤1: 下载错误日志...")
        summary, full_log = download_error_logs()
        
        if not full_log:
            print("⚠️ 未找到详细日志，尝试分析已知问题...")
            # 尝试运行 flutter analyze
            analyze_result = os.popen("flutter analyze 2>&1").read()
            if analyze_result:
                full_log = analyze_result
            else:
                raise Exception("无法获取错误信息")
        
        print(f"📄 日志长度: {len(full_log)} 字符")
        print()
        
        # 步骤2：分析错误
        print("🔍 步骤2: 分析错误...")
        errors = analyze_errors(full_log)
        print(f"发现 {len(errors)} 个错误:")
        for i, e in enumerate(errors[:5], 1):
            print(f"  {i}. [{e['type']}] {e['message'][:80]}")
        print()
        
        # 步骤3：调用AI生成修复方案
        print("🤖 步骤3: 生成修复方案...")
        ai_fix = call_ai_for_fix(errors, full_log)
        print("AI生成的修复方案:")
        print(ai_fix[:500] + "..." if len(ai_fix) > 500 else ai_fix)
        print()
        
        # 步骤4：应用修复
        print("🔨 步骤4: 应用修复...")
        num_fixes = apply_fix(ai_fix)
        
        if num_fixes == 0:
            print("⚠️ 没有应用任何修复")
            # 尝试本地修复
            print("尝试本地修复规则...")
            local_fix = generate_local_fix(errors)
            print(local_fix)
        
        # 步骤5：提交代码
        print()
        print("📤 步骤5: 提交代码...")
        success = commit_and_push()
        
        if success:
            print("✅ 自动修复完成！")
        else:
            print("⚠️ 修复完成但未提交")
    
    except Exception as e:
        print(f"❌ 自动修复失败: {str(e)}")
        import traceback
        traceback.print_exc()
        exit(1)
