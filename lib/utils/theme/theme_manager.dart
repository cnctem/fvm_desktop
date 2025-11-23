import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 主题管理器 - 根据系统深色模式状态管理应用主题
class ThemeManager {
  /// 获取当前系统的深色模式状态
  static bool get isSystemDarkMode {
    // 获取系统平台亮度
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  /// 根据系统状态获取主题模式
  static ThemeMode get systemThemeMode {
    return isSystemDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  /// 创建亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 58, 81, 183),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      // 添加一些常用的亮色主题配置
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 58, 81, 183),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// 创建暗色主题
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 58, 81, 183),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      // 添加一些常用的暗色主题配置
      appBarTheme: AppBarTheme(
        backgroundColor: const Color.fromARGB(255, 30, 40, 90),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: const Color.fromARGB(255, 45, 45, 45),
      ),
      scaffoldBackgroundColor: const Color.fromARGB(255, 30, 30, 30),
    );
  }

  /// 监听系统主题变化
  static void listenToSystemThemeChange(VoidCallback onThemeChanged) {
    // 添加平台亮度变化的监听器
    final dispatcher = SchedulerBinding.instance.platformDispatcher;
    dispatcher.onPlatformBrightnessChanged = () {
      onThemeChanged();
    };
  }

  /// 移除系统主题变化监听
  static void removeSystemThemeListener() {
    final dispatcher = SchedulerBinding.instance.platformDispatcher;
    dispatcher.onPlatformBrightnessChanged = null;
  }
}