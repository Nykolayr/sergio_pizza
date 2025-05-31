import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:sergio_pizza/domain/repository/user_repository.dart';
import 'package:sergio_pizza/domain/models/delivery_address.dart';

class DeliveryMapPage extends StatefulWidget {
  const DeliveryMapPage({super.key});

  @override
  State<DeliveryMapPage> createState() => _DeliveryMapPageState();
}

class _DeliveryMapPageState extends State<DeliveryMapPage> {
  String selectedAddress = '';
  Point? selectedCoordinates;
  final userRepository = Get.find<UserRepository>();

  @override
  Widget build(BuildContext context) {
    // Проверяем, есть ли уже сохраненный адрес (для случая смены адреса)
    final hasExistingAddress = userRepository.hasAnyAddress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор адреса доставки'),
        leading: hasExistingAddress
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(), // Возвращаемся на главную
              )
            : null,
        automaticallyImplyLeading: hasExistingAddress,
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
            mapObjects: const [],
            onMapTap: (point) {
              setState(() {
                selectedAddress = 'Зеленоград, ул. Примерная, д. 1';
                selectedCoordinates = point;
              });
            },
          ),

          // Нижняя панель
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedAddress.isNotEmpty) ...[
                    Text(
                      'Ваш адрес:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedAddress,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedAddress.isNotEmpty &&
                              selectedCoordinates != null
                          ? () async {
                              // Создаем объект адреса доставки
                              final deliveryAddress = DeliveryAddress(
                                address: selectedAddress,
                                apartment: '',
                                entrance: '',
                                floor: '',
                                intercom: '',
                                comment: '',
                                coordinates: selectedCoordinates!,
                              );

                              // Сохраняем адрес
                              await userRepository
                                  .setDeliveryAddress(deliveryAddress);

                              if (hasExistingAddress) {
                                context.pop();
                              } else {
                                context.go('/main');
                              }
                            }
                          : null,
                      child: const Text('Доставить сюда'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
