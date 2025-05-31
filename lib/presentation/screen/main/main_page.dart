import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          mapObjects: [
            // Пример добавления метки на карту
            PlacemarkMapObject(
              mapId: const MapObjectId('placemark'),
              point: Point(latitude: 55.751244, longitude: 37.618423),
              icon: PlacemarkIcon.single(
                PlacemarkIconStyle(
                  image: BitmapDescriptor.fromAssetImage(
                      'assets/svg/pickup_point.svg'),
                  scale: 2,
                ),
              ),
            ),
          ],
        ),
      ],
    ));
  }
}
