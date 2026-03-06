import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/organization.dart';
import 'package:uuid/uuid.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Organization> _organizations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final orgs = await DatabaseService.instance.getOrganizations();
    setState(() {
      _organizations = orgs;
      _isLoading = false;
    });
  }

  Future<void> _addOrganization() async {
    final result = await showDialog<Organization>(
      context: context,
      builder: (context) => const AddOrgDialog(),
    );
    if (result != null) {
      await DatabaseService.instance.insertOrganization(result);
      _loadData();
    }
  }

  Future<void> _editOrganization(Organization org) async {
    final result = await showDialog<Organization>(
      context: context,
      builder: (context) => AddOrgDialog(organization: org),
    );
    if (result != null) {
      await DatabaseService.instance.updateOrganization(result);
      _loadData();
    }
  }

  Future<void> _deleteOrganization(Organization org) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除组织"${org.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseService.instance.deleteOrganization(org.id);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 用户信息卡片
                  _buildUserCard(),
                  const SizedBox(height: 24),
                  
                  // 组织管理
                  _buildSectionTitle('我的组织'),
                  const SizedBox(height: 12),
                  ..._organizations.map((org) => _buildOrgCard(org)),
                  const SizedBox(height: 12),
                  _buildAddOrgButton(),
                  const SizedBox(height: 24),
                  
                  // 设置
                  _buildSectionTitle('设置'),
                  const SizedBox(height: 12),
                  _buildSettingsCard(),
                  const SizedBox(height: 24),
                  
                  // 关于
                  _buildSectionTitle('关于'),
                  const SizedBox(height: 12),
                  _buildAboutCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF07C160), Color(0xFF06AD56)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF07C160).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 2),
            ),
            child: const Center(
              child: Text('🏸', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '羽毛球爱好者',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '已加入 ${_organizations.length} 个组织',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
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

  Widget _buildOrgCard(Organization org) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF07C160).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🏸', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  org.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (org.defaultLocation != null)
                  Text(
                    '📍 ${org.defaultLocation}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (org.defaultCost != null)
                  Text(
                    '💰 默认 ¥${org.defaultCost}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _editOrganization(org);
              } else if (value == 'delete') {
                _deleteOrganization(org);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('编辑'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('删除', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddOrgButton() {
    return InkWell(
      onTap: _addOrganization,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              '添加组织',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: '通知提醒',
            subtitle: '活动开始前提醒',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: const Color(0xFF07C160),
            ),
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingItem(
            icon: Icons.dark_mode_outlined,
            title: '深色模式',
            subtitle: '跟随系统',
            trailing: Switch(
              value: false,
              onChanged: (value) {},
              activeColor: const Color(0xFF07C160),
            ),
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingItem(
            icon: Icons.backup_outlined,
            title: '数据备份',
            subtitle: '导出/导入数据',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据备份功能开发中')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
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
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildAboutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAboutItem(
            icon: Icons.info_outline,
            title: '版本',
            value: 'v1.0.0',
          ),
          const Divider(height: 1, indent: 56),
          _buildAboutItem(
            icon: Icons.code,
            title: '开源协议',
            value: 'MIT',
          ),
          const Divider(height: 1, indent: 56),
          _buildAboutItem(
            icon: Icons.favorite,
            title: '致谢',
            value: 'Flutter Team',
          ),
        ],
      ),
    );
  }

  Widget _buildAboutItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.grey.shade600),
      ),
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }
}

// 添加/编辑组织对话框
class AddOrgDialog extends StatefulWidget {
  final Organization? organization;
  
  const AddOrgDialog({super.key, this.organization});

  @override
  State<AddOrgDialog> createState() => _AddOrgDialogState();
}

class _AddOrgDialogState extends State<AddOrgDialog> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _costController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.organization != null) {
      _nameController.text = widget.organization!.name;
      _locationController.text = widget.organization!.defaultLocation ?? '';
      if (widget.organization!.defaultCost != null) {
        _costController.text = widget.organization!.defaultCost.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.organization == null ? '添加组织' : '编辑组织'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '组织名称 *',
                hintText: '例如：公司球友群',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入组织名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: '默认地点',
                hintText: '例如：李宁羽毛球馆',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '默认费用',
                hintText: '例如：40',
                suffixText: '元',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF07C160),
            foregroundColor: Colors.white,
          ),
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;

    final org = Organization(
      id: widget.organization?.id ?? _uuid.v4(),
      name: _nameController.text,
      defaultLocation: _locationController.text.isEmpty ? null : _locationController.text,
      defaultCost: _costController.text.isEmpty ? null : double.parse(_costController.text),
      createdAt: widget.organization?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, org);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _costController.dispose();
    super.dispose();
  }
}
