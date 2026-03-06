# GitHub 操作指南

## 方式1: 使用 Git 命令行（推荐）

### 步骤1: 创建 GitHub 仓库

1. 访问 https://github.com/new
2. 填写仓库信息：
   - Repository name: `badminton-diary`
   - Description: `羽球日记 - 羽毛球爱好者专属记录工具`
   - 选择 Public 或 Private
   - **不要**勾选 "Initialize this repository with a README"
3. 点击 "Create repository"

### 步骤2: 获取仓库地址

创建后，GitHub 会显示类似以下的命令：

```bash
# HTTPS 方式（推荐新手）
https://github.com/你的用户名/badminton-diary.git

# SSH 方式（需要配置密钥）
git@github.com:你的用户名/badminton-diary.git
```

### 步骤3: 推送代码

在项目目录执行：

```bash
cd /home/test/.openclaw/workspace/badminton-diary-flutter

# 初始化 Git 仓库（如果尚未初始化）
git init

# 添加所有文件
git add .

# 提交更改
git commit -m "Initial commit: 羽球日记 Flutter 项目

- 完整的羽毛球活动记录功能
- 支持多组织管理
- 数据统计与分析
- 小米澎湃OS 适配
- GitHub Actions CI/CD"

# 添加远程仓库（替换为你的仓库地址）
git remote add origin https://github.com/你的用户名/badminton-diary.git

# 推送代码
git push -u origin master
```

### 步骤4: 触发自动构建

1. 访问 `https://github.com/你的用户名/badminton-diary`
2. 点击 "Actions" 标签
3. 找到 "Build APK" 工作流
4. 点击 "Run workflow" → "Run workflow"
5. 等待 3-5 分钟构建完成
6. 点击构建记录，下载 Artifacts 中的 APK

---

## 方式2: 使用 GitHub Desktop（图形界面）

### 步骤1: 安装 GitHub Desktop

下载地址：https://desktop.github.com/

### 步骤2: 添加本地仓库

1. 打开 GitHub Desktop
2. File → Add local repository
3. 选择 `/home/test/.openclaw/workspace/badminton-diary-flutter` 目录
4. 点击 "Add repository"

### 步骤3: 发布到 GitHub

1. 在 GitHub Desktop 中，点击 "Publish repository"
2. 填写仓库名称: `badminton-diary`
3. 选择 Public 或 Private
4. 点击 "Publish repository"

### 步骤4: 触发构建

与方式1相同，访问 GitHub 网站触发 Actions。

---

## 方式3: 使用 VS Code（推荐开发者）

### 步骤1: 安装 VS Code

下载地址：https://code.visualstudio.com/

### 步骤2: 安装 GitHub 扩展

1. 打开 VS Code
2. 扩展 → 搜索 "GitHub"
3. 安装 "GitHub Pull Requests and Issues"

### 步骤3: 打开项目

```bash
code /home/test/.openclaw/workspace/badminton-diary-flutter
```

### 步骤4: 使用 VS Code 提交

1. 源代码管理面板（左侧第三个图标）
2. 点击 "+" 暂存所有更改
3. 输入提交消息
4. 点击 "提交"
5. 点击 "发布分支"

---

## 配置 GitHub 个人访问令牌（PAT）

如果使用 HTTPS 方式推送，可能需要配置 PAT：

### 创建 PAT

1. 访问 https://github.com/settings/tokens
2. 点击 "Generate new token (classic)"
3. 填写 Note: `Badminton Diary Access`
4. 选择有效期（建议 90 天）
5. 勾选权限：
   - `repo` (完整仓库访问)
   - `workflow` (Actions 工作流)
6. 点击 "Generate token"
7. **复制并保存令牌**（只显示一次）

### 使用 PAT 推送

```bash
# 推送时会提示输入密码，使用 PAT 代替密码
git push -u origin master

# Username: 你的 GitHub 用户名
# Password: 你的 PAT 令牌
```

---

## 常见问题

### Q: 推送时提示 "Permission denied"

A: 
1. 检查仓库地址是否正确
2. 检查是否有仓库写入权限
3. 使用 PAT 或 SSH 密钥

### Q: 推送时提示 "rejected: non-fast-forward"

A: 
```bash
# 先拉取远程更改
git pull origin master --rebase

# 然后再推送
git push origin master
```

### Q: Actions 没有触发

A:
1. 检查 `.github/workflows/build.yml` 是否存在
2. 检查是否推送到默认分支 (main/master)
3. 检查仓库设置中 Actions 是否启用

### Q: 如何更新代码后重新构建？

A:
```bash
# 修改代码后
git add .
git commit -m "更新说明"
git push

# 推送后会自动触发 Actions 构建
```

---

## 快速命令参考

```bash
# 查看状态
git status

# 查看提交历史
git log --oneline

# 查看远程仓库
git remote -v

# 拉取最新代码
git pull origin master

# 推送代码
git push origin master

# 创建分支
git checkout -b feature/新功能

# 切换分支
git checkout master

# 合并分支
git merge feature/新功能
```

---

## 下一步

推送代码到 GitHub 后：

1. [触发自动构建](BUILD_GUIDE.md#方式3-github-actions-自动构建)
2. [下载 APK 安装到手机](BUILD_GUIDE.md#小米澎湃OS-安装指南)
3. [配置签名发布](SIGNING.md)
