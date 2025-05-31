// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/injects.dart';
import 'package:sergio_pizza/domain/repository/user_repository.dart';
import 'package:sergio_pizza/domain/routers/routers.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final int numDots = 3;
  // bool isLoading = true;

  Future<void> initializeApp() async {
    try {
      await initMain();
      Logger.i('initializeApp');
      final userRepository = Get.find<UserRepository>();
      final isReg = userRepository.isReg;

      // if (mounted) {
      //   setState(() {
      //     isLoading = false;
      //   });
      // }

      if (isReg) {
        // Проверяем наличие любого адреса (доставки или самовывоза)
        final hasAnyAddress = userRepository.hasAnyAddress;

        if (hasAnyAddress) {
          router.go('/main'); // Переходим на главную, если есть любой адрес
        } else {
          router.go('/main/delivery'); // Переходим сразу на выбор адреса
        }
      } else {
        router.goNamed('авторизация');
      }
    } catch (e) {
      Logger.e('initializeApp error: $e');
      // if (mounted) {
      //   setState(() {
      //     isLoading = false;
      //   });
      // }
    }
  }

  @override
  void initState() {
    super.initState();
    initializeApp();
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
                Text('Загружаемся', style: AppText.text14lb),
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
                          height: 3,
                          width: 3,
                          decoration: const BoxDecoration(
                            color: AppColor.greyLight,
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
