# 羽球日记 🏸

一款专为羽毛球爱好者设计的记录工具，支持 Android 和小米澎湃OS。

## 功能特性

### 📅 活动管理
- 创建和管理羽毛球活动
- 支持多组织管理（公司球友群、俱乐部等）
- 自动检测时间冲突
- 活动状态追踪（未报名/已报名/已打完/已取消）

### 📝 记录功能
- 记录打球费用（场地费、球费、饮料等）
- 运动数据统计（时长、消耗热量）
- 对战记录（单打/双打/混双，胜负统计）
- 心情记录

### 📊 数据统计
- 时间维度筛选（本周/本月/本年/全部）
- 费用明细分析
- 常去组织统计
- 战绩统计（胜率计算）

### 🎨 界面设计
- Material 3 设计语言
- 绿色主题（#07C160）
- 支持深色模式
- 流畅动画效果

## 技术栈

- **框架**: Flutter 3.x
- **语言**: Dart
- **数据库**: SQLite (sqflite)
- **状态管理**: Provider
- **图表**: fl_chart

## 项目结构

```
badminton-diary-flutter/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── models/                      # 数据模型
│   │   ├── activity.dart            # 活动模型
│   │   ├── record.dart              # 记录模型
│   │   └── organization.dart        # 组织模型
│   ├── screens/                     # 页面
│   │   ├── home_screen.dart         # 首页
│   │   ├── add_record_screen.dart   # 添加记录
│   │   ├── add_activity_screen.dart # 添加活动
│   │   ├── stats_screen.dart        # 统计页面
│   │   └── profile_screen.dart      # 个人中心
│   └── services/
│       └── database_service.dart    # 数据库服务
├── android/                         # Android 配置
├── assets/                          # 资源文件
│   ├── images/                      # 图片
│   ├── icons/                       # 图标
│   └── fonts/                       # 字体
└── pubspec.yaml                     # 依赖配置
```

## 开发环境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android SDK >= 21
- Android Studio / VS Code

## 快速开始

### 方式1: GitHub Actions 自动构建（推荐）

无需配置环境，自动构建 APK：

1. Fork 本项目到您的 GitHub 账号
2. 进入 Actions → Build APK → Run workflow
3. 等待构建完成，下载 APK

详细步骤见 [BUILD_GUIDE.md](BUILD_GUIDE.md)

### 方式2: 本地构建

```bash
# 1. 安装 Flutter
# https://flutter.dev/docs/get-started/install

# 2. 进入项目
cd badminton-diary-flutter

# 3. 一键构建
./build.sh

# 或手动构建
flutter pub get
flutter build apk --debug
```

### 方式3: Docker 构建

```bash
# 使用 Docker 构建（无需安装 Flutter）
./build-docker.sh
```

### 安装到手机

```bash
# 自动安装
flutter install

# 或手动安装
adb install build/app/outputs/flutter-apk/app-debug.apk
```

## 小米澎湃OS 适配

本项目已针对小米澎湃OS 进行完整优化：

| 适配项 | 状态 | 说明 |
|-------|------|-----|
| targetSdk 35 | ✅ | Android 15 兼容 |
| 64位架构 | ✅ | arm64-v8a 专属构建 |
| 存储权限 | ✅ | Android 13+ MediaStore 适配 |
| 通知权限 | ✅ | Android 13+ 运行时请求 |
| 全面屏 | ✅ | 刘海/挖孔屏适配 |
| 折叠屏 | ✅ | 多窗口/分屏支持 |
| 后台限制 | ✅ | 前台服务 + 电池白名单引导 |
| GMS 无关 | ✅ | 无 Google Play Services 依赖 |

详细适配文档：
- [HYPEROS_ADAPTATION.md](HYPEROS_ADAPTATION.md) - 适配检查清单
- [SIGNING.md](SIGNING.md) - 签名配置指南

### 小米澎湃OS 安装注意事项

1. **开启安装权限**
   - 设置 → 应用设置 → 权限管理 → 特殊应用权限 → 安装未知来源的应用 → 授权

2. **关闭安装监控**（如被拦截）
   - 手机管家 → 病毒扫描 → 设置 → 关闭"安装监控"
   - 或安装时点击"继续安装(风险)"

3. **后台保活设置**
   - 设置 → 电池与性能 → 电池保护 → 羽球日记 → 设为"无限制"

4. **通知权限**
   - 设置 → 通知管理 → 羽球日记 → 允许通知

## 数据库结构

### 组织表 (organizations)
- id: 主键
- name: 组织名称
- defaultLocation: 默认地点
- defaultCost: 默认费用
- createdAt: 创建时间

### 活动表 (activities)
- id: 主键
- orgId: 组织ID
- date: 日期
- startTime: 开始时间
- endTime: 结束时间
- location: 地点
- costEstimate: 预估费用
- status: 状态 (0=未报名, 1=已报名, 2=已打完, 3=已取消)
- note: 备注
- createdAt: 创建时间

### 记录表 (records)
- id: 主键
- activityId: 活动ID
- orgId: 组织ID
- date: 日期
- duration: 时长（小时）
- costs: 费用JSON
- intensity: 强度 (0=低, 1=中, 2=高)
- calories: 消耗热量
- matchType: 比赛类型 (0=单打, 1=双打, 2=混双)
- wins: 胜局数
- losses: 负局数
- mood: 心情 (0=超棒, 1=不错, 2=累了, 3= exhausted)
- note: 备注
- createdAt: 创建时间

## 截图

（待添加）

## 版本历史

### v1.0.0 (2024-03)
- 初始版本发布
- 活动管理功能
- 记录功能
- 数据统计功能
- 多组织支持

## 许可证

MIT License

## 致谢

- Flutter Team
- 所有开源库的贡献者

---

Made with ❤️ for badminton lovers
