# 故障排除指南

## 构建问题

### 问题1: Flutter 命令未找到

**症状:**
```
bash: flutter: command not found
```

**解决:**
```bash
# 添加 Flutter 到 PATH
export PATH="$PATH:$HOME/flutter/bin"

# 永久添加
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

---

### 问题2: Android SDK 未找到

**症状:**
```
Unable to locate Android SDK
```

**解决:**
```bash
# 设置 ANDROID_HOME
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# 安装 Android SDK 组件
sdkmanager "platforms;android-35"
sdkmanager "build-tools;35.0.0"
```

---

### 问题3: Gradle 构建失败

**症状:**
```
FAILURE: Build failed with an exception
```

**解决:**
```bash
# 清理构建缓存
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

---

### 问题4: 依赖下载超时

**症状:**
```
Connection timed out
Could not resolve all dependencies
```

**解决:**

编辑 `android/build.gradle`:
```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        // 添加国内镜像
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
    }
}
```

---

## 安装问题

### 问题5: 安装被系统拦截

**症状:**
- "禁止安装" 提示
- "风险应用" 警告
- 安装按钮灰色

**解决:**

1. **关闭 MIUI 优化**
   ```
   设置 → 更多设置 → 开发者选项 → 关闭 "启用 MIUI 优化" → 重启
   ```

2. **允许未知来源**
   ```
   设置 → 应用设置 → 授权管理 → 安装未知应用 → 允许
   ```

3. **关闭安装监控**
   ```
   手机管家 → 病毒扫描 → 设置 → 关闭 "安装监控"
   ```

---

### 问题6: 解析包错误

**症状:**
```
解析包时出现问题
```

**解决:**
1. 检查 APK 是否完整下载
2. 检查手机架构是否匹配 (arm64-v8a)
3. 检查 Android 版本是否满足 (>= 8.0)

---

## 运行问题

### 问题7: 应用启动闪退

**症状:**
应用打开后立即关闭

**排查:**
```bash
# 查看日志
adb logcat | grep -i "badminton\|flutter\|AndroidRuntime"
```

**常见原因:**

1. **数据库初始化失败**
   - 解决: 清除应用数据 → 重新打开

2. **权限未授予**
   - 解决: 设置 → 应用管理 → 羽球日记 → 权限 → 允许存储

3. **内存不足**
   - 解决: 关闭其他应用，释放内存

---

### 问题8: 白屏/黑屏

**症状:**
应用打开后显示白屏或黑屏

**解决:**
1. 等待 10-30 秒（首次启动需要初始化）
2. 强制停止应用后重新打开
3. 清除应用缓存

---

### 问题9: 数据不保存

**症状:**
添加的记录或活动重启后消失

**解决:**
1. 检查存储权限是否授予
2. 检查手机是否有足够的存储空间
3. 检查是否使用了清理软件清除了应用数据

---

## 小米澎湃OS 特有问题

### 问题10: 后台被杀死

**症状:**
应用切换到后台后被关闭，数据丢失

**解决:**
```
设置 → 电池与性能 → 电池保护 → 羽球日记 → 无限制
```

---

### 问题11: 通知不显示

**症状:**
设置了提醒但没有收到通知

**解决:**
1. 开启通知权限
   ```
   设置 → 通知管理 → 羽球日记 → 允许通知
   ```

2. 开启锁屏通知
   ```
   设置 → 通知管理 → 羽球日记 → 锁屏通知 → 显示
   ```

3. 关闭省电限制
   ```
   设置 → 电池与性能 → 应用智能省电 → 羽球日记 → 无限制
   ```

---

### 问题12: 界面显示异常

**症状:**
- 文字被刘海遮挡
- 底部被导航栏遮挡
- 界面元素错位

**解决:**
应用已适配全面屏，如仍有问题：
```
设置 → 显示 → 全面屏显示 → 羽球日记 → 自动匹配
```

---

## 性能问题

### 问题13: 应用卡顿

**解决:**
1. 关闭其他后台应用
2. 清理手机存储空间
3. 重启手机
4. 更新到最新版本

---

### 问题14: 数据库操作慢

**症状:**
添加记录或加载列表时卡顿

**解决:**
1. 数据量过大时，考虑归档旧数据
2. 定期清理已完成的活动
3. 避免单组织活动数量超过 1000 条

---

## 调试技巧

### 查看日志

```bash
# 连接手机
adb devices

# 查看所有日志
adb logcat

# 过滤 Flutter 日志
adb logcat | grep flutter

# 过滤应用日志
adb logcat -s "BadmintonDiary"

# 保存日志到文件
adb logcat -d > log.txt
```

### 清除数据

```bash
# 清除应用数据（相当于重装）
adb shell pm clear com.example.badminton_diary
```

### 强制停止

```bash
adb shell am force-stop com.example.badminton_diary
```

---

## 获取帮助

如果以上方法无法解决问题：

1. 收集以下信息：
   - 手机型号和系统版本
   - 应用版本号
   - 问题复现步骤
   - 错误日志 (adb logcat)

2. 提交 Issue:
   - 描述问题
   - 附上日志
   - 说明已尝试的解决方法

---

## 快速诊断清单

遇到问题时，按顺序检查：

- [ ] Flutter 环境正常 (`flutter doctor`)
- [ ] 依赖已下载 (`flutter pub get`)
- [ ] 构建无错误 (`flutter build apk`)
- [ ] APK 文件存在且大小正常 (>10MB)
- [ ] 手机已开启 USB 调试
- [ ] 已允许安装未知来源应用
- [ ] 已关闭 MIUI 优化
- [ ] 存储权限已授予
- [ ] 手机存储空间充足
- [ ] 手机架构为 arm64-v8a
