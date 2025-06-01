import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600), // 1 оборот за 1.6 сек
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 68,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.1415926535,
            child: child,
          );
        },
        child: SvgPicture.asset(
          'assets/svg/loader.svg',
          width: 168,
          height: 168,
          colorFilter: const ColorFilter.mode(
            AppColor.blueDark,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
