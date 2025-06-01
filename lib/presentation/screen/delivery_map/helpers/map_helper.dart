import 'package:flutter/services.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:sergio_pizza/domain/models/delivery_type.dart';
import 'package:sergio_pizza/domain/models/establishment.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/bloc/delivery_map_bloc.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart' as mapkit;

class MapHelper {
  // Статические переменные для кэширования маркеров
  static mapkit.BitmapDescriptor? _cachedMarkerIcon;
  static mapkit.BitmapDescriptor? _cachedCafeBlueIcon;
  static mapkit.BitmapDescriptor? _cachedCafeRedIcon;

  static mapkit.BitmapDescriptor? get customMarkerIcon => _cachedMarkerIcon;
  static mapkit.BitmapDescriptor? get cafeBlueIcon => _cachedCafeBlueIcon;
  static mapkit.BitmapDescriptor? get cafeRedIcon => _cachedCafeRedIcon;

  /// Загружает кастомные маркеры из assets
  static Future<void> loadCustomMarkers() async {
    // Если маркеры уже закэшированы, используем их
    if (_cachedMarkerIcon != null &&
        _cachedCafeBlueIcon != null &&
        _cachedCafeRedIcon != null) {
      return;
    }

    try {
      // Загружаем маркер местоположения
      if (_cachedMarkerIcon == null) {
        final ByteData data =
            await rootBundle.load('assets/images/location_marker.png');
        final Uint8List bytes = data.buffer.asUint8List();
        _cachedMarkerIcon = mapkit.BitmapDescriptor.fromBytes(bytes);
      }

      // Загружаем синий маркер кафе
      if (_cachedCafeBlueIcon == null) {
        final ByteData blueData =
            await rootBundle.load('assets/images/cafe_marker_blue.png');
        final Uint8List blueBytes = blueData.buffer.asUint8List();
        _cachedCafeBlueIcon = mapkit.BitmapDescriptor.fromBytes(blueBytes);
      }

      // Загружаем красный маркер кафе
      if (_cachedCafeRedIcon == null) {
        final ByteData redData =
            await rootBundle.load('assets/images/cafe_marker_red.png');
        final Uint8List redBytes = redData.buffer.asUint8List();
        _cachedCafeRedIcon = mapkit.BitmapDescriptor.fromBytes(redBytes);
      }
    } catch (e) {
      Logger.e('Ошибка загрузки иконок: $e');
    }
  }

  /// Создает маркеры заведений для карты
  static List<mapkit.PlacemarkMapObject> buildEstablishmentMarkers(
      DeliveryMapState state,
      {Function(Establishment)? onEstablishmentTap}) {
    if (state.selectedDeliveryType != DeliveryType.pickup ||
        state.filteredEstablishments.isEmpty ||
        cafeBlueIcon == null ||
        cafeRedIcon == null) {
      return [];
    }

    final markers = state.filteredEstablishments.map((establishment) {
      final isOpen = establishment.isOpen;
      final icon = isOpen ? cafeBlueIcon! : cafeRedIcon!;

      // Проверяем, выделено ли это заведение
      final isSelected = state.selectedEstablishment?.id == establishment.id;
      // Увеличиваем масштаб для выделенного маркера
      final scale = isSelected ? 4.0 : 3.0;

      return mapkit.PlacemarkMapObject(
        mapId: mapkit.MapObjectId('establishment_${establishment.id}'),
        point: establishment.coordinates,
        icon: mapkit.PlacemarkIcon.single(
          mapkit.PlacemarkIconStyle(
            image: icon,
            scale: scale,
          ),
        ),
        opacity: 1.0,
        onTap: (mapObject, point) {
          // Вызываем callback при нажатии на маркер
          onEstablishmentTap?.call(establishment);
        },
      );
    }).toList();

    return markers;
  }

  /// Создает маркер местоположения доставки
  static mapkit.PlacemarkMapObject? buildDeliveryLocationMarker(
      DeliveryMapState state) {
    if (state.selectedLocation == null || customMarkerIcon == null) {
      return null;
    }

    return mapkit.PlacemarkMapObject(
      mapId: const mapkit.MapObjectId('selected_location'),
      point: state.selectedLocation!,
      icon: mapkit.PlacemarkIcon.single(
        mapkit.PlacemarkIconStyle(
          image: customMarkerIcon!,
          scale: 2.0,
        ),
      ),
      opacity: 1.0,
    );
  }

  /// Создает маркер пользователя для самовывоза
  static mapkit.PlacemarkMapObject? buildUserLocationMarker(
      DeliveryMapState state) {
    if (state.userLocation == null || customMarkerIcon == null) {
      return null;
    }

    return mapkit.PlacemarkMapObject(
      mapId: const mapkit.MapObjectId('user_location'),
      point: state.userLocation!,
      icon: mapkit.PlacemarkIcon.single(
        mapkit.PlacemarkIconStyle(
          image: customMarkerIcon!,
          scale: 2.0,
        ),
      ),
      opacity: 1.0,
    );
  }

  /// Создает все маркеры для карты
  static List<mapkit.PlacemarkMapObject> buildAllMarkers(DeliveryMapState state,
      {Function(Establishment)? onEstablishmentTap}) {
    final List<mapkit.PlacemarkMapObject> allMarkers = [];

    // Добавляем маркер местоположения (только для доставки)
    if (state.selectedDeliveryType == DeliveryType.delivery) {
      final deliveryMarker = buildDeliveryLocationMarker(state);
      if (deliveryMarker != null) {
        allMarkers.add(deliveryMarker);
      }
    }

    // Добавляем маркер пользователя (только для самовывоза)
    if (state.selectedDeliveryType == DeliveryType.pickup) {
      final userMarker = buildUserLocationMarker(state);
      if (userMarker != null) {
        allMarkers.add(userMarker);
      }
    }

    // Добавляем маркеры заведений (только для самовывоза)
    final establishmentMarkers = buildEstablishmentMarkers(state,
        onEstablishmentTap: onEstablishmentTap);
    allMarkers.addAll(establishmentMarkers);

    return allMarkers;
  }

  /// Подгоняет камеру под все маркеры
  static void fitCameraToShowAllMarkers(
      DeliveryMapState state, mapkit.YandexMapController? mapController) {
    if (state.selectedDeliveryType != DeliveryType.pickup ||
        state.filteredEstablishments.isEmpty ||
        mapController == null) {
      return;
    }

    final List<mapkit.Point> allPoints = [];

    // Добавляем координаты пользователя
    if (state.userLocation != null) {
      allPoints.add(state.userLocation!);
    }

    // Добавляем координаты всех заведений
    for (final establishment in state.filteredEstablishments) {
      allPoints.add(establishment.coordinates);
    }

    if (allPoints.isEmpty) return;

    // Находим границы
    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLon = allPoints.first.longitude;
    double maxLon = allPoints.first.longitude;

    for (final point in allPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLon) minLon = point.longitude;
      if (point.longitude > maxLon) maxLon = point.longitude;
    }

    // Увеличиваем отступы чтобы все маркеры были видны
    const double padding = 0.02; // Увеличиваем отступ до 2 км
    minLat -= padding;
    maxLat += padding;
    minLon -= padding;
    maxLon += padding;

    // Подгоняем камеру с анимацией
    mapController.moveCamera(
      mapkit.CameraUpdate.newGeometry(
        mapkit.Geometry.fromBoundingBox(
          mapkit.BoundingBox(
            southWest: mapkit.Point(latitude: minLat, longitude: minLon),
            northEast: mapkit.Point(latitude: maxLat, longitude: maxLon),
          ),
        ),
      ),
      animation: const mapkit.MapAnimation(
        type: mapkit.MapAnimationType.smooth,
        duration: 1.0,
      ),
    );
  }

  /// Устанавливает начальную позицию камеры на Зеленоград
  static void setInitialCameraPosition(mapkit.YandexMapController controller) {
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
  }
}
