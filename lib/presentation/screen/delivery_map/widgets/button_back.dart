import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class ButtonBack extends StatelessWidget {
  final VoidCallback onPressed;
  const ButtonBack({super.key, required this.onPressed});

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
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(
          Icons.chevron_left,
          color: AppColor.blueDark,
          size: 25,
        ),
      ),
    );
  }
}
