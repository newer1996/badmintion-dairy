#!/bin/bash

# 创建 GitHub Release 脚本

REPO="newer1996/badmintion-dairy"
VERSION="v1.1.0"
TAG="v1.1.0"
BUILD_RUN_ID="22750898936"

echo "🏸 创建羽球日记 Release $VERSION"
echo "======================"

# 获取 GitHub Token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ 错误: GITHUB_TOKEN 未设置"
    exit 1
fi

# 创建 Release
echo "📦 创建 Release..."

curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$REPO/releases \
  -d "{
    \"tag_name\": \"$TAG\",
    \"name\": \"🏸 羽球日记 $VERSION\",
    \"body\": \"## 🎉 羽球日记 $VERSION 发布！\n\n### ✨ 新功能\n- 🤖 **AI自动修复** - 构建失败时自动分析并修复代码\n- 🔔 **通知提醒** - 活动开始前提醒（简化版）\n- 🌙 **深色模式** - 支持浅色/深色/跟随系统三种模式\n- 💾 **数据备份** - 导出JSON和CSV格式的数据\n- ⚙️ **设置中心** - 统一的设置管理页面\n\n### 🔧 修复\n- 修复添加活动功能\n- 修复代码分析错误\n- 优化构建流程\n\n### 📱 系统要求\n- Android 8.0+ (API 26+)\n- 64位处理器 (arm64-v8a)\n- 100MB+ 存储空间\n\n### 📥 下载\n1. 点击下方 Assets 中的 app-debug.apk\n2. 或访问 [Actions 页面](https://github.com/$REPO/actions/runs/$BUILD_RUN_ID) 下载\n\n### 🛠️ 安装\n1. 下载 APK 文件\n2. 开启「允许安装未知来源应用」\n3. 安装并享受羽毛球记录体验！\n\n---\nMade with ❤️ for badminton lovers\",
    \"draft\": false,
    \"prerelease\": false
  }"

echo ""
echo "✅ Release 创建完成！"
echo "📎 访问: https://github.com/$REPO/releases/tag/$TAG"
