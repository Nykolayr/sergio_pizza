import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  final bool isReg;
  const SplashPage({super.key, required this.isReg});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('SplashPage'));
  }
}
