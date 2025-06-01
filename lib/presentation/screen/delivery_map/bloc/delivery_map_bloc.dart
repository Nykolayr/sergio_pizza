import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/models/delivery_address.dart';
import 'package:sergio_pizza/domain/models/user.dart';
import 'package:sergio_pizza/domain/repository/user_repository.dart';
import 'package:sergio_pizza/domain/models/delivery_type.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart' as mapkit;
import 'package:yandex_geocoder/yandex_geocoder.dart';
import 'package:sergio_pizza/main.dart'; // Для доступа к isMock
import 'package:sergio_pizza/data/geolocation_servise.dart'; // Для геопозиции
import 'package:flutter_easylogger/flutter_logger.dart'; // Добавляем импорт

part 'delivery_map_event.dart';
part 'delivery_map_state.dart';

class DeliveryMapBloc extends Bloc<DeliveryMapEvent, DeliveryMapState> {
  final UserRepository userRepository = Get.find<UserRepository>();

  // Добавляем контроллер карты
  mapkit.YandexMapController? mapController;

  // Новые координаты для тестирования
  static const double mockLatitude = 55.994849;
  static const double mockLongitude = 37.214121;

  // Город определенный при первом запуске
  String? detectedCity;

  DeliveryMapBloc() : super(DeliveryMapState.initial()) {
    // НЕ устанавливаем город заранее - будем определять из геопозиции

    on<SetErrorEvent>(_onSetError);
    on<SelectDeliveryType>(_onSelectDeliveryType);
    on<MapTapped>(_onMapTapped);
    on<UpdateDeliveryAddress>(_onUpdateDeliveryAddress);
    on<SaveDeliveryAddress>(_onSaveDeliveryAddress);
    on<ClearDeliveryAddress>(_onClearDeliveryAddress);
    on<ClearTempDataOnExit>(_onClearTempDataOnExit);
    on<GetCurrentLocation>(_onGetCurrentLocation);
    on<InitializeMap>(_onInitializeMap);
    on<ExpandDeliveryPanel>(_onExpandDeliveryPanel);

    // Инициализируем карту при создании блока
    add(const InitializeMap());
  }

  /// установка ошибки
  void _onSetError(SetErrorEvent event, Emitter<DeliveryMapState> emit) {
    emit(state.copyWith(error: event.error));
  }

  /// выбор типа доставки
  void _onSelectDeliveryType(
      SelectDeliveryType event, Emitter<DeliveryMapState> emit) async {
    // Обновляем тип доставки в UserRepository
    await userRepository.setDeliveryType(event.deliveryType);

    // Обновляем состояние с новым пользователем
    emit(state.copyWith(user: userRepository.user));
  }

  /// событие нажатия на карту
  void _onMapTapped(MapTapped event, Emitter<DeliveryMapState> emit) async {
    try {
      // Создаем Point из yandex_mapkit с координатами
      final coordinates =
          mapkit.Point(latitude: event.latitude, longitude: event.longitude);

      // Используем yandex_geocoder для получения адреса по координатам
      final geocoder =
          YandexGeocoder(apiKey: '583ffca0-799b-43a5-aebd-9d7106689dc0');

      final geocodeResult = await geocoder.getGeocode(
        ReverseGeocodeRequest(
          pointGeocode: (lat: event.latitude, lon: event.longitude),
          lang: Lang.ru,
        ),
      );

      String fullAddress = 'Адрес не найден';
      if (geocodeResult
              .response?.geoObjectCollection?.featureMember?.isNotEmpty ==
          true) {
        final geoObject = geocodeResult
            .response!.geoObjectCollection!.featureMember!.first.geoObject;
        fullAddress = geoObject?.metaDataProperty?.geocoderMetaData?.text ??
            'Адрес не найден';
      }

      // ЛОГИРУЕМ ЧТО ВОЗВРАЩАЕТ ГЕОКОДЕР ПРИ ТАПЕ
      Logger.i('👆 Тап по карте - полный адрес: $fullAddress');
      Logger.i('👆 Координаты тапа: ${event.latitude}, ${event.longitude}');

      // Парсим адрес для извлечения города и адреса
      final parsedAddress = _parseAddress(fullAddress);

      Logger.i('👆 Парсинг тапа:');
      Logger.i('🏙️ Город: ${parsedAddress['city']}');
      Logger.i('🏠 Адрес: ${parsedAddress['address']}');

      // ИЗМЕНЕНИЕ: Обновляем detectedAddress, а НЕ tempDeliveryAddress
      final detectedAddress = DeliveryAddress(
        address: parsedAddress['address'] ?? '',
        city: parsedAddress['city'] ?? detectedCity ?? 'Зеленоград',
        apartment: '',
        entrance: '',
        floor: '',
        intercom: '',
        comment: '',
        coordinates: coordinates,
      );

      // Обновляем detectedAddress - панель остается свернутой
      emit(state.copyWith(detectedAddress: detectedAddress));
    } catch (e) {
      Logger.e('❌ Ошибка геокодирования при тапе: $e');

      // В случае ошибки обновляем detectedAddress с координатами
      final coordinates =
          mapkit.Point(latitude: event.latitude, longitude: event.longitude);

      final detectedAddress = DeliveryAddress(
        address:
            'Широта: ${event.latitude.toStringAsFixed(6)}, Долгота: ${event.longitude.toStringAsFixed(6)}',
        city: detectedCity ?? 'Зеленоград',
        apartment: '',
        entrance: '',
        floor: '',
        intercom: '',
        comment: '',
        coordinates: coordinates,
      );

      emit(state.copyWith(detectedAddress: detectedAddress));
    }
  }

  void _onUpdateDeliveryAddress(
      UpdateDeliveryAddress event, Emitter<DeliveryMapState> emit) {
    // Обновляем временный адрес
    emit(state.copyWith(tempDeliveryAddress: () => event.address));
  }

  void _onSaveDeliveryAddress(
      SaveDeliveryAddress event, Emitter<DeliveryMapState> emit) async {
    // Сохраняем адрес в пользователя только при нажатии кнопки
    if (state.tempDeliveryAddress != null &&
        state.tempDeliveryAddress!.address.isNotEmpty &&
        state.tempDeliveryAddress!.coordinates != null) {
      await userRepository.setDeliveryAddress(state.tempDeliveryAddress!);

      // Обновляем состояние с сохраненным пользователем и очищаем временный адрес
      emit(state.copyWith(
        user: userRepository.user,
        tempDeliveryAddress: () => null,
      ));
    }
  }

  /// событие очистки адреса доставки
  void _onClearDeliveryAddress(
      ClearDeliveryAddress event, Emitter<DeliveryMapState> emit) {
    // Очищаем временный адрес - панель должна свернуться
    emit(state.copyWith(tempDeliveryAddress: () => null));
  }

  /// событие очистки временных данных при выходе
  void _onClearTempDataOnExit(
      ClearTempDataOnExit event, Emitter<DeliveryMapState> emit) {
    // Очищаем временные данные при выходе со страницы
    emit(state.copyWith(tempDeliveryAddress: () => null));
  }

  /// событие получения текущей локации
  void _onGetCurrentLocation(
      GetCurrentLocation event, Emitter<DeliveryMapState> emit) async {
    try {
      double latitude, longitude;

      if (isMock) {
        // Используем моковые координаты Зеленограда
        latitude = mockLatitude;
        longitude = mockLongitude;
      } else {
        // Получаем реальную геопозицию
        final position = await GeolocationService.instance.getCurrentPosition();
        latitude = position.latitude;
        longitude = position.longitude;
      }

      final userLocation =
          mapkit.Point(latitude: latitude, longitude: longitude);

      // Определяем адрес по координатам
      await _detectAddressByLocation(latitude, longitude, emit);

      // Обновляем позицию пользователя
      emit(state.copyWith(userLocation: userLocation));

      // Центрируем карту по новой позиции
      if (mapController != null) {
        await mapController!.moveCamera(
          mapkit.CameraUpdate.newCameraPosition(
            mapkit.CameraPosition(
              target: userLocation,
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      // В случае ошибки используем моковые координаты
      final userLocation =
          mapkit.Point(latitude: mockLatitude, longitude: mockLongitude);

      // Определяем адрес по моковым координатам
      await _detectAddressByLocation(mockLatitude, mockLongitude, emit);

      emit(state.copyWith(userLocation: userLocation));

      if (mapController != null) {
        await mapController!.moveCamera(
          mapkit.CameraUpdate.newCameraPosition(
            mapkit.CameraPosition(
              target: userLocation,
              zoom: 15,
            ),
          ),
        );
      }
    }
  }

  /// событие инициализации карты
  void _onInitializeMap(
      InitializeMap event, Emitter<DeliveryMapState> emit) async {
    // При первом запуске определяем геопозицию, но НЕ разворачиваем панель
    add(const GetCurrentLocation());
  }

  // Исправляем _detectAddressByLocation - НЕ создаем tempDeliveryAddress
  Future<void> _detectAddressByLocation(
      double latitude, double longitude, Emitter<DeliveryMapState> emit) async {
    try {
      final geocoder =
          YandexGeocoder(apiKey: '583ffca0-799b-43a5-aebd-9d7106689dc0');

      final geocodeResult = await geocoder.getGeocode(
        ReverseGeocodeRequest(
          pointGeocode: (lat: latitude, lon: longitude),
          lang: Lang.ru,
        ),
      );

      if (geocodeResult
              .response?.geoObjectCollection?.featureMember?.isNotEmpty ==
          true) {
        final geoObject = geocodeResult
            .response!.geoObjectCollection!.featureMember!.first.geoObject;

        final fullAddress =
            geoObject?.metaDataProperty?.geocoderMetaData?.text ?? '';

        // ЛОГИРУЕМ ЧТО ВОЗВРАЩАЕТ ГЕОКОДЕР
        Logger.i('🗺️ Полный адрес от геокодера: $fullAddress');
        Logger.i('🗺️ Координаты: $latitude, $longitude');

        // Парсим адрес для извлечения города и адреса
        final parsedAddress = _parseAddress(fullAddress);

        Logger.i('🗺️ Парсинг результат:');
        Logger.i('🏙️ Город: ${parsedAddress['city']}');
        Logger.i('🏠 Адрес: ${parsedAddress['address']}');

        // Сохраняем определенный город
        if (detectedCity == null) {
          detectedCity = parsedAddress['city'];
        }

        // Создаем адрес для отображения
        final detectedAddress = DeliveryAddress(
          address: parsedAddress['address'] ?? '',
          city: parsedAddress['city'] ?? 'Зеленоград',
          apartment: '',
          entrance: '',
          floor: '',
          intercom: '',
          comment: '',
          coordinates: mapkit.Point(latitude: latitude, longitude: longitude),
        );

        // Обновляем состояние с определенным адресом
        emit(state.copyWith(detectedAddress: detectedAddress));
      }
    } catch (e) {
      Logger.e('❌ Ошибка геокодирования: $e');

      // В случае ошибки создаем адрес с координатами
      final detectedAddress = DeliveryAddress(
        address:
            'Координаты: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
        city: detectedCity ?? 'Зеленоград',
        apartment: '',
        entrance: '',
        floor: '',
        intercom: '',
        comment: '',
        coordinates: mapkit.Point(latitude: latitude, longitude: longitude),
      );

      emit(state.copyWith(detectedAddress: detectedAddress));
    }
  }

  // Метод для парсинга адреса
  Map<String, String> _parseAddress(String fullAddress) {
    // Пример: "Россия, Москва, Зеленоград, 4-й микрорайон, корпус 414"
    final parts = fullAddress.split(', ');

    String city = 'Зеленоград'; // По умолчанию
    String address = '';

    if (parts.length >= 2) {
      // Ищем город в адресе
      int cityIndex = -1;

      // Сначала ищем конкретные города
      for (int i = 0; i < parts.length; i++) {
        final part = parts[i].toLowerCase();
        if (part.contains('зеленоград') ||
            part.contains('химки') ||
            part.contains('солнечногорск') ||
            part.contains('клин') ||
            part.contains('истра')) {
          city = parts[i];
          cityIndex = i;
          break;
        }
      }

      // Если не нашли конкретный город, но есть Москва
      if (cityIndex == -1) {
        for (int i = 0; i < parts.length; i++) {
          if (parts[i].toLowerCase().contains('москва')) {
            // Проверяем, есть ли после Москвы другой город
            if (i + 1 < parts.length) {
              final nextPart = parts[i + 1].toLowerCase();
              if (nextPart.contains('зеленоград')) {
                city = 'Зеленоград';
                cityIndex = i + 1;
                break;
              }
            }
            // Если нет, то это просто Москва
            city = 'Москва';
            cityIndex = i;
            break;
          }
        }
      }

      // Формируем адрес - все что после города
      if (cityIndex != -1 && cityIndex + 1 < parts.length) {
        address = parts.sublist(cityIndex + 1).join(', ');
      } else if (parts.length > 1) {
        // Если город не найден, берем все кроме первой части (страна)
        address = parts.sublist(1).join(', ');
      }
    }

    // Очищаем адрес от дублирования города
    address = _cleanAddressFromCity(address, city);

    return {
      'city': city,
      'address': address,
    };
  }

  // Обновленный метод для очистки адреса от города
  String _cleanAddressFromCity(String address, String city) {
    // Убираем упоминания текущего города из адреса
    String cleanAddress = address
        .replaceAll(
            RegExp(r'г\.\s*' + RegExp.escape(city) + r',?\s*',
                caseSensitive: false),
            '')
        .replaceAll(
            RegExp(RegExp.escape(city) + r',?\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'г\.\s*Москва,?\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'Москва,?\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'Россия,?\s*', caseSensitive: false), '');

    // Убираем лишние запятые и пробелы в начале
    cleanAddress = cleanAddress.replaceAll(RegExp(r'^,\s*'), '').trim();

    return cleanAddress;
  }

  /// событие разворачивания панели доставки
  void _onExpandDeliveryPanel(
      ExpandDeliveryPanel event, Emitter<DeliveryMapState> emit) {
    // Берем detectedAddress и делаем его tempDeliveryAddress для редактирования
    if (state.detectedAddress != null) {
      emit(state.copyWith(
        tempDeliveryAddress: () => state.detectedAddress,
      ));
    }
  }
}
