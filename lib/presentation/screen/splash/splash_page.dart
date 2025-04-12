// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class SplashPage extends StatefulWidget {
  final bool isReg;
  const SplashPage({super.key, required this.isReg});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final int numDots = 3;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 150, right: 40, left: 40),
              child: SvgPicture.asset(
                'assets/svg/logo.svg',
                fit: BoxFit.contain,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Загружаемся', style: AppText.text10grey),
                ...List.generate(numDots, (index) {
                  return AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          8 *
                              (controller.value + index / numDots) %
                              1.0 *
                              numDots,
                          0,
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          height: 2,
                          width: 2,
                          decoration: const BoxDecoration(
                            color: AppColor.greyText,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
