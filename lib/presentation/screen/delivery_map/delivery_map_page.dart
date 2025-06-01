import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/bloc/delivery_map_bloc.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/button_back.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/delivery_bottom_panel.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/tabs_map.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:sergio_pizza/presentation/theme/theme.dart';

class DeliveryMapPage extends StatefulWidget {
  const DeliveryMapPage({super.key});

  @override
  State<DeliveryMapPage> createState() => _DeliveryMapPageState();
}

class _DeliveryMapPageState extends State<DeliveryMapPage> {
  DeliveryMapBloc bloc = Get.find<DeliveryMapBloc>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DeliveryMapBloc, DeliveryMapState>(
          bloc: bloc,
          builder: (context, state) {
            return Stack(
              children: [
                YandexMap(
                  onMapCreated: (controller) {
                    // Сохраняем контроллер для управления картой
                    bloc.mapController = controller;

                    // Устанавливаем начальную позицию карты
                    controller.moveCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: Point(
                              latitude: 55.9929,
                              longitude: 37.2107), // Зеленоград
                          zoom: 15,
                        ),
                      ),
                    );
                  },
                  mapObjects: state.userLocation != null
                      ? [
                          PlacemarkMapObject(
                            mapId: const MapObjectId('user_location'),
                            point: state.userLocation!,
                            icon: PlacemarkIcon.single(
                              PlacemarkIconStyle(
                                image: BitmapDescriptor.fromAssetImage(
                                    'assets/images/user_marker.png'),
                                scale: 0.5,
                              ),
                            ),
                          ),
                        ]
                      : [],
                  onMapTap: (point) {
                    // Отправляем событие в блок при нажатии на карту
                    bloc.add(MapTapped(
                      latitude: point.latitude,
                      longitude: point.longitude,
                    ));
                  },
                ),
                // Кнопка назад
                Positioned(
                  top: 40,
                  left: 21,
                  child: ButtonBack(
                    onPressed: () {
                      bloc.add(const ClearTempDataOnExit());
                      context.pop();
                    },
                  ),
                ),
                // выбор доставки или самовывоза
                Positioned(
                  top: 92,
                  left: 21,
                  right: 21,
                  child: const TabsMap(),
                ),
                const DeliveryBottomPanel(),
                // Добавляем кнопку геопозиции
                Positioned(
                  top: 40,
                  right: 21,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        bloc.add(const GetCurrentLocation());
                      },
                      icon: Icon(
                        Icons.my_location,
                        color: AppColor.blue,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  @override
  void dispose() {
    // Очищаем временные данные при выходе
    bloc.add(const ClearTempDataOnExit());
    super.dispose();
  }
}
