import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/database_service.dart';

import '../models/organization.dart';

// 简化版备份服务，先确保构建成功
class BackupService {
  static final BackupService instance = BackupService._init();
  
  BackupService._init();

  Future<String> exportData() async {
    try {
      final activities = await DatabaseService.instance.getActivities();
      final records = await DatabaseService.instance.getRecords();
      final organizations = await DatabaseService.instance.getOrganizations();

      final backupData = {
        'version': '1.0.0',
        'exportTime': DateTime.now().toIso8601String(),
        'activities': activities.map((a) => a.toMap()).toList(),
        'records': records.map((r) => r.toMap()).toList(),
        'organizations': organizations.map((o) => o.toMap()).toList(),
      };

      final jsonString = jsonEncode(backupData);
      
      final tempDir = await getTemporaryDirectory();
      final fileName = 'badminton_diary_backup_${_formatDateTime(DateTime.now())}.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);

      debugPrint('✅ Data exported to ${file.path}');
      return file.path;
    } catch (e) {
      throw Exception('导出失败: $e');
    }
  }

  Future<void> importData() async {
    debugPrint('📥 Import functionality would be implemented here');
    throw Exception('导入功能暂未实现');
  }

  Future<String> exportToCSV() async {
    try {
      final records = await DatabaseService.instance.getRecords();
      
      final csv = StringBuffer();
      csv.writeln('日期,组织,时长(小时),场地费,球费,饮料费,其他费用,总费用,热量(千卡),胜局,负局');
      
      for (final record in records) {
        final orgs = await DatabaseService.instance.getOrganizations();
        final org = orgs.firstWhere(
          (o) => o.id == record.orgId,
          orElse: () => Organization(id: '', name: '未知', createdAt: DateTime.now()),
        );
        
        csv.writeln('${record.date},${org.name},${record.duration},'
            '${record.costs['court'] ?? 0},${record.costs['shuttlecock'] ?? 0},'
            '${record.costs['drinks'] ?? 0},${record.costs['other'] ?? 0},'
            '${record.totalCost},${record.calories},${record.wins},${record.losses}');
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = 'badminton_diary_records_${_formatDateTime(DateTime.now())}.csv';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(csv.toString());

      debugPrint('✅ CSV exported to ${file.path}');
      return file.path;
    } catch (e) {
      throw Exception('CSV导出失败: $e');
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}${dt.month.toString().padLeft(2, '0')}${dt.day.toString().padLeft(2, '0')}_'
        '${dt.hour.toString().padLeft(2, '0')}${dt.minute.toString().padLeft(2, '0')}';
  }
}
