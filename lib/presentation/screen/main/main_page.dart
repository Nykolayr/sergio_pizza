import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/models/delivery_type.dart';
import 'package:sergio_pizza/domain/repository/user_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/bloc/delivery_map_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final userRepository = Get.find<UserRepository>();

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Переход на смену адреса
            context.goNamed('карта доставки');
          },
          child: Row(
            children: [
              const Icon(Icons.location_on),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getDisplayAddress(userRepository),
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [],
      ),
    );
  }

  String _getDisplayAddress(UserRepository userRepository) {
    DeliveryMapBloc bloc = Get.find<DeliveryMapBloc>();
    DeliveryMapState state = bloc.state;
    if (state.user.deliveryType == DeliveryType.delivery) {
      return '${state.user.deliveryAddress.city}, ${state.user.deliveryAddress.address}';
    } else if (state.user.deliveryType == DeliveryType.pickup) {
      return state.user.pickupAddress.address;
    } else {
      return 'Выберите адрес доставки';
    }
  }
}
