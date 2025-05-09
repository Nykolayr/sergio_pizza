import 'package:flutter/material.dart';
import 'package:sergio_pizza/presentation/widgets/buttons.dart';

class BottomAuth extends StatelessWidget {
  final bool isEnable;
  final void Function() onPressed;
  const BottomAuth({
    super.key,
    required this.isEnable,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            ButtonWide(
              onPressed: onPressed,
              text: 'Отправить код',
              isNext: true,
              isEnable: isEnable,
            ),
          ],
        ),
      ),
    );
  }
}
