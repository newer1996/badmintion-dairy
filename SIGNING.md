## 签名配置说明

### 1. 生成签名密钥

```bash
# 进入 android/app 目录
cd android/app

# 生成签名密钥 (有效期 10000 天)
keytool -genkey -v \
  -keystore release.keystore \
  -alias badminton \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

# 按提示输入信息：
# - 密钥库密码: 建议 8 位以上
# - 姓名: 您的姓名
# - 组织单位: 公司名或个人
# - 组织: 公司名
# - 城市: 所在城市
# - 省份: 所在省份
# - 国家代码: CN
```

### 2. 配置签名

编辑 `android/app/build.gradle`:

```gradle
signingConfigs {
    release {
        storeFile file("release.keystore")
        storePassword "您的密钥库密码"
        keyAlias "badminton"
        keyPassword "您的密钥密码"
        v1SigningEnabled true
        v2SigningEnabled true
        v3SigningEnabled true
    }
}
```

### 3. 安全存储

**不要**将密码直接写在 build.gradle 中！使用以下方式：

#### 方式1: 环境变量
```gradle
signingConfigs {
    release {
        storeFile file("release.keystore")
        storePassword System.getenv("KEYSTORE_PASSWORD")
        keyAlias System.getenv("KEY_ALIAS")
        keyPassword System.getenv("KEY_PASSWORD")
    }
}
```

#### 方式2: local.properties (添加到 .gitignore)
```gradle
// 在 build.gradle 顶部添加
def keystorePropertiesFile = rootProject.file("keystore.properties")
def keystoreProperties = new Properties()
keystoreProperties.load(new FileInputStream(keystorePropertiesFile))

signingConfigs {
    release {
        storeFile file(keystoreProperties['storeFile'])
        storePassword keystoreProperties['storePassword']
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
    }
}
```

创建 `android/keystore.properties`:
```properties
storeFile=release.keystore
storePassword=your_password
keyAlias=badminton
keyPassword=your_password
```

添加到 `.gitignore`:
```
android/keystore.properties
android/app/release.keystore
```

### 4. 验证签名

```bash
# 检查 APK 签名
apksigner verify -v build/app/outputs/flutter-apk/app-release.apk

# 查看签名信息
keytool -list -v -keystore android/app/release.keystore
```

### 5. 重要提醒

⚠️ **务必保管好签名文件和密码！**
- 丢失签名 = 无法更新应用
- 泄露签名 = 他人可伪造您的应用
- 建议多处备份 (加密存储)

### 6. 小米澎湃OS 签名要求

| 要求 | 说明 |
|-----|------|
| V1 签名 | 兼容旧设备 |
| V2 签名 | Android 7.0+ 必需 |
| V3 签名 | Android 9.0+ 推荐 |
| 密钥有效期 | 建议 25 年以上 |
| 密钥算法 | RSA 2048 或更高 |
