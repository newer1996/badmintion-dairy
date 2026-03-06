# 小米澎湃OS 适配检查清单

## ✅ 已完成适配

### 1. 安卓标准兼容

| 要求 | 状态 | 配置 |
|-----|------|-----|
| targetSdkVersion ≥ 33 | ✅ | targetSdkVersion 35 |
| 64位架构 (arm64-v8a) | ✅ | ndk { abiFilters "arm64-v8a" } |
| Java 17 | ✅ | sourceCompatibility JavaVersion.VERSION_17 |
| 禁用非SDK接口 | ✅ | 无反射隐藏API |
| V1+V2+V3 签名 | ✅ | signingConfigs 配置 |

### 2. 权限最小化

| 权限 | 用途 | 状态 |
|-----|------|-----|
| INTERNET | 网络访问 | ✅ 必需 |
| READ_MEDIA_IMAGES | 读取图片 | ✅ 必需 |
| POST_NOTIFICATIONS | 通知 | ✅ 必需 |
| FOREGROUND_SERVICE | 前台服务 | ✅ 可选 |
| READ_CONTACTS | 通讯录 | ❌ 不申请 |
| READ_SMS | 短信 | ❌ 不申请 |
| CAMERA | 相机 | ❌ 不申请 |

### 3. 界面适配

| 要求 | 状态 | 配置 |
|-----|------|-----|
| resizeableActivity | ✅ | android:resizeableActivity="true" |
| 全面屏适配 | ✅ | 使用 SafeArea |
| 折叠屏适配 | ✅ | 响应式布局 |

### 4. 后台限制适配

| 要求 | 状态 | 说明 |
|-----|------|-----|
| 不依赖GMS | ✅ | 无 Google Play Services |
| 前台服务通知 | ✅ | 如需后台保活 |
| 电池优化白名单 | ⚠️ | 用户手动设置 |

---

## 📋 发布前检查清单

### 构建配置
- [ ] 修改 applicationId (不要使用 com.example)
- [ ] 配置正式签名 (release.keystore)
- [ ] 更新版本号 (versionCode, versionName)
- [ ] 测试 release 构建

### 签名配置
```bash
# 生成签名密钥
keytool -genkey -v -keystore release.keystore -alias badminton -keyalg RSA -keysize 2048 -validity 10000

# 放置到 android/app/release.keystore
```

### 权限检查
- [ ] 只申请必需权限
- [ ] 运行时权限请求处理
- [ ] 权限被拒绝的降级处理

### 测试验证
- [ ] 小米澎湃OS 设备真机测试
- [ ] 安装测试 (关闭MIUI优化)
- [ ] 功能测试 (增删改查)
- [ ] 后台保活测试
- [ ] 通知测试

---

## 🚨 常见问题解决

### 1. 安装被拦截
```
解决：
1. 使用正式签名 (V1+V2+V3)
2. 关闭手机管家 → 病毒扫描 → 安装监控
3. 安装时选择"继续安装(风险)"
```

### 2. 启动闪退
```
排查：
1. 检查是否有 GMS 依赖
2. 检查是否有反射隐藏API
3. 查看 logcat 错误日志
```

### 3. 通知不显示
```
解决：
1. 设置 → 通知管理 → 羽球日记 → 允许通知
2. 开启悬浮通知/锁屏通知
3. 加入电池白名单
```

### 4. 后台被杀死
```
解决：
设置 → 电池与性能 → 电池保护 → 羽球日记 → 无限制
```

---

## 🔧 构建命令

```bash
# 清理构建
cd badminton-diary-flutter
flutter clean

# 获取依赖
flutter pub get

# 构建 APK (release)
flutter build apk --release

# 构建 App Bundle (Google Play)
flutter build appbundle --release

# 安装到设备
flutter install
```

---

## 📱 测试设备要求

| 项目 | 要求 |
|-----|------|
| 系统 | 小米澎湃OS / Android 14+ |
| 架构 | arm64-v8a |
| 存储 | 100MB+ 可用空间 |
| 权限 | 允许安装未知来源应用 |

---

## 📝 更新日志

### v1.0.0 (2024-03-06)
- ✅ 小米澎湃OS 基础适配
- ✅ 64位架构支持
- ✅ 权限最小化
- ✅ 全面屏适配

---

**注意**: 发布前请务必在小米澎湃OS 真机上测试！
