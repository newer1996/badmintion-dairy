#!/bin/bash

# 羽球日记 - 本地构建脚本
# 需要先安装 Flutter SDK

set -e

echo "🏸 羽球日记 - 构建脚本"
echo "======================"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查 Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ 错误: Flutter 未安装${NC}"
    echo ""
    echo "请按以下步骤安装 Flutter:"
    echo ""
    echo "1. 下载 Flutter SDK:"
    echo "   git clone https://github.com/flutter/flutter.git -b stable"
    echo ""
    echo "2. 添加到 PATH:"
    echo "   export PATH=\"\$PATH:\$(pwd)/flutter/bin\""
    echo ""
    echo "3. 运行 flutter doctor 检查环境"
    echo ""
    echo "或使用 Docker 构建:"
    echo "   ./build-docker.sh"
    exit 1
fi

echo -e "${GREEN}✅ Flutter 版本:${NC}"
flutter --version | head -3
echo ""

# 检查签名配置
if [ ! -f "android/app/release.keystore" ]; then
    echo -e "${YELLOW}⚠️ 警告: 未找到发布签名密钥${NC}"
    echo ""
    echo "构建调试版本..."
    BUILD_TYPE="debug"
else
    echo -e "${GREEN}✅ 找到发布签名密钥${NC}"
    BUILD_TYPE="release"
fi

echo ""
echo "📦 获取依赖..."
flutter pub get

echo ""
echo "🔨 构建 APK (${BUILD_TYPE})..."
if [ "$BUILD_TYPE" = "release" ]; then
    flutter build apk --release
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
else
    flutter build apk --debug
    APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
fi

echo ""
echo -e "${GREEN}✅ 构建完成!${NC}"
echo ""
echo "APK 位置: ${APK_PATH}"
echo ""

# 检查是否连接设备
if adb devices | grep -q "device$"; then
    echo "📱 检测到连接的设备"
    echo ""
    read -p "是否安装到设备? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "正在安装..."
        adb install -r "${APK_PATH}"
        echo -e "${GREEN}✅ 安装完成!${NC}"
    fi
else
    echo "💡 未检测到连接的设备"
    echo "   连接手机后运行: adb install ${APK_PATH}"
fi

echo ""
echo "🎉 构建流程结束!"
