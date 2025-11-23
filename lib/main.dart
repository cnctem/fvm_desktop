import 'package:flutter/material.dart';
import 'package:fvm_desktop/page/main_menu.dart';
import 'package:fvm_desktop/utils/theme/theme_provider.dart';
import 'package:fvm_desktop/utils/theme/theme_manager.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'FVM Desktop',
            theme: ThemeManager.lightTheme,
            darkTheme: ThemeManager.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainMenu(),
          );
        },
      ),
    );
  }
}
