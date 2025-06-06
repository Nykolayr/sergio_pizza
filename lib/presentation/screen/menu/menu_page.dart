import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sergio_pizza/presentation/screen/menu/widgets/delivery_address_bar.dart';
import 'package:sergio_pizza/presentation/screen/menu/widgets/banners_carousel.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Строка с адресом доставки
        const DeliveryAddressBar(),
        // Баннеры
        const BannersCarousel(),

        Image.asset('assets/temp/pizza.png'),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/temp/pizza2.png',
                  width: MediaQuery.of(context).size.width - 32,
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
