import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sergio_pizza/domain/models/delivery_type.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/bloc/delivery_map_bloc.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/helpers/map_helper.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/button_back.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/delivery_bottom_panel.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/establishment_info_panel.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/tabs_map.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart' as mapkit;
import 'package:sergio_pizza/presentation/theme/theme.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/widgets/pickup_bottom_panel.dart';

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
    _loadCustomMarkers();
  }

  Future<void> _loadCustomMarkers() async {
    await MapHelper.loadCustomMarkers();

    if (bloc.state.selectedLocation != null) {
      bloc.add(MapTapped(
        latitude: bloc.state.selectedLocation!.latitude,
        longitude: bloc.state.selectedLocation!.longitude,
      ));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocBuilder<DeliveryMapBloc, DeliveryMapState>(
          bloc: bloc,
          builder: (context, state) {
            // Создаем все маркеры через MapHelper
            final allMarkers = MapHelper.buildAllMarkers(
              state,
              onEstablishmentTap: (establishment) {
                // Отправляем событие выбора заведения в блок
                bloc.add(SelectEstablishment(establishment));
              },
            );

            // Подгоняем камеру при переключении на самовывоз
            if (state.selectedDeliveryType == DeliveryType.pickup &&
                state.filteredEstablishments.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                MapHelper.fitCameraToShowAllMarkers(state, bloc.mapController);
              });
            }

            return Stack(
              children: [
                mapkit.YandexMap(
                  mapType: mapkit.MapType.vector,
                  onMapCreated: (controller) async {
                    bloc.mapController = controller;

                    // Устанавливаем начальную позицию через MapHelper
                    MapHelper.setInitialCameraPosition(controller);

                    bloc.add(const InitializeMap());
                  },
                  mapObjects: allMarkers,
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
                state.selectedDeliveryType == DeliveryType.delivery
                    ? const DeliveryBottomPanel()
                    : state.selectedEstablishment != null
                        ? EstablishmentInfoPanel(
                            establishment: state.selectedEstablishment!)
                        : const PickupBottomPanel(),
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
