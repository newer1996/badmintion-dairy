import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';
import '../models/record.dart';
import '../models/organization.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _timeRange = 'month';
  Map<String, dynamic> _stats = {};
  List<Record> _records = [];
  List<Organization> _organizations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final records = await DatabaseService.instance.getRecords();
    final orgs = await DatabaseService.instance.getOrganizations();
    final stats = await DatabaseService.instance.getStatistics();
    
    setState(() {
      _records = records;
      _organizations = orgs;
      _stats = stats;
      _isLoading = false;
    });
  }

  List<Record> get _filteredRecords {
    final now = DateTime.now();
    return _records.where((r) {
      final date = r.date;
      switch (_timeRange) {
        case 'week':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          return date.isAfter(weekStart.subtract(const Duration(days: 1)));
        case 'month':
          return date.year == now.year && date.month == now.month;
        case 'year':
          return date.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  Map<String, dynamic> get _filteredStats {
    final filtered = _filteredRecords;
    return {
      'count': filtered.length,
      'duration': filtered.fold<double>(0, (sum, r) => sum + r.duration),
      'calories': filtered.fold<int>(0, (sum, r) => sum + r.calories),
      'cost': filtered.fold<double>(0, (sum, r) => sum + r.totalCost),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 时间筛选
                    _buildTimeFilter(),
                    const SizedBox(height: 24),
                    
                    // 核心数据
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    
                    // 费用明细
                    if (_filteredRecords.isNotEmpty) ...[
                      _buildCostBreakdown(),
                      const SizedBox(height: 24),
                    ],
                    
                    // 组织统计
                    if (_filteredRecords.isNotEmpty) ...[
                      _buildOrgStats(),
                      const SizedBox(height: 24),
                    ],
                    
                    // 战绩统计
                    if (_filteredRecords.isNotEmpty) ...[
                      _buildMatchStats(),
                    ],
                    
                    // 空状态
                    if (_filteredRecords.isEmpty)
                      _buildEmptyState(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTimeFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTimeOption('本周', 'week'),
          _buildTimeOption('本月', 'month'),
          _buildTimeOption('本年', 'year'),
          _buildTimeOption('全部', 'all'),
        ],
      ),
    );
  }

  Widget _buildTimeOption(String label, String value) {
    final isSelected = _timeRange == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _timeRange = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF07C160) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = _filteredStats;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard('${stats['count']}', '打球场次', Icons.sports_tennis),
        _buildStatCard('${stats['duration'].toStringAsFixed(1)}', '运动时长(小时)', Icons.timer),
        _buildStatCard('${stats['calories']}', '消耗热量(千卡)', Icons.local_fire_department),
        _buildStatCard('¥${stats['cost'].toStringAsFixed(0)}', '总花费', Icons.account_balance_wallet),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF07C160), size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF07C160),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostBreakdown() {
    final costs = {'court': 0.0, 'shuttlecock': 0.0, 'drinks': 0.0, 'other': 0.0};
    for (final record in _filteredRecords) {
      costs['court'] = (costs['court'] ?? 0) + (record.costs['court'] ?? 0);
      costs['shuttlecock'] = (costs['shuttlecock'] ?? 0) + (record.costs['shuttlecock'] ?? 0);
      costs['drinks'] = (costs['drinks'] ?? 0) + (record.costs['drinks'] ?? 0);
      costs['other'] = (costs['other'] ?? 0) + (record.costs['other'] ?? 0);
    }
    
    final total = costs.values.fold<double>(0, (sum, v) => sum + v);
    if (total == 0) return const SizedBox.shrink();

    final costLabels = {
      'court': '场地费',
      'shuttlecock': '球费',
      'drinks': '饮料/水',
      'other': '其他',
    };
    
    final costColors = [
      const Color(0xFF07C160),
      const Color(0xFF10AEFF),
      const Color(0xFFFFC300),
      const Color(0xFF999999),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💰 费用明细',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...costs.entries.map((entry) {
            final index = costs.keys.toList().indexOf(entry.key);
            final percentage = total > 0 ? (entry.value / total * 100) : 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(costLabels[entry.key]!),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '¥${entry.value.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total > 0 ? entry.value / total : 0,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(costColors[index]),
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '场均花费',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '¥${(_filteredRecords.isNotEmpty ? total / _filteredRecords.length : 0).toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF07C160),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrgStats() {
    final orgStats = <String, Map<String, dynamic>>{};
    for (final record in _filteredRecords) {
      if (!orgStats.containsKey(record.orgId)) {
        final org = _organizations.firstWhere(
          (o) => o.id == record.orgId,
          orElse: () => Organization(id: '', name: '未知组织', createdAt: DateTime.now()),
        );
        orgStats[record.orgId] = {
          'name': org.name,
          'count': 0,
          'cost': 0.0,
        };
      }
      orgStats[record.orgId]!['count'] = (orgStats[record.orgId]!['count'] as int) + 1;
      orgStats[record.orgId]!['cost'] = (orgStats[record.orgId]!['cost'] as double) + record.totalCost;
    }

    final sortedOrgs = orgStats.entries.toList()
      ..sort((a, b) => (b.value['count'] as int).compareTo(a.value['count'] as int));

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏸 常去组织',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedOrgs.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.value['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${entry.value['count']} 场',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '¥${(entry.value['cost'] as double).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMatchStats() {
    int totalMatches = 0;
    int totalWins = 0;
    int totalLosses = 0;
    
    for (final record in _filteredRecords) {
      totalMatches += record.wins + record.losses;
      totalWins += record.wins;
      totalLosses += record.losses;
    }

    if (totalMatches == 0) return const SizedBox.shrink();

    final winRate = totalMatches > 0 ? (totalWins / totalMatches * 100) : 0;

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 战绩统计',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMatchStat('总对局', '$totalMatches 局', Colors.black87),
              _buildMatchStat('胜', '$totalWins 局', const Color(0xFF07C160)),
              _buildMatchStat('负', '$totalLosses 局', const Color(0xFFFA5151)),
              _buildMatchStat('胜率', '${winRate.toStringAsFixed(1)}%', const Color(0xFF10AEFF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatchStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无数据',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '快去记录你的第一场球吧！',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}