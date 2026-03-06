import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/database_service.dart';
import '../models/activity.dart';
import '../models/record.dart';
import '../models/organization.dart';

class BackupService {
  static final BackupService instance = BackupService._init();
  
  BackupService._init();

  // 导出数据
  Future<String> exportData() async {
    try {
      // 获取所有数据
      final activities = await DatabaseService.instance.getActivities();
      final records = await DatabaseService.instance.getRecords();
      final organizations = await DatabaseService.instance.getOrganizations();

      // 构建备份数据
      final backupData = {
        'version': '1.0.0',
        'exportTime': DateTime.now().toIso8601String(),
        'activities': activities.map((a) => a.toMap()).toList(),
        'records': records.map((r) => r.toMap()).toList(),
        'organizations': organizations.map((o) => o.toMap()).toList(),
      };

      // 转换为 JSON
      final jsonString = jsonEncode(backupData);
      
      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final fileName = 'badminton_diary_backup_${_formatDateTime(DateTime.now())}.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString);

      // 分享文件
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '羽球日记数据备份',
      );

      return file.path;
    } catch (e) {
      throw Exception('导出失败: $e');
    }
  }

  // 导入数据
  Future<void> importData() async {
    try {
      // 选择文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('未选择文件');
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // 验证版本
      final version = backupData['version'] as String?;
      if (version == null) {
        throw Exception('无效的备份文件');
      }

      // 导入组织
      final organizations = (backupData['organizations'] as List?)
          ?.map((o) => Organization.fromMap(o as Map<String, dynamic>))
          .toList() ?? [];

      for (final org in organizations) {
        await DatabaseService.instance.insertOrganization(org);
      }

      // 导入活动
      final activities = (backupData['activities'] as List?)
          ?.map((a) => Activity.fromMap(a as Map<String, dynamic>))
          .toList() ?? [];

      for (final activity in activities) {
        await DatabaseService.instance.insertActivity(activity);
      }

      // 导入记录
      final records = (backupData['records'] as List?)
          ?.map((r) => Record.fromMap(r as Map<String, dynamic>))
          .toList() ?? [];

      for (final record in records) {
        await DatabaseService.instance.insertRecord(record);
      }

    } catch (e) {
      throw Exception('导入失败: $e');
    }
  }

  // 导出为 CSV
  Future<String> exportToCSV() async {
    try {
      final records = await DatabaseService.instance.getRecords();
      
      // CSV 头部
      final csv = StringBuffer();
      csv.writeln('日期,组织,时长(小时),场地费,球费,饮料费,其他费用,总费用,热量(千卡),胜局,负局');
      
      // 数据行
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

      // 保存文件
      final tempDir = await getTemporaryDirectory();
      final fileName = 'badminton_diary_records_${_formatDateTime(DateTime.now())}.csv';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(csv.toString());

      // 分享文件
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '羽球日记记录导出',
      );

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
