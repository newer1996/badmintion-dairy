import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';
import 'services/settings_service.dart';
import 'services/notification_service.dart';
import 'models/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 初始化服务
  await SettingsService.instance.initialize();
  await DatabaseService.instance.initialize();
  await NotificationService.instance.initialize();

  // 请求通知权限
  await NotificationService.instance.requestPermission();

  runApp(const BadmintonDiaryApp());
}

class BadmintonDiaryApp extends StatefulWidget {
  const BadmintonDiaryApp({super.key});

  @override
  State<BadmintonDiaryApp> createState() => _BadmintonDiaryAppState();
}

class _BadmintonDiaryAppState extends State<BadmintonDiaryApp> {
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
    if (_settings == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: '羽球日记',
      debugShowCheckedModeBanner: false,
      themeMode: _settings!.themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF07C160),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF07C160),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF07C160),
        unselectedItemColor: Color(0xFF999999),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        backgroundColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF07C160),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Color(0xFF07C160),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF07C160),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF07C160),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: const Color(0xFF1E1E1E),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF07C160),
        unselectedItemColor: Color(0xFF999999),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        backgroundColor: Color(0xFF1E1E1E),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF07C160),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Color(0xFF07C160),
      ),
    );
  }
}
