# 羽球日记 - 构建指南

## 构建方式选择

根据你的环境，选择以下任一方式构建：

| 方式 | 适用场景 | 难度 |
|-----|---------|------|
| [方式1: 本地构建](#方式1-本地构建) | 已安装 Flutter | ⭐⭐ |
| [方式2: Docker 构建](#方式2-docker-构建) | 有 Docker，无 Flutter | ⭐⭐⭐ |
| [方式3: GitHub Actions](#方式3-github-actions-自动构建) | 有 GitHub 账号 | ⭐ |

---

## 方式1: 本地构建

### 环境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android SDK >= 35
- Java 17
- Git

### 安装 Flutter

```bash
# 1. 下载 Flutter
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# 2. 添加到 PATH
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# 3. 验证安装
flutter doctor
```

### 构建步骤

```bash
# 进入项目目录
cd badminton-diary-flutter

# 运行构建脚本
./build.sh
```

或手动构建：

```bash
# 获取依赖
flutter pub get

# 构建调试版本
flutter build apk --debug

# 构建发布版本 (需要签名)
flutter build apk --release
```

### 安装到手机

```bash
# 自动安装
flutter install

# 或手动安装
adb install build/app/outputs/flutter-apk/app-debug.apk
```

---

## 方式2: Docker 构建

### 环境要求

- Docker >= 20.0
- 良好的网络连接（需要下载 Flutter/Android SDK）

### 构建步骤

```bash
# 进入项目目录
cd badminton-diary-flutter

# 运行 Docker 构建脚本
./build-docker.sh
```

### 输出

构建完成后，APK 位于：
```
build/outputs/app-debug.apk
```

### 注意事项

- Docker 构建为调试版本（无签名）
- 首次构建需要下载大量依赖，耗时较长（10-30分钟）
- 需要稳定的网络连接

---

## 方式3: GitHub Actions 自动构建

### 步骤

1. **Fork 或推送代码到 GitHub**

```bash
# 初始化 Git 仓库
git init
git add .
git commit -m "Initial commit"

# 推送到 GitHub
git remote add origin https://github.com/你的用户名/badminton-diary.git
git push -u origin main
```

2. **配置自动构建**

   工作流文件已配置：`.github/workflows/build.yml`

3. **触发构建**

   - 每次推送代码到 main 分支会自动触发
   - 或手动触发：GitHub 仓库 → Actions → Build APK → Run workflow

4. **下载 APK**

   构建完成后，在 Actions 页面下载Artifacts

### 配置签名（可选）

如需自动构建签名版本：

1. **生成签名密钥**

```bash
cd android/app
keytool -genkey -v -keystore release.keystore -alias badminton -keyalg RSA -keysize 2048 -validity 10000
```

2. **转换为 Base64**

```bash
base64 -i release.keystore | pbcopy  # macOS
# 或
base64 -w 0 release.keystore  # Linux
```

3. **添加到 GitHub Secrets**

   仓库 → Settings → Secrets and variables → Actions → New repository secret

   | Secret Name | Value |
   |------------|-------|
   | KEYSTORE_BASE64 | Base64 编码的 keystore |
   | KEYSTORE_PASSWORD | 密钥库密码 |
   | KEY_ALIAS | 别名 (badminton) |
   | KEY_PASSWORD | 密钥密码 |

---

## 小米澎湃OS 安装指南

### 开启开发者选项

1. 设置 → 我的设备 → 全部参数与信息
2. 连续点击 "OS 版本" 7次
3. 返回设置 → 更多设置 → 开发者选项

### 开启 USB 调试

1. 开发者选项 → USB 调试 → 开启
2. USB 安装 → 开启

### 安装 APK

```bash
# 连接手机后
adb devices  # 确认设备已连接
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

### 解决安装被拦截

如果安装时被系统拦截：

1. **关闭 MIUI 优化**
   - 开发者选项 → 关闭 "启用 MIUI 优化"
   - 重启手机

2. **允许安装未知来源**
   - 设置 → 应用设置 → 授权管理 → 安装未知应用 → 允许

3. **关闭安装监控**
   - 手机管家 → 病毒扫描 → 设置 → 关闭 "安装监控"

---

## 常见问题

### Q: 构建失败，提示 "Could not find androidx..."

A: 更新 Android SDK
```bash
sdkmanager --update
sdkmanager "platforms;android-35" "build-tools;35.0.0"
```

### Q: 构建成功但安装失败

A: 检查以下几点：
1. 手机是否开启 USB 调试
2. 是否允许安装未知来源应用
3. 是否关闭 MIUI 优化
4. APK 是否与手机架构匹配 (arm64-v8a)

### Q: 应用启动闪退

A: 查看日志
```bash
adb logcat | grep flutter
```

常见原因：
- 缺少权限
- 数据库初始化失败
- Flutter 引擎问题

### Q: 如何构建 iOS 版本？

A: 需要 macOS + Xcode
```bash
flutter build ios --release
```

---

## 构建输出

| 构建类型 | 输出路径 | 大小 | 用途 |
|---------|---------|------|------|
| Debug | `build/app/outputs/flutter-apk/app-debug.apk` | ~50MB | 开发测试 |
| Release (未签名) | `build/app/outputs/flutter-apk/app-release.apk` | ~25MB | 内部测试 |
| Release (已签名) | `build/app/outputs/flutter-apk/app-release.apk` | ~25MB | 发布 |
| App Bundle | `build/app/outputs/bundle/release/app-release.aab` | ~20MB | Google Play |

---

## 下一步

构建成功后：

1. [在小米澎湃OS 上测试](HYPEROS_ADAPTATION.md)
2. [配置签名发布](SIGNING.md)
3. 分发 APK 给朋友使用

---

**需要帮助？** 查看 [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
