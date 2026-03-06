import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

class SettingsService {
  static final SettingsService instance = SettingsService._init();
  static SharedPreferences? _prefs;
  
  static const String _settingsKey = 'app_settings';

  SettingsService._init();

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // 获取设置
  AppSettings getSettings() {
    final jsonString = _prefs?.getString(_settingsKey);
    if (jsonString == null) {
      return AppSettings();
    }
    
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return AppSettings.fromMap(map);
    } catch (e) {
      return AppSettings();
    }
  }

  // 保存设置
  Future<void> saveSettings(AppSettings settings) async {
    final jsonString = jsonEncode(settings.toMap());
    await _prefs?.setString(_settingsKey, jsonString);
  }

  // 通知设置
  Future<void> setNotificationsEnabled(bool enabled) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(notificationsEnabled: enabled));
  }

  Future<void> setReminderMinutes(int minutes) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(reminderMinutes: minutes));
  }

  // 主题设置
  Future<void> setThemeMode(ThemeMode mode) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(themeMode: mode));
  }

  Future<void> setFollowSystemTheme(bool follow) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(followSystemTheme: follow));
  }

  // 备份设置
  Future<void> setLastBackupTime(DateTime time) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(lastBackupTime: time));
  }

  // 清除所有设置
  Future<void> clearSettings() async {
    await _prefs?.remove(_settingsKey);
  }
}
