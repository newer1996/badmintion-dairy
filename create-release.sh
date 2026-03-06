#!/bin/bash

# 创建 GitHub Release 脚本

REPO="newer1996/badmintion-dairy"
VERSION="v1.0.0"
TAG="v1.0.0"

echo "🏸 创建羽球日记 Release"
echo "======================"

# 获取构建产物下载 URL
echo "📥 获取 APK 下载链接..."

# 使用 GitHub API 创建 Release
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$REPO/releases \
  -d '{
    "tag_name": "'$TAG'",
    "name": "羽球日记 '$VERSION'",
    "body": "## 🏸 羽球日记 v1.0.0

### 功能特性
- 📅 活动管理 - 创建和管理羽毛球活动
- 📝 记录功能 - 记录打球费用、运动数据、对战结果
- 📊 数据统计 - 费用分析、战绩统计、热量消耗
- 🏸 多组织支持 - 公司球友群、俱乐部等
- 🎨 Material 3 设计 + 深色模式

### 小米澎湃OS 适配
- ✅ targetSdk 35 (Android 15)
- ✅ 64位架构 (arm64-v8a)
- ✅ 权限最小化
- ✅ 全面屏适配

### 下载
- [app-debug.apk](https://github.com/'$REPO'/actions)

### 安装
1. 下载 APK
2. 开启「允许安装未知来源应用」
3. 安装并享受羽毛球记录体验！

---
Made with ❤️ for badminton lovers",
    "draft": false,
    "prerelease": false
  }'

echo "✅ Release 创建完成！"
