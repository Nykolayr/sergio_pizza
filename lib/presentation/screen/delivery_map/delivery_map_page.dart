import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sergio_pizza/domain/models/delivery_type.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/bloc/delivery_map_bloc.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/button_back.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/delivery_bottom_panel.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/tabs_map.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart' as mapkit;
import 'package:sergio_pizza/presentation/theme/theme.dart';

class DeliveryMapPage extends StatefulWidget {
  const DeliveryMapPage({super.key});

  @override
  State<DeliveryMapPage> createState() => _DeliveryMapPageState();
}

class _DeliveryMapPageState extends State<DeliveryMapPage> {
  DeliveryMapBloc bloc = Get.find<DeliveryMapBloc>();

  // Статическая переменная для кэширования маркера
  static mapkit.BitmapDescriptor? _cachedMarkerIcon;

  mapkit.BitmapDescriptor? get customMarkerIcon => _cachedMarkerIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
  }

  Future<void> _loadCustomMarker() async {
    // Если маркер уже закэширован, используем его
    if (_cachedMarkerIcon != null) {
      Logger.i('Используется закэшированная иконка маркера');
      setState(() {});
      return;
    }

    try {
      final ByteData data =
          await rootBundle.load('assets/images/location_marker.png');
      final Uint8List bytes = data.buffer.asUint8List();
      _cachedMarkerIcon = mapkit.BitmapDescriptor.fromBytes(bytes);
      Logger.i('Иконка маркера загружена и закэширована');

      if (bloc.state.selectedLocation != null) {
        bloc.add(MapTapped(
          latitude: bloc.state.selectedLocation!.latitude,
          longitude: bloc.state.selectedLocation!.longitude,
        ));
      }

      setState(() {});
    } catch (e) {
      Logger.e('Ошибка загрузки иконки: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocBuilder<DeliveryMapBloc, DeliveryMapState>(
          bloc: bloc,
          builder: (context, state) {
            final shouldShowMarker =
                state.selectedLocation != null && customMarkerIcon != null;

            return Stack(
              children: [
                mapkit.YandexMap(
                  mapType: mapkit.MapType.vector,
                  onMapCreated: (controller) async {
                    bloc.mapController = controller;

                    // Устанавливаем начальную позицию на Зеленоград
                    controller.moveCamera(
                      mapkit.CameraUpdate.newCameraPosition(
                        mapkit.CameraPosition(
                          target: const mapkit.Point(
                            latitude: 55.994849, // Координаты Зеленограда
                            longitude: 37.214121,
                          ),
                          zoom: 13, // Зум на уровне города
                        ),
                      ),
                    );

                    bloc.add(const InitializeMap());
                  },
                  mapObjects: shouldShowMarker
                      ? [
                          mapkit.PlacemarkMapObject(
                            mapId:
                                const mapkit.MapObjectId('selected_location'),
                            point: state.selectedLocation!,
                            icon: mapkit.PlacemarkIcon.single(
                              mapkit.PlacemarkIconStyle(
                                image: customMarkerIcon!,
                                scale: 1.6,
                              ),
                            ),
                            opacity: 1.0,
                          ),
                        ]
                      : [],
                  onMapTap: (point) {
                    // Обрабатываем тап только в режиме доставки
                    if (state.selectedDeliveryType == DeliveryType.delivery) {
                      // Отправляем координаты тапа для поиска ближайшего адреса
                      bloc.add(MapTapped(
                        latitude: point.latitude,
                        longitude: point.longitude,
                      ));
                    }
                    // В режиме самовывоза тапы игнорируем
                  },
                ),
                Positioned(
                  top: 40,
                  left: 21,
                  child: ButtonOnMap(
                    onPressed: () {
                      bloc.add(const ClearTempDataOnExit());
                      context.pop();
                    },
                  ),
                ),
                Positioned(
                  top: 92,
                  left: 21,
                  right: 21,
                  child: const TabsMap(),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height / 2 - 50,
                  right: 21,
                  child: ButtonOnMap(
                    onPressed: () {
                      bloc.add(const GetCurrentLocation());
                    },
                    icon: Icons.navigation,
                    color: AppColor.yellowLight,
                    angle: 4,
                  ),
                ),
                const DeliveryBottomPanel(),
                if (state.isLoading)
                  Positioned(
                    top: MediaQuery.of(context).size.height / 2 - 200,
                    left: 0,
                    right: 0,
                    child: AppLoader(),
                  ),
              ],
            );
          }),
    );
  }

  @override
  void dispose() {
    bloc.add(const ClearTempDataOnExit());
    super.dispose();
  }
}
