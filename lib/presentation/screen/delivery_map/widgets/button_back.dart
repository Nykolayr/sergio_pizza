import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class ButtonOnMap extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color color;
  final int angle;
  const ButtonOnMap({
    super.key,
    required this.onPressed,
    this.icon = Icons.chevron_left,
    this.color = AppColor.blueDark,
    this.angle = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColor.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0x00000000).withValues(alpha: 0.07),
            blurRadius: 10.5,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Transform.rotate(
        angle: angle == 0 ? 0 : math.pi / angle,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: color,
            size: 25,
          ),
        ),
      ),
    );
  }
}
