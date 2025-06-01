import 'package:flutter/material.dart';
import 'package:sergio_pizza/presentation/theme/colors.dart';

class HandleLine extends StatelessWidget {
  const HandleLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 60,
        height: 5,
        decoration: BoxDecoration(
          color: AppColor.greyLight,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}
