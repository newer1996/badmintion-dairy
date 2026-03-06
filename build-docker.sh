#!/bin/bash

# 羽球日记 - Docker 构建脚本
# 无需本地安装 Flutter，使用 Docker 容器构建

set -e

echo "🏸 羽球日记 - Docker 构建"
echo "========================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ 错误: Docker 未安装${NC}"
    echo ""
    echo "请安装 Docker:"
    echo "   https://docs.docker.com/get-docker/"
    exit 1
fi

echo -e "${GREEN}✅ Docker 版本:${NC}"
docker --version
echo ""

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/build-docker"

echo "📁 项目目录: ${PROJECT_DIR}"
echo ""

# 创建 Dockerfile
echo "📝 创建 Dockerfile..."
mkdir -p "${BUILD_DIR}"

cat > "${BUILD_DIR}/Dockerfile" << 'EOF'
FROM cirrusci/flutter:stable

# 安装 Android SDK
RUN apt-get update && apt-get install -y \
    android-sdk \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# 设置环境变量
ENV ANDROID_HOME=/usr/lib/android-sdk
ENV PATH=${PATH}:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# 接受 Android 许可
RUN yes | sdkmanager --licenses || true

# 安装必要的 Android 组件
RUN sdkmanager "platform-tools" "platforms;android-35" "build-tools;35.0.0"

WORKDIR /app

# 复制项目文件
COPY . .

# 获取依赖
RUN flutter pub get

# 构建 APK (调试版本)
RUN flutter build apk --debug

# 输出路径
RUN mkdir -p /output && cp build/app/outputs/flutter-apk/app-debug.apk /output/

CMD ["cat", "/output/app-debug.apk"]
EOF

# 创建 .dockerignore
cat > "${BUILD_DIR}/.dockerignore" << 'EOF'
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.pub-cache/
.pub/
build/
android/.gradle/
android/app/release.keystore
android/keystore.properties
.git/
.gitignore
*.md
!README.md
EOF

# 构建 Docker 镜像
echo ""
echo "🔨 构建 Docker 镜像..."
echo -e "${BLUE}   这可能需要 10-30 分钟，取决于网络速度...${NC}"
echo ""

docker build \
    -t badminton-diary-builder \
    -f "${BUILD_DIR}/Dockerfile" \
    "${PROJECT_DIR}"

if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}❌ Docker 构建失败${NC}"
    echo ""
    echo "可能的原因:"
    echo "   1. 网络问题 (需要访问外网下载 Flutter/Android SDK)"
    echo "   2. Docker 镜像源问题"
    echo ""
    echo "建议:"
    echo "   1. 配置 Docker 代理"
    echo "   2. 使用国内镜像源"
    echo "   3. 直接在本地安装 Flutter 构建"
    exit 1
fi

# 提取 APK
echo ""
echo "📦 提取 APK..."
mkdir -p "${PROJECT_DIR}/build/outputs"
docker create --name badminton-temp badminton-diary-builder
docker cp badminton-temp:/output/app-debug.apk "${PROJECT_DIR}/build/outputs/"
docker rm badminton-temp

echo ""
echo -e "${GREEN}✅ 构建完成!${NC}"
echo ""
echo "APK 位置: build/outputs/app-debug.apk"
echo ""

# 清理
rm -rf "${BUILD_DIR}"

echo "🎉 Docker 构建流程结束!"
echo ""
echo "💡 提示: 由于 Docker 环境限制，此构建为调试版本"
echo "   如需发布版本，请在本地配置签名后构建"
