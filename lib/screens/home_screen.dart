import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/record.dart';
import '../models/organization.dart';
import '../services/database_service.dart';
import 'add_activity_screen.dart';
import 'add_record_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const ScheduleTab(),
    const StatsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: '日程',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: '统计',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddActivityScreen()),
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  List<Activity> _activities = [];
  List<Record> _recentRecords = [];
  List<Organization> _organizations = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final activities = await DatabaseService.instance.getUpcomingActivities();
    final records = await DatabaseService.instance.getRecords();
    final orgs = await DatabaseService.instance.getOrganizations();
    final stats = await DatabaseService.instance.getStatistics();
    
    setState(() {
      _activities = activities;
      _recentRecords = records.take(4).toList();
      _organizations = orgs;
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('羽球日记'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 头部日期卡片
                    _buildHeaderCard(now, weekdayNames),
                    const SizedBox(height: 24),
                    
                    // 活动列表
                    _buildSectionTitle('🏸 upcoming 活动', _activities.isEmpty),
                    const SizedBox(height: 12),
                    _activities.isEmpty
                        ? _buildEmptyState()
                        : Column(
                            children: _activities.map((a) => _buildActivityCard(a)).toList(),
                          ),
                    const SizedBox(height: 24),
                    
                    // 最近记录
                    if (_recentRecords.isNotEmpty) ...[
                      _buildSectionTitle('📝 最近记录', false),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _recentRecords.length,
                        itemBuilder: (context, index) => _buildRecordCard(_recentRecords[index]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCard(DateTime now, List<String> weekdayNames) {
    final weeklyCount = _stats['totalCount'] ?? 0;
    final monthlyCost = (_stats['totalCost'] ?? 0).toStringAsFixed(0);
    
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${now.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${now.month}月',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        weekdayNames[now.weekday - 1],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (weeklyCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '本周 $weeklyCount 场',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickStat('${_activities.where((a) => a.status == ActivityStatus.registered).length}', '待参加'),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildQuickStat('$weeklyCount', '本周场次'),
                Container(width: 1, height: 40, color: Colors.white24),
                _buildQuickStat('¥$monthlyCost', '本月花费'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool showAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showAdd)
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddActivityScreen()),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('添加'),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF0FFF4), Color(0xFFE6F7ED)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🏸', style: TextStyle(fontSize: 60)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '还没有 upcoming 活动',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击右下角按钮，添加你的第一场球局',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHintItem('🏸', '支持多组织管理'),
              const SizedBox(width: 24),
              _buildHintItem('⏰', '自动检测时间冲突'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHintItem(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final org = _organizations.firstWhere(
      (o) => o.id == activity.orgId,
      orElse: () => Organization(
        id: '',
        name: '未知组织',
        createdAt: DateTime.now(),
      ),
    );
    
    final date = activity.date;
    final now = DateTime.now();
    final diffDays = date.difference(DateTime(now.year, now.month, now.day)).inDays;
    final weekdayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    
    String daysLeftText;
    if (diffDays == 0) {
      daysLeftText = '今天';
    } else if (diffDays == 1) {
      daysLeftText = '明天';
    } else {
      daysLeftText = '$diffDays天后';
    }
    
    final isToday = diffDays == 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isToday
            ? Border.all(color: const Color(0xFF07C160), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // 左侧日期
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weekdayNames[date.weekday - 1],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${date.month}月',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 中间内容
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${activity.startTime}-${activity.endTime}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: activity.statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      org.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (activity.location != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '📍 ${activity.location}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // 右侧操作
            Container(
              width: 80,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _onActivityAction(activity),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: activity.status == ActivityStatus.registered
                          ? const Color(0xFF07C160)
                          : Colors.grey.shade200,
                      foregroundColor: activity.status == ActivityStatus.registered
                          ? Colors.white
                          : Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      activity.status == ActivityStatus.registered
                          ? '记录'
                          : (activity.status == ActivityStatus.completed ? '已完成' : '报名'),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    daysLeftText,
                    style: TextStyle(
                      fontSize: 12,
                      color: isToday ? const Color(0xFF07C160) : Colors.grey,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(Record record) {
    final org = _organizations.firstWhere(
      (o) => o.id == record.orgId,
      orElse: () => Organization(
        id: '',
        name: '未知组织',
        createdAt: DateTime.now(),
      ),
    );
    
    final now = DateTime.now();
    final date = record.date;
    String dateText;
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      dateText = '今天';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      dateText = '昨天';
    } else {
      dateText = '${date.month}/${date.day}';
    }
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateText,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF07C160).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '¥${record.totalCost.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF07C160),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            org.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              _buildRecordStat('⏱️', '${record.duration.toStringAsFixed(0)}小时'),
              const SizedBox(width: 12),
              _buildRecordStat('🔥', '${record.calories}千卡'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordStat(String icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _onActivityAction(Activity activity) async {
    if (activity.status == ActivityStatus.registered) {
      // 去记录
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddRecordScreen(activity: activity),
        ),
      );
      if (result == true) {
        _loadData();
      }
    } else if (activity.status == ActivityStatus.pending) {
      // 标记已报名
      final updated = activity.copyWith(status: ActivityStatus.registered);
      await DatabaseService.instance.updateActivity(updated);
      _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已标记报名')),
        );
      }
    }
  }
}