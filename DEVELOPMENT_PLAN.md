# 羽球日记 v2.0 功能开发计划

## 🎯 目标
修复现有问题，扩展核心功能，提升用户体验

## 📅 开发阶段

### Phase 1: 核心功能修复 (1-2天)

#### 1.1 添加活动功能修复
- [ ] 修复保存逻辑，添加调试日志
- [ ] 添加活动冲突检测（同一时间不能有两个活动）
- [ ] 添加重复活动功能（每周/每月固定活动）
- [ ] 添加表单验证增强

#### 1.2 通知提醒系统
- [ ] 集成 flutter_local_notifications
- [ ] 实现本地通知调度
- [ ] 添加提醒时间设置页面
- [ ] 持久化通知设置

#### 1.3 深色模式
- [ ] 实现主题切换逻辑
- [ ] 添加主题状态管理
- [ ] 持久化主题设置
- [ ] 优化深色模式下的颜色

#### 1.4 数据备份
- [ ] 实现 JSON 导出
- [ ] 实现 JSON 导入
- [ ] 添加文件选择器
- [ ] 添加备份确认对话框

### Phase 2: 功能增强 (2-3天)

#### 2.1 活动管理增强
- [ ] 活动编辑功能
- [ ] 活动删除功能
- [ ] 活动搜索/筛选
- [ ] 活动日历视图

#### 2.2 数据统计增强
- [ ] 月度统计报告
- [ ] 年度统计报告
- [ ] 图表可视化
- [ ] 数据导出 CSV

#### 2.3 用户体验优化
- [ ] 添加加载动画
- [ ] 添加空状态提示
- [ ] 添加操作确认对话框
- [ ] 优化错误提示

### Phase 3: 高级功能 (3-5天)

#### 3.1 社交功能
- [ ] 好友系统
- [ ] 活动分享
- [ ] 战绩对比

#### 3.2 智能功能
- [ ] 最佳打球时间推荐
- [ ] 费用预算提醒
- [ ] 装备更换提醒

#### 3.3 扩展功能
- [ ] 视频记录
- [ ] 照片上传
- [ ] 语音备注

## 🛠️ 技术栈

### 新增依赖
```yaml
dependencies:
  # 通知
  flutter_local_notifications: ^16.3.0
  timezone: ^0.9.2
  
  # 文件操作
  file_picker: ^6.1.1
  share_plus: ^7.2.1
  
  # 权限
  permission_handler: ^11.1.0
  
  # 存储
  shared_preferences: ^2.2.2
  
  # 图表
  fl_chart: ^0.66.0
  
  # 日历
  table_calendar: ^3.0.9
```

## 📁 文件结构

```
lib/
├── main.dart
├── models/
│   ├── activity.dart
│   ├── record.dart
│   ├── organization.dart
│   └── settings.dart          # 新增：设置模型
├── screens/
│   ├── home_screen.dart
│   ├── add_activity_screen.dart
│   ├── add_record_screen.dart
│   ├── stats_screen.dart
│   ├── profile_screen.dart
│   ├── settings/              # 新增：设置页面
│   │   ├── notification_settings_screen.dart
│   │   ├── theme_settings_screen.dart
│   │   └── backup_screen.dart
│   └── calendar/              # 新增：日历页面
│       └── calendar_screen.dart
├── services/
│   ├── database_service.dart
│   ├── notification_service.dart    # 新增：通知服务
│   ├── settings_service.dart        # 新增：设置服务
│   └── backup_service.dart          # 新增：备份服务
├── providers/                 # 新增：状态管理
│   ├── theme_provider.dart
│   └── settings_provider.dart
└── utils/
    ├── constants.dart
    └── helpers.dart
```

## 📝 实现优先级

### P0 - 必须修复
1. 添加活动功能
2. 通知提醒
3. 深色模式
4. 数据备份

### P1 - 重要功能
1. 活动编辑/删除
2. 月度报告
3. 图表可视化
4. 用户体验优化

### P2 - 增强功能
1. 社交功能
2. 智能推荐
3. 视频/照片

## 🎨 UI/UX 设计

### 主题色
- 主色：#07C160 (绿色)
- 深色背景：#121212
- 深色卡片：#1E1E1E

### 通知样式
- 图标：🏸
- 声音：默认
- 振动：开启

### 动画
- 页面切换：300ms
- 加载动画：圆形进度条
- 按钮反馈：涟漪效果

## ✅ 验收标准

### 功能验收
- [ ] 添加活动成功保存到数据库
- [ ] 通知在设定时间准时触发
- [ ] 深色模式切换无闪烁
- [ ] 数据备份完整可恢复

### 性能验收
- [ ] 启动时间 < 3秒
- [ ] 页面切换流畅
- [ ] 大数据量不卡顿

### 兼容性验收
- [ ] 小米澎湃OS 正常
- [ ] Android 8.0+ 正常
- [ ] 深色/浅色模式正常
