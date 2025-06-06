import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class MenuAppBar extends StatelessWidget {
  const MenuAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Иконка поиска слева
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/svg/search.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColor.greyIcon,
                BlendMode.srcIn,
              ),
            ),
          ),
          // Логотип по центру
          Expanded(
            child: Center(
              child: SvgPicture.asset(
                'assets/svg/logo_line.svg',
                height: 40,
              ),
            ),
          ),
          // Иконка сканирования справа
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/svg/scan.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColor.greyIcon,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
