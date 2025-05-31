import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/repository/user_repository.dart';
import 'package:go_router/go_router.dart';

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
            context.push('/main/delivery');
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
        children: [
          YandexMap(
            onMapCreated: (controller) {
              controller.moveCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: Point(latitude: 55.751244, longitude: 37.618423),
                    zoom: 15,
                  ),
                ),
              );
            },
            mapObjects: const [], // Пустой список - никаких маркеров
          ),
        ],
      ),
    );
  }

  String _getDisplayAddress(UserRepository userRepository) {
    if (userRepository.hasDeliveryAddress) {
      return userRepository.user.deliveryAddress.address;
    } else if (userRepository.hasPickupAddress) {
      return userRepository.user.pickupAddress.address;
    } else {
      return 'Выберите адрес доставки';
    }
  }
}
