import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/organization.dart';
import '../models/activity.dart';
import '../models/record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('badminton_diary.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // 组织表
    await db.execute('''
      CREATE TABLE organizations (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        defaultLocation TEXT,
        defaultCost REAL,
        createdAt TEXT NOT NULL
      )
    ''');

    // 活动表
    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        orgId TEXT NOT NULL,
        date TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        location TEXT,
        costEstimate REAL,
        status INTEGER NOT NULL DEFAULT 0,
        note TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // 记录表
    await db.execute('''
      CREATE TABLE records (
        id TEXT PRIMARY KEY,
        activityId TEXT,
        orgId TEXT NOT NULL,
        date TEXT NOT NULL,
        duration REAL NOT NULL,
        costs TEXT NOT NULL,
        intensity INTEGER NOT NULL DEFAULT 1,
        calories INTEGER NOT NULL,
        matchType INTEGER NOT NULL DEFAULT 1,
        wins INTEGER NOT NULL DEFAULT 0,
        losses INTEGER NOT NULL DEFAULT 0,
        mood INTEGER NOT NULL DEFAULT 1,
        note TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    // 插入默认组织
    await db.insert('organizations', {
      'id': 'org_default_1',
      'name': '公司球友群',
      'defaultLocation': '李宁羽毛球馆',
      'defaultCost': 40.0,
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('organizations', {
      'id': 'org_default_2',
      'name': 'XX羽毛球俱乐部',
      'defaultLocation': '奥体中心',
      'defaultCost': 50.0,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> initialize() async {
    await database;
  }

  // 组织相关操作
  Future<List<Organization>> getOrganizations() async {
    final db = await database;
    final maps = await db.query('organizations', orderBy: 'createdAt DESC');
    return maps.map((e) => Organization.fromMap(e)).toList();
  }

  Future<void> insertOrganization(Organization org) async {
    final db = await database;
    await db.insert('organizations', org.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateOrganization(Organization org) async {
    final db = await database;
    await db.update('organizations', org.toMap(),
        where: 'id = ?', whereArgs: [org.id]);
  }

  Future<void> deleteOrganization(String id) async {
    final db = await database;
    await db.delete('organizations', where: 'id = ?', whereArgs: [id]);
  }

  // 活动相关操作
  Future<List<Activity>> getActivities() async {
    final db = await database;
    final maps = await db.query('activities', orderBy: 'date ASC, startTime ASC');
    return maps.map((e) => Activity.fromMap(e)).toList();
  }

  Future<List<Activity>> getUpcomingActivities() async {
    final db = await database;
    final now = DateTime.now();
    final twoWeeksLater = now.add(const Duration(days: 14));
    
    final maps = await db.query(
      'activities',
      where: 'date >= ? AND date <= ? AND status != ?',
      whereArgs: [
        now.toIso8601String(),
        twoWeeksLater.toIso8601String(),
        ActivityStatus.cancelled.index,
      ],
      orderBy: 'date ASC, startTime ASC',
    );
    return maps.map((e) => Activity.fromMap(e)).toList();
  }

  Future<void> insertActivity(Activity activity) async {
    final db = await database;
    await db.insert('activities', activity.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateActivity(Activity activity) async {
    final db = await database;
    await db.update('activities', activity.toMap(),
        where: 'id = ?', whereArgs: [activity.id]);
  }

  Future<void> deleteActivity(String id) async {
    final db = await database;
    await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  // 记录相关操作
  Future<List<Record>> getRecords() async {
    final db = await database;
    final maps = await db.query('records', orderBy: 'date DESC');
    return maps.map((e) => Record.fromMap(e)).toList();
  }

  Future<void> insertRecord(Record record) async {
    final db = await database;
    await db.insert('records', record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateRecord(Record record) async {
    final db = await database;
    await db.update('records', record.toMap(),
        where: 'id = ?', whereArgs: [record.id]);
  }

  Future<void> deleteRecord(String id) async {
    final db = await database;
    await db.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  // 统计查询
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    // 总记录数
    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM records');
    final totalCount = Sqflite.firstIntValue(countResult) ?? 0;
    
    // 总时长
    final durationResult = await db.rawQuery('SELECT SUM(duration) as total FROM records');
    final totalDuration = (durationResult.first['total'] as num?)?.toDouble() ?? 0;
    
    // 总花费
    final records = await getRecords();
    final totalCost = records.fold<double>(0, (sum, r) => sum + r.totalCost);
    
    // 总消耗
    final caloriesResult = await db.rawQuery('SELECT SUM(calories) as total FROM records');
    final totalCalories = Sqflite.firstIntValue(caloriesResult) ?? 0;
    
    return {
      'totalCount': totalCount,
      'totalDuration': totalDuration,
      'totalCost': totalCost,
      'totalCalories': totalCalories,
    };
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}