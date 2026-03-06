#!/bin/bash

# 构建监控脚本
# 持续监控 GitHub Actions 构建状态

REPO="newer1996/badmintion-dairy"
CHECK_INTERVAL=60  # 检查间隔（秒）

echo "🔍 启动构建监控..."
echo "仓库: $REPO"
echo "检查间隔: ${CHECK_INTERVAL}秒"
echo ""

while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') - 检查构建状态..."
    
    # 获取最新构建状态
    RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$REPO/actions/workflows/build.yml/runs?per_page=1")
    
    # 解析状态
    STATUS=$(echo "$RESPONSE" | grep -o '"status": "[^"]*"' | head -1 | cut -d'"' -f4)
    CONCLUSION=$(echo "$RESPONSE" | grep -o '"conclusion": "[^"]*"' | head -1 | cut -d'"' -f4)
    RUN_ID=$(echo "$RESPONSE" | grep -o '"id": [0-9]*' | head -1 | cut -d' ' -f2)
    
    echo "  状态: $STATUS, 结果: $CONCLUSION, 运行ID: $RUN_ID"
    
    if [ "$STATUS" = "completed" ]; then
        if [ "$CONCLUSION" = "success" ]; then
            echo "✅ 构建成功！"
            echo "📥 下载地址: https://github.com/$REPO/actions/runs/$RUN_ID"
            
            # 发送成功通知（如果配置了）
            if [ -n "$NOTIFY_URL" ]; then
                curl -s "$NOTIFY_URL" -d "message=构建成功: $REPO" || true
            fi
            
            break
        elif [ "$CONCLUSION" = "failure" ]; then
            echo "❌ 构建失败！"
            echo "🔧 尝试自动修复..."
            
            # 触发自动修复工作流
            curl -s -X POST \
                -H "Authorization: token $GITHUB_TOKEN" \
                -H "Accept: application/vnd.github.v3+json" \
                "https://api.github.com/repos/$REPO/actions/workflows/auto-fix.yml/dispatches" \
                -d '{"ref":"master"}' || true
            
            echo "🔄 自动修复已触发，等待修复完成..."
        fi
    else
        echo "⏳ 构建进行中..."
    fi
    
    echo ""
    sleep $CHECK_INTERVAL
done

echo "监控结束"
