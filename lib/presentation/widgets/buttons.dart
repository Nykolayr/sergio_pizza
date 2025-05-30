import 'package:sergio_pizza/presentation/theme/theme.dart';
import 'package:flutter/material.dart';

/// большая кнопка

class ButtonWide extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnable;
  const ButtonWide({
    required this.text,
    required this.onPressed,
    this.isEnable = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isEnable) {
          onPressed();
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        height: 54,
        decoration: BoxDecoration(
          color: isEnable ? AppColor.blueLight : AppColor.blueLight2,
          borderRadius: AppDif.borderRadius16,
        ),
        child: Center(
          child: Text(
            text,
            style: AppText.text14sb.copyWith(
                color: isEnable ? AppColor.whitefon : AppColor.blueLight),
          ),
        ),
      ),
    );
  }
}

/// общий класс для кнопок приложения
class ButtonSelf extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final bool isGrey;
  final bool isDark;
  final Color? color;
  const ButtonSelf({
    required this.text,
    required this.width,
    required this.height,
    required this.onPressed,
    this.isDark = false,
    this.isGrey = false,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Color? colorButton = color;
    colorButton ??= isDark
        ? AppColor.redButton
        : isGrey
            ? AppColor.greyLight2
            : AppColor.red;
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        children: [
          Container(width: width, height: height, color: Colors.transparent),
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: colorButton,
              borderRadius: AppDif.borderRadius8,
              border: Border.all(color: colorButton, width: 1),
            ),
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: AppText.text14sw,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// класс с прессетами кнопок приложения
class Buttons {
  /// кнопка входа в приложение
  static ButtonSelf button180({
    required void Function() onPressed,
    required String text,
    isWidth = false,
  }) {
    return ButtonSelf(text: text, onPressed: onPressed, width: 180, height: 50);
  }

  /// широка кнопка 280
  static ButtonSelf button280({
    required void Function() onPressed,
    required String text,
    isWidth = false,
  }) {
    return ButtonSelf(text: text, onPressed: onPressed, width: 280, height: 50);
  }

  /// широка кнопка 220
  static ButtonSelf button220({
    required void Function() onPressed,
    required String text,
    isWidth = false,
  }) {
    return ButtonSelf(text: text, onPressed: onPressed, width: 220, height: 50);
  }

  /// кнопка выхода из профиля
  static ButtonSelf alert({
    required void Function() onPressed,
    required String text,
  }) {
    return ButtonSelf(
      text: text,
      onPressed: onPressed,
      width: 120,
      height: 40,
      isDark: true,
    );
  }

  /// кнопка выбора дальнейшего действия
  static ButtonSelf selfChooseBlue({
    required void Function() onPressed,
    required String text,
    bool isBlue = true,
  }) {
    return ButtonSelf(text: text, onPressed: onPressed, width: 156, height: 71);
  }

  /// кнопка перехода на таблицы
  static ButtonSelf goTable({
    required void Function() onPressed,
    required String text,
    bool isBlue = true,
  }) {
    return ButtonSelf(text: text, onPressed: onPressed, width: 156, height: 71);
  }
}
