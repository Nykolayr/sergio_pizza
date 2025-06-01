import 'package:flutter/material.dart';
import 'package:sergio_pizza/presentation/theme/colors.dart';

class CloseIcon extends StatelessWidget {
  final VoidCallback onPressed;
  const CloseIcon({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.only(right: 16, bottom: 8),
          color: Colors.transparent,
          child: const Icon(
            Icons.close,
            color: AppColor.greyIcon,
            size: 20,
          ),
        ),
      ),
    );
  }
}
