import 'package:flutter/material.dart';
import '../services/backup_service.dart';
import '../services/settings_service.dart';
import '../models/settings.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据备份'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('导出数据'),
          const SizedBox(height: 12),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('导出为 JSON'),
              subtitle: const Text('导出所有数据为 JSON 文件'),
              trailing: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _isExporting ? null : () => _exportData(),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('导出为 CSV'),
              subtitle: const Text('导出记录为 Excel 可打开的 CSV 文件'),
              trailing: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _isExporting ? null : () => _exportToCSV(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('导入数据'),
          const SizedBox(height: 12),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('从 JSON 导入'),
              subtitle: const Text('从备份文件恢复数据'),
              trailing: _isImporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _isImporting ? null : () => _importData(),
            ),
          ]),
          if (_settings?.lastBackupTime != null) ...[
            const SizedBox(height: 24),
            _buildLastBackupInfo(),
          ],
          const SizedBox(height: 24),
          _buildWarningCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF07C160).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF07C160),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_sync, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '数据备份',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '定期备份您的数据，防止意外丢失',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildLastBackupInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Color(0xFF07C160)),
          const SizedBox(width: 12),
          Text(
            '上次备份: ${_formatDateTime(_settings!.lastBackupTime!)}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '导入数据将覆盖现有数据，请确保已备份当前数据。',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    try {
      final path = await BackupService.instance.exportData();
      await SettingsService.instance.setLastBackupTime(DateTime.now());
      await _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('数据导出成功: $path')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportToCSV() async {
    setState(() => _isExporting = true);
    try {
      await BackupService.instance.exportToCSV();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV导出成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _importData() async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认导入'),
        content: const Text('导入数据将覆盖现有数据，确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('导入'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isImporting = true);
    try {
      await BackupService.instance.importData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据导入成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    } finally {
      setState(() => _isImporting = false);
    }
  }
}
