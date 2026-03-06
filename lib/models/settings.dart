import 'package:flutter/material.dart';

class AppSettings {
  // 通知设置
  final bool notificationsEnabled;
  final int reminderMinutes; // 提前多少分钟提醒
  final bool vibrationEnabled;
  final String notificationSound;
  
  // 主题设置
  final ThemeMode themeMode;
  final bool followSystemTheme;
  
  // 备份设置
  final DateTime? lastBackupTime;
  final String? backupLocation;
  
  // 其他设置
  final String defaultCurrency;
  final String language;

  AppSettings({
    this.notificationsEnabled = true,
    this.reminderMinutes = 30,
    this.vibrationEnabled = true,
    this.notificationSound = 'default',
    this.themeMode = ThemeMode.system,
    this.followSystemTheme = true,
    this.lastBackupTime,
    this.backupLocation,
    this.defaultCurrency = 'CNY',
    this.language = 'zh_CN',
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    int? reminderMinutes,
    bool? vibrationEnabled,
    String? notificationSound,
    ThemeMode? themeMode,
    bool? followSystemTheme,
    DateTime? lastBackupTime,
    String? backupLocation,
    String? defaultCurrency,
    String? language,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationSound: notificationSound ?? this.notificationSound,
      themeMode: themeMode ?? this.themeMode,
      followSystemTheme: followSystemTheme ?? this.followSystemTheme,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      backupLocation: backupLocation ?? this.backupLocation,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'reminderMinutes': reminderMinutes,
      'vibrationEnabled': vibrationEnabled,
      'notificationSound': notificationSound,
      'themeMode': themeMode.index,
      'followSystemTheme': followSystemTheme,
      'lastBackupTime': lastBackupTime?.toIso8601String(),
      'backupLocation': backupLocation,
      'defaultCurrency': defaultCurrency,
      'language': language,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      reminderMinutes: map['reminderMinutes'] ?? 30,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      notificationSound: map['notificationSound'] ?? 'default',
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
      followSystemTheme: map['followSystemTheme'] ?? true,
      lastBackupTime: map['lastBackupTime'] != null 
          ? DateTime.parse(map['lastBackupTime']) 
          : null,
      backupLocation: map['backupLocation'],
      defaultCurrency: map['defaultCurrency'] ?? 'CNY',
      language: map['language'] ?? 'zh_CN',
    );
  }
}
