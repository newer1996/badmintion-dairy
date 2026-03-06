import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/record.dart';
import '../models/organization.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class AddRecordScreen extends StatefulWidget {
  final Activity? activity;
  
  const AddRecordScreen({super.key, this.activity});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _uuid = const Uuid();
  
  // 费用
  final _courtController = TextEditingController();
  final _shuttlecockController = TextEditingController();
  final _drinksController = TextEditingController();
  final _otherController = TextEditingController();
  
  // 运动数据
  double _duration = 2.0;
  Intensity _intensity = Intensity.medium;
  int _calories = 0;
  
  // 对战记录
  MatchType _matchType = MatchType.doubles;
  final _winsController = TextEditingController(text: '0');
  final _lossesController = TextEditingController(text: '0');
  
  // 心情
  Mood _mood = Mood.good;
  
  // 备注
  final _noteController = TextEditingController();
  
  Organization? _organization;

  @override
  void initState() {
    super.initState();
    _loadOrganization();
    _calculateCalories();
    
    if (widget.activity?.costEstimate != null) {
      _courtController.text = widget.activity!.costEstimate.toString();
    }
  }

  Future<void> _loadOrganization() async {
    if (widget.activity != null) {
      final orgs = await DatabaseService.instance.getOrganizations();
      _organization = orgs.firstWhere(
        (o) => o.id == widget.activity!.orgId,
        orElse: () => Organization(id: '', name: '未知组织', createdAt: DateTime.now()),
      );
      setState(() {});
    }
  }

  void _calculateCalories() {
    final caloriesPerHour = switch (_intensity) {
      Intensity.low => 300,
      Intensity.medium => 500,
      Intensity.high => 700,
    };
    setState(() {
      _calories = (_duration * caloriesPerHour).round();
    });
  }

  double get _totalCost {
    return (double.tryParse(_courtController.text) ?? 0) +
        (double.tryParse(_shuttlecockController.text) ?? 0) +
        (double.tryParse(_drinksController.text) ?? 0) +
        (double.tryParse(_otherController.text) ?? 0);
  }

  Future<void> _save() async {
    if (widget.activity == null) return;

    final record = Record(
      id: _uuid.v4(),
      activityId: widget.activity!.id,
      orgId: widget.activity!.orgId,
      date: widget.activity!.date,
      duration: _duration,
      costs: {
        'court': double.tryParse(_courtController.text) ?? 0,
        'shuttlecock': double.tryParse(_shuttlecockController.text) ?? 0,
        'drinks': double.tryParse(_drinksController.text) ?? 0,
        'other': double.tryParse(_otherController.text) ?? 0,
      },
      intensity: _intensity,
      calories: _calories,
      matchType: _matchType,
      wins: int.tryParse(_winsController.text) ?? 0,
      losses: int.tryParse(_lossesController.text) ?? 0,
      mood: _mood,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      createdAt: DateTime.now(),
    );

    await DatabaseService.instance.insertRecord(record);
    
    // 更新活动状态为已完成
    final updatedActivity = widget.activity!.copyWith(status: ActivityStatus.completed);
    await DatabaseService.instance.updateActivity(updatedActivity);
    
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('打球记录'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 活动信息卡片
          if (_organization != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF07C160), Color(0xFF06AD56)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _organization!.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.activity!.date.month}月${widget.activity!.date.day}日 ${widget.activity!.startTime}-${widget.activity!.endTime}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  if (widget.activity!.location != null)
                    Text(
                      '📍 ${widget.activity!.location}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          
          // 费用记录
          _buildSectionTitle('💰 费用记录'),
          const SizedBox(height: 12),
          _buildCostItem('场地费', _courtController),
          const SizedBox(height: 12),
          _buildCostItem('球费', _shuttlecockController),
          const SizedBox(height: 12),
          _buildCostItem('饮料/水', _drinksController),
          const SizedBox(height: 12),
          _buildCostItem('其他', _otherController),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF07C160).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '合计',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '¥${_totalCost.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF07C160),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // 运动数据
          _buildSectionTitle('🔥 运动数据'),
          const SizedBox(height: 12),
          _buildInfoRow('运动时长', '${_duration.toStringAsFixed(1)} 小时'),
          const SizedBox(height: 16),
          _buildSectionSubTitle('运动强度'),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildIntensityOption('低', Intensity.low),
              const SizedBox(width: 12),
              _buildIntensityOption('中', Intensity.medium),
              const SizedBox(width: 12),
              _buildIntensityOption('高', Intensity.high),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('消耗热量', '$_calories 千卡'),
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '💡 参考：低强度约300千卡/小时，中强度约500千卡/小时，高强度约700千卡/小时',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 对战记录
          _buildSectionTitle('🏸 对战记录'),
          const SizedBox(height: 12),
          _buildSectionSubTitle('比赛类型'),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMatchTypeOption('单打', MatchType.singles),
              const SizedBox(width: 12),
              _buildMatchTypeOption('双打', MatchType.doubles),
              const SizedBox(width: 12),
              _buildMatchTypeOption('混双', MatchType.mixed),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildResultInput('赢', _winsController)),
              const SizedBox(width: 16),
              Expanded(child: _buildResultInput('输', _lossesController)),
            ],
          ),
          const SizedBox(height: 24),
          
          // 身体状态
          _buildSectionTitle('身体状态'),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMoodOption('🔥', '超棒', Mood.great),
              const SizedBox(width: 8),
              _buildMoodOption('😊', '不错', Mood.good),
              const SizedBox(width: 8),
              _buildMoodOption('😅', '累了', Mood.tired),
              const SizedBox(width: 8),
              _buildMoodOption('😫', ' exhausted', Mood.exhausted),
            ],
          ),
          const SizedBox(height: 24),
          
          // 备注
          _buildSectionTitle('📝 备注'),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 4,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: '记录今天的感受：手感如何？杀球爽不爽？有什么值得记住的？',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 32),
          
          // 保存按钮
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07C160),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                '保存记录',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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

  Widget _buildSectionSubTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildCostItem(String label, TextEditingController controller) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '¥',
              hintText: '0',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildIntensityOption(String label, Intensity intensity) {
    final isSelected = _intensity == intensity;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _intensity = intensity;
            _calculateCalories();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF07C160).withOpacity(0.1) : Colors.grey.shade100,
            border: Border.all(
              color: isSelected ? const Color(0xFF07C160) : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF07C160) : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchTypeOption(String label, MatchType type) {
    final isSelected = _matchType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _matchType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF07C160).withOpacity(0.1) : Colors.grey.shade100,
            border: Border.all(
              color: isSelected ? const Color(0xFF07C160) : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF07C160) : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultInput(String label, TextEditingController controller) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text('局', style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMoodOption(String emoji, String label, Mood mood) {
    final isSelected = _mood == mood;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _mood = mood),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF07C160).withOpacity(0.1) : Colors.grey.shade100,
            border: Border.all(
              color: isSelected ? const Color(0xFF07C160) : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? const Color(0xFF07C160) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _courtController.dispose();
    _shuttlecockController.dispose();
    _drinksController.dispose();
    _otherController.dispose();
    _winsController.dispose();
    _lossesController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}