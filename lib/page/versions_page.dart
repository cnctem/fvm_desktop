import 'package:flutter/material.dart';

class VersionsPage extends StatelessWidget {
  const VersionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          'Flutter Versions Management',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}