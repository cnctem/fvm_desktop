import 'package:flutter/material.dart';
import 'theme_manager.dart';

/// 主题提供者 - 管理应用主题状态
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  ThemeProvider() {
    // 初始化时检测系统主题
    _initializeTheme();
    // 监听系统主题变化
    _setupSystemThemeListener();
  }

  /// 当前主题模式
  ThemeMode get themeMode => _themeMode;

  /// 是否为深色模式
  bool get isDarkMode => _isDarkMode;

  /// 获取当前主题数据
  ThemeData get currentTheme {
    switch (_themeMode) {
      case ThemeMode.light:
        return ThemeManager.lightTheme;
      case ThemeMode.dark:
        return ThemeManager.darkTheme;
      case ThemeMode.system:
        return _isDarkMode ? ThemeManager.darkTheme : ThemeManager.lightTheme;
    }
  }

  /// 初始化主题设置
  void _initializeTheme() {
    _isDarkMode = ThemeManager.isSystemDarkMode;
  }

  /// 设置系统主题变化监听器
  void _setupSystemThemeListener() {
    ThemeManager.listenToSystemThemeChange(() {
      if (_themeMode == ThemeMode.system) {
        _updateSystemTheme();
      }
    });
  }

  /// 更新系统主题状态
  void _updateSystemTheme() {
    final newIsDarkMode = ThemeManager.isSystemDarkMode;
    if (_isDarkMode != newIsDarkMode) {
      _isDarkMode = newIsDarkMode;
      notifyListeners();
    }
  }

  /// 设置主题模式
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      
      // 根据新的主题模式更新深色状态
      switch (mode) {
        case ThemeMode.light:
          _isDarkMode = false;
          break;
        case ThemeMode.dark:
          _isDarkMode = true;
          break;
        case ThemeMode.system:
          _isDarkMode = ThemeManager.isSystemDarkMode;
          break;
      }
      
      notifyListeners();
    }
  }

  /// 切换主题模式
  void toggleThemeMode() {
    switch (_themeMode) {
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        setThemeMode(ThemeMode.light);
        break;
    }
  }

  /// 获取主题模式描述文本
  String get themeModeDescription {
    switch (_themeMode) {
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  /// 清理资源
  @override
  void dispose() {
    ThemeManager.removeSystemThemeListener();
    super.dispose();
  }
}