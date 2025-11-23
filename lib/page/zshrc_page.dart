import 'package:flutter/material.dart';

class ZshrcPage extends StatelessWidget {
  const ZshrcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          '.zshrc Terminal Configuration',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}