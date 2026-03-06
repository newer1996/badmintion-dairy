import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../models/settings.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  AppSettings? _settings;

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
        title: const Text('主题设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('主题模式'),
          const SizedBox(height: 12),
          _buildCard([
            RadioListTile<ThemeMode>(
              title: const Text('跟随系统'),
              subtitle: const Text('根据系统设置自动切换'),
              value: ThemeMode.system,
              groupValue: _settings!.themeMode,
              onChanged: (value) => _onThemeModeChanged(value!),
              activeColor: const Color(0xFF07C160),
            ),
            const Divider(height: 1, indent: 56),
            RadioListTile<ThemeMode>(
              title: const Text('浅色模式'),
              subtitle: const Text('明亮的界面风格'),
              value: ThemeMode.light,
              groupValue: _settings!.themeMode,
              onChanged: (value) => _onThemeModeChanged(value!),
              activeColor: const Color(0xFF07C160),
            ),
            const Divider(height: 1, indent: 56),
            RadioListTile<ThemeMode>(
              title: const Text('深色模式'),
              subtitle: const Text('护眼的暗色界面'),
              value: ThemeMode.dark,
              groupValue: _settings!.themeMode,
              onChanged: (value) => _onThemeModeChanged(value!),
              activeColor: const Color(0xFF07C160),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('预览'),
          const SizedBox(height: 12),
          _buildPreviewCard(),
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

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF07C160).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF07C160),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sports_tennis, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '羽毛球活动',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        '19:00 - 21:00',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF07C160),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '已报名',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('本周场次', '3'),
              _buildStatItem('总花费', '¥120'),
              _buildStatItem('热量', '1500'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF07C160),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Future<void> _onThemeModeChanged(ThemeMode mode) async {
    await SettingsService.instance.setThemeMode(mode);
    setState(() {
      _settings = _settings!.copyWith(themeMode: mode);
    });

    String message;
    switch (mode) {
      case ThemeMode.system:
        message = '已切换到跟随系统';
        break;
      case ThemeMode.light:
        message = '已切换到浅色模式';
        break;
      case ThemeMode.dark:
        message = '已切换到深色模式';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
