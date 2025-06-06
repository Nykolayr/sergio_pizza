import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:sergio_pizza/presentation/screen/main/enum_main_page.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class NavigationButtons extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const NavigationButtons({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 0; i < MainPages.values.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onItemTapped(i),
                  child: SizedBox(
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          MainPages.values[i].icon,
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            selectedIndex == i
                                ? AppColor.blueDark
                                : AppColor.greyIcon,
                            BlendMode.srcIn,
                          ),
                        ),
                        const Gap(7),
                        Text(
                          MainPages.values[i].title,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: selectedIndex == i
                                ? AppColor.blueDark
                                : AppColor.greyIcon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
