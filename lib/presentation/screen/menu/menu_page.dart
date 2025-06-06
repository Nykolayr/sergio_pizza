import 'package:flutter/material.dart';
import 'package:sergio_pizza/presentation/screen/menu/widgets/delivery_address_bar.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Строка с адресом доставки
        const DeliveryAddressBar(),
        // Остальной контент страницы
        const Expanded(
          child: Center(
            child: Text('Menu'),
          ),
        ),
      ],
    );
  }
}
