#!/bin/bash

# 本地调试启动脚本

echo "🏸 羽球日记 - 本地调试"
echo "======================"

# 配置 Flutter 环境
export PATH="/home/test/flutter_sdk/bin:$PATH"

# 进入项目目录
cd /home/test/.openclaw/workspace/badminton-diary-flutter

echo ""
echo "📦 步骤1: 获取依赖..."
flutter pub get

echo ""
echo "🔍 步骤2: 分析代码..."
flutter analyze

echo ""
echo "✅ 调试准备完成！"
echo ""
echo "可用命令:"
echo "  flutter run          - 运行应用"
echo "  flutter build apk    - 构建 APK"
echo "  flutter logs         - 查看日志"
echo ""
