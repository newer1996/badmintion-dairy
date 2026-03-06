import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';
import '../models/settings.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  AppSettings? _settings;

  final List<Map<String, dynamic>> _reminderOptions = [
    {'minutes': 15, 'label': '15分钟'},
    {'minutes': 30, 'label': '30分钟'},
    {'minutes': 60, 'label': '1小时'},
    {'minutes': 120, 'label': '2小时'},
    {'minutes': 1440, 'label': '1天'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = SettingsService.instance.getSettings();
    setState(() {
      _settings = settings;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('通知设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('通知开关'),
          const SizedBox(height: 12),
          _buildCard([
            SwitchListTile(
              title: const Text('启用通知'),
              subtitle: const Text('接收活动开始前的提醒'),
              value: _settings!.notificationsEnabled,
              onChanged: _onNotificationToggle,
              activeColor: const Color(0xFF07C160),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('提醒时间'),
          const SizedBox(height: 12),
          _buildCard(
            _reminderOptions.map((option) {
              return RadioListTile<int>(
                title: Text('活动前 ${option['label']}'),
                value: option['minutes'],
                groupValue: _settings!.reminderMinutes,
                onChanged: _settings!.notificationsEnabled
                    ? (value) => _onReminderTimeChanged(value!)
                    : null,
                activeColor: const Color(0xFF07C160),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('测试'),
          const SizedBox(height: 12),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const Text('发送测试通知'),
              subtitle: const Text('立即发送一条测试通知'),
              onTap: _settings!.notificationsEnabled
                  ? () => _sendTestNotification()
                  : null,
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

  Widget _buildCard(List<Widget> children) {
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

  Future<void> _onNotificationToggle(bool value) async {
    await SettingsService.instance.setNotificationsEnabled(value);
    setState(() {
      _settings = _settings!.copyWith(notificationsEnabled: value);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value ? '通知已开启' : '通知已关闭')),
    );
  }

  Future<void> _onReminderTimeChanged(int minutes) async {
    await SettingsService.instance.setReminderMinutes(minutes);
    setState(() {
      _settings = _settings!.copyWith(reminderMinutes: minutes);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('提醒时间已设置为活动前 $minutes 分钟')),
    );
  }

  Future<void> _sendTestNotification() async {
    await NotificationService.instance.showTestNotification();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('测试通知已发送')),
    );
  }
}
