import 'package:sergio_pizza/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// большая кнопка

class ButtonWide extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String iconPath;
  final bool isNext;
  final bool isEnable;
  const ButtonWide({
    required this.text,
    required this.onPressed,
    this.isNext = false,
    this.iconPath = '',
    this.isEnable = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColor.black.withAlpha(20),
              border: Border.all(color: AppColor.black, width: 2),
              borderRadius: AppDif.borderRadius10,
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconPath.isNotEmpty) SvgPicture.asset(iconPath, width: 20),
                if (iconPath.isNotEmpty) const Gap(10),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: AppText.text14sb.copyWith(color: AppColor.whitefon),
                  overflow: TextOverflow.ellipsis,
                ),
                if (isNext) const Gap(5),
                if (isNext)
                  const Flexible(
                    child: Icon(
                      Icons.chevron_right,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ],
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
    colorButton ??=
        isDark
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
