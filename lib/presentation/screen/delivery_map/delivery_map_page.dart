import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/bloc/delivery_map_bloc.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/button_back.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/tabs_map.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

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
                    controller.moveCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target:
                              Point(latitude: 55.751244, longitude: 37.618423),
                          zoom: 15,
                        ),
                      ),
                    );
                  },
                  mapObjects: const [],
                  onMapTap: (point) {
                    setState(() {});
                  },
                ),
                // Кнопка назад
                Positioned(
                  top: 40,
                  left: 21,
                  child: const ButtonBack(),
                ),
                // выбор доставки или самовывоза
                Positioned(
                  top: 92,
                  left: 21,
                  right: 21,
                  child: const TabsMap(),
                ),
              ],
            );
          }),
    );
  }
}
