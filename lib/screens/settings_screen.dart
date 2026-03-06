import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
import '../models/settings.dart';
import 'notification_settings_screen.dart';
import 'theme_settings_screen.dart';
import 'backup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppSettings? _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = SettingsService.instance.getSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _settings == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('通知'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.notifications_outlined,
              title: '通知提醒',
              subtitle: _settings!.notificationsEnabled ? '已开启' : '已关闭',
              trailing: Switch(
                value: _settings!.notificationsEnabled,
                onChanged: _onNotificationToggle,
                activeColor: const Color(0xFF07C160),
              ),
            ),
            const Divider(height: 1, indent: 56),
            _buildSettingItem(
              icon: Icons.access_time,
              title: '提醒时间',
              subtitle: '活动前 ${_settings!.reminderMinutes} 分钟',
              onTap: () => _navigateToNotificationSettings(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('外观'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.dark_mode_outlined,
              title: '深色模式',
              subtitle: _getThemeModeText(_settings!.themeMode),
              trailing: Switch(
                value: _settings!.themeMode == ThemeMode.dark,
                onChanged: _onDarkModeToggle,
                activeColor: const Color(0xFF07C160),
              ),
            ),
            const Divider(height: 1, indent: 56),
            _buildSettingItem(
              icon: Icons.palette_outlined,
              title: '主题设置',
              subtitle: '自定义应用外观',
              onTap: () => _navigateToThemeSettings(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('数据'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.backup_outlined,
              title: '数据备份与恢复',
              subtitle: '导出/导入您的数据',
              onTap: () => _navigateToBackupScreen(),
            ),
            const Divider(height: 1, indent: 56),
            _buildSettingItem(
              icon: Icons.delete_outline,
              title: '清除所有数据',
              subtitle: '删除所有活动和记录',
              onTap: _showClearDataDialog,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('关于'),
          const SizedBox(height: 12),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.info_outline,
              title: '版本',
              value: 'v1.0.0',
            ),
            const Divider(height: 1, indent: 56),
            _buildSettingItem(
              icon: Icons.code,
              title: '开源协议',
              value: 'MIT',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? value,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF07C160).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF07C160)),
      ),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600))
          : null,
      trailing: trailing ??
          (value != null
              ? Text(value, style: TextStyle(color: Colors.grey.shade600))
              : const Icon(Icons.chevron_right)),
      onTap: onTap,
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
    }
  }

  Future<void> _onNotificationToggle(bool value) async {
    await SettingsService.instance.setNotificationsEnabled(value);
    setState(() {
      _settings = _settings!.copyWith(notificationsEnabled: value);
    });

    if (value) {
      // 测试通知
      await NotificationService.instance.showTestNotification();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value ? '通知已开启' : '通知已关闭')),
    );
  }

  Future<void> _onDarkModeToggle(bool value) async {
    final newMode = value ? ThemeMode.dark : ThemeMode.light;
    await SettingsService.instance.setThemeMode(newMode);
    setState(() {
      _settings = _settings!.copyWith(themeMode: newMode);
    });
  }

  void _navigateToNotificationSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationSettingsScreen(),
      ),
    ).then((_) => _loadSettings());
  }

  void _navigateToThemeSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ThemeSettingsScreen(),
      ),
    ).then((_) => _loadSettings());
  }

  void _navigateToBackupScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BackupScreen(),
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除数据'),
        content: const Text('此操作将删除所有活动、记录和组织数据，无法恢复。确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: 实现清除数据功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据已清除')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }
}
