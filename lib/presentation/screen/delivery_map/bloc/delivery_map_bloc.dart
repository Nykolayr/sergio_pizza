import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/models/delivery_address.dart';
import 'package:sergio_pizza/domain/models/establishment_type.dart';
import 'package:sergio_pizza/domain/models/user.dart';
import 'package:sergio_pizza/domain/repository/user_repository.dart';
import 'package:sergio_pizza/domain/models/delivery_type.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart' as mapkit;
import 'package:yandex_geocoder/yandex_geocoder.dart';
import 'package:sergio_pizza/main.dart'; // Для доступа к isMock
import 'package:sergio_pizza/data/geolocation_servise.dart'; // Для геопозиции
import 'package:flutter_easylogger/flutter_logger.dart'; // Добавляем импорт
import 'package:sergio_pizza/domain/models/establishment.dart';
import 'package:sergio_pizza/domain/repository/main_repository.dart';

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
    on<DeliverHerePressed>(_onDeliverHerePressed);
    on<ClosePanelEvent>(_onClosePanel);
    on<UpdateUserLocationSilently>(_onUpdateUserLocationSilently);
    on<LoadEstablishments>(_onLoadEstablishments);
    on<SelectEstablishment>(_onSelectEstablishment);
  }

  /// загрузка заведений
  void _onLoadEstablishments(
      LoadEstablishments event, Emitter<DeliveryMapState> emit) async {
    try {
      final mainRepo = Get.find<MainRepository>();
      final result = await mainRepo.loadEstablishments();

      if (result.isEmpty) {
        // Успешная загрузка
        Logger.i('Загружено заведений: ${mainRepo.establishments.length}');
        emit(state.copyWith(
          filteredEstablishments: mainRepo.establishments,
          error: '',
        ));
      } else {
        // Ошибка загрузки
        emit(state.copyWith(
          error: result,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: 'Ошибка загрузки заведений: $e',
        filteredEstablishments: [],
      ));
    }
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

    // Обновляем состояние с новым типом
    emit(state.copyWith(
      user: userRepository.user,
      selectedDeliveryType: event.deliveryType,
    ));

    // Переключаем маркер в зависимости от типа
    if (event.deliveryType == DeliveryType.pickup) {
      // При переходе на самовывоз - СРАЗУ показываем старую геолокацию
      if (state.userLocation != null) {
        emit(state.copyWith(selectedLocation: state.userLocation));

        // Сразу перемещаем камеру к старой геолокации
        mapController?.moveCamera(
          mapkit.CameraUpdate.newCameraPosition(
            mapkit.CameraPosition(
              target: state.userLocation!,
              zoom: 15,
            ),
          ),
        );
      }

      // Потом тихо обновляем геолокацию в фоне БЕЗ emit
      _updateGeolocationSilentlyWithoutEmit();
    } else {
      // При переходе на доставку - показываем сохраненный адрес
      final savedAddress = userRepository.user.deliveryAddress;
      if (savedAddress.coordinates != null) {
        emit(state.copyWith(
          selectedLocation: savedAddress.coordinates,
          tempDeliveryAddress: () => savedAddress,
        ));

        // Перемещаем камеру к сохраненному адресу
        mapController?.moveCamera(
          mapkit.CameraUpdate.newCameraPosition(
            mapkit.CameraPosition(
              target: savedAddress.coordinates!,
              zoom: 15,
            ),
          ),
        );
      }
    }
  }

  /// Обработка нажатия на карту
  Future<void> _onMapTapped(
      MapTapped event, Emitter<DeliveryMapState> emit) async {
    try {
      // Включаем загрузку для геокодинга
      emit(state.copyWith(isLoading: true));

      Logger.i('🗺️ Тап по карте: ${event.latitude}, ${event.longitude}');

      final geocoder =
          YandexGeocoder(apiKey: '583ffca0-799b-43a5-aebd-9d7106689dc0');

      final geocoderResult = await geocoder
          .getGeocode(
        ReverseGeocodeRequest(
          pointGeocode: (lat: event.latitude, lon: event.longitude),
          lang: Lang.ru,
        ),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          Logger.e('⏰ Таймаут геокодера');
          throw Exception('Таймаут геокодера');
        },
      );

      if (geocoderResult
              .response?.geoObjectCollection?.featureMember?.isNotEmpty ==
          true) {
        final geoObject = geocoderResult
            .response!.geoObjectCollection!.featureMember!.first.geoObject!;
        final fullAddress =
            geoObject.metaDataProperty?.geocoderMetaData?.text ?? '';

        final point = geoObject.point;
        if (point != null &&
            point.latitude != null &&
            point.longitude != null) {
          final exactLatitude = point.latitude!;
          final exactLongitude = point.longitude!;

          Logger.i('🎯 Найден точный адрес: $fullAddress');
          Logger.i('📍 Точные координаты: $exactLatitude, $exactLongitude');

          final exactLocation = mapkit.Point(
            latitude: exactLatitude,
            longitude: exactLongitude,
          );

          final parsedAddress = _parseAddress(fullAddress);
          final city = parsedAddress['city'] ?? detectedCity ?? 'Зеленоград';
          final address = parsedAddress['address'] ?? fullAddress;

          // СОЗДАЕМ/ОБНОВЛЯЕМ tempDeliveryAddress с новым адресом
          // Сохраняем существующие поля (квартира, подъезд и т.д.)
          final updatedTempAddress = DeliveryAddress(
            address: address, // НОВЫЙ адрес
            city: city, // НОВЫЙ город
            apartment: state.tempDeliveryAddress?.apartment ?? '', // Сохраняем
            entrance: state.tempDeliveryAddress?.entrance ?? '', // Сохраняем
            floor: state.tempDeliveryAddress?.floor ?? '', // Сохраняем
            intercom: state.tempDeliveryAddress?.intercom ?? '', // Сохраняем
            comment: state.tempDeliveryAddress?.comment ?? '', // Сохраняем
            coordinates: exactLocation, // НОВЫЕ координаты
          );

          emit(state.copyWith(
            selectedLocation: exactLocation,
            tempDeliveryAddress: () => updatedTempAddress, // Обновляем temp
            detectedAddress: updatedTempAddress, // Обновляем detected
            isLoading: false,
          ));

          // Перемещаем камеру
          mapController?.moveCamera(
            mapkit.CameraUpdate.newCameraPosition(
              mapkit.CameraPosition(
                target: exactLocation,
                zoom: 16,
              ),
            ),
          );

          Logger.i('✅ tempDeliveryAddress обновлен новым адресом');
        }
      } else {
        Logger.e('❌ Адрес не найден по координатам тапа');
        final fallbackLocation = mapkit.Point(
          latitude: event.latitude,
          longitude: event.longitude,
        );

        emit(state.copyWith(
          selectedLocation: fallbackLocation,
          isLoading: false,
        ));
      }
    } catch (e) {
      Logger.e('❌ Ошибка при обработке тапа по карте: $e');
      final fallbackLocation = mapkit.Point(
        latitude: event.latitude,
        longitude: event.longitude,
      );

      emit(state.copyWith(
        selectedLocation: fallbackLocation,
        isLoading: false,
      ));
    }
  }

  /// событие обновления адреса доставки
  void _onUpdateDeliveryAddress(
      UpdateDeliveryAddress event, Emitter<DeliveryMapState> emit) {
    // ОПТИМИЗАЦИЯ: Проверяем что адрес действительно изменился
    if (state.tempDeliveryAddress != event.address) {
      emit(state.copyWith(tempDeliveryAddress: () => event.address));
    }
  }

  /// событие сохранения адреса доставки
  void _onSaveDeliveryAddress(
      SaveDeliveryAddress event, Emitter<DeliveryMapState> emit) async {
    Logger.i('💾 Сохранение адреса доставки');

    // Сохраняем tempDeliveryAddress в пользователя
    if (state.tempDeliveryAddress != null &&
        state.tempDeliveryAddress!.address.isNotEmpty) {
      // Убеждаемся что город не пустой
      final addressToSave = state.tempDeliveryAddress!.copyWith(
        city: state.tempDeliveryAddress!.city.isEmpty
            ? (detectedCity ?? 'Зеленоград')
            : state.tempDeliveryAddress!.city,
      );

      await userRepository.setDeliveryAddress(addressToSave);

      // Обновляем состояние с сохраненным пользователем
      emit(state.copyWith(
        user: userRepository.user,
        tempDeliveryAddress: () => null, // Очищаем временный адрес
        detectedAddress: addressToSave, // Обновляем detectedAddress
        isPanelExpanded: false, // Сворачиваем панель
      ));
    }
  }

  /// закрывает панель доставки
  void _onClearDeliveryAddress(
      ClearDeliveryAddress event, Emitter<DeliveryMapState> emit) {
    emit(state.copyWith(isPanelExpanded: false));
  }

  /// событие очистки временных данных при выходе
  void _onClearTempDataOnExit(
      ClearTempDataOnExit event, Emitter<DeliveryMapState> emit) {
    // ИСПРАВЛЕНИЕ: Только очищаем временные данные, город остается
    emit(state.copyWith(tempDeliveryAddress: () => null));
  }

  /// событие получения текущей геопозиции (кнопка геолокации)
  void _onGetCurrentLocation(
      GetCurrentLocation event, Emitter<DeliveryMapState> emit) async {
    // СРАЗУ переходим к старой геолокации если есть
    if (state.userLocation != null) {
      emit(state.copyWith(selectedLocation: state.userLocation));

      // Сразу перемещаем камеру
      mapController?.moveCamera(
        mapkit.CameraUpdate.newCameraPosition(
          mapkit.CameraPosition(
            target: state.userLocation!,
            zoom: 15,
          ),
        ),
      );
    }

    // Потом тихо обновляем геолокацию в фоне БЕЗ emit
    _updateGeolocationSilentlyWithoutEmit();
  }

  /// событие инициализации карты
  Future<void> _onInitializeMap(
      InitializeMap event, Emitter<DeliveryMapState> emit) async {
    // Проверяем есть ли сохраненный адрес доставки у пользователя
    final savedAddress = userRepository.user.deliveryAddress;

    if (savedAddress.address.isNotEmpty) {
      // Если есть сохраненный адрес - используем его, геолокацию НЕ запрашиваем
      Logger.i('📋 Найден сохраненный адрес, пропускаем геолокацию');

      emit(state.copyWith(
        tempDeliveryAddress: () => savedAddress.copyWith(),
        detectedAddress: savedAddress,
        selectedLocation: savedAddress.coordinates,
        userLocation: savedAddress
            .coordinates, // Устанавливаем как текущее местоположение
      ));

      // Центрируем карту на сохраненном адресе
      if (savedAddress.coordinates != null) {
        mapController?.moveCamera(
          mapkit.CameraUpdate.newCameraPosition(
            mapkit.CameraPosition(
              target: savedAddress.coordinates!,
              zoom: 16, // Больший зум для точного адреса
            ),
          ),
        );
      }

      // Устанавливаем город из сохраненного адреса
      detectedCity = savedAddress.city;

      Logger.i('✅ Загружен сохраненный адрес: ${savedAddress.address}');
    } else {
      // Если НЕТ сохраненного адреса - запрашиваем геолокацию
      Logger.i('🗺️ Сохраненного адреса нет, запрашиваем геолокацию');
      await _requestLocationAndSetup(emit);
    }

    // Загружаем заведения
    add(const LoadEstablishments());
  }

  /// НОВЫЙ метод - тихое обновление геолокации БЕЗ emit
  Future<void> _updateGeolocationSilentlyWithoutEmit() async {
    try {
      Logger.i('🔄 Тихое обновление геолокации');

      // Получаем новую геолокацию
      final mapkit.Point newUserLocation;

      if (isMock) {
        newUserLocation = const mapkit.Point(
          latitude: mockLatitude,
          longitude: mockLongitude,
        );
        Logger.i('🧪 Моковый режим: используем моковые координаты');
      } else {
        final position = await GeolocationService.instance.getCurrentPosition();
        newUserLocation = mapkit.Point(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        Logger.i('📍 Получена новая геолокация');
      }

      // Сохраняем новую геолокацию в пользователя
      await userRepository.saveGeolocation(newUserLocation);

      // Добавляем новое событие для обновления состояния
      add(UpdateUserLocationSilently(newUserLocation));

      Logger.i('✅ Геолокация тихо обновлена');
    } catch (e) {
      Logger.e('❌ Ошибка тихого обновления геолокации: $e');
      // НЕ показываем ошибку пользователю, просто логируем
    }
  }

  /// НОВЫЙ обработчик для тихого обновления геолокации
  void _onUpdateUserLocationSilently(
      UpdateUserLocationSilently event, Emitter<DeliveryMapState> emit) {
    // Обновляем состояние с новой геолокацией
    emit(state.copyWith(
      userLocation: event.location,
      selectedLocation: event.location,
      user: userRepository.user,
    ));

    // Плавно перемещаем камеру к новой позиции
    mapController?.moveCamera(
      mapkit.CameraUpdate.newCameraPosition(
        mapkit.CameraPosition(
          target: event.location,
          zoom: 15,
        ),
      ),
      animation: const mapkit.MapAnimation(
        type: mapkit.MapAnimationType.smooth,
        duration: 1.0, // 1 секунда плавной анимации
      ),
    );
  }

  /// ОБНОВЛЕННЫЙ метод для запроса геолокации и настройки карты
  Future<void> _requestLocationAndSetup(Emitter<DeliveryMapState> emit) async {
    // Если есть сохраненная геолокация - используем её сразу
    if (state.userLocation != null) {
      emit(state.copyWith(selectedLocation: state.userLocation));

      mapController?.moveCamera(
        mapkit.CameraUpdate.newCameraPosition(
          mapkit.CameraPosition(
            target: state.userLocation!,
            zoom: 15,
          ),
        ),
      );

      // Потом тихо обновляем
      _updateGeolocationSilentlyWithoutEmit();
      return;
    }

    // Если НЕТ сохраненной геолокации - показываем лоадер только первый раз
    try {
      emit(state.copyWith(isLoading: true));

      Logger.i('🗺️ Первый запрос геолокации');

      final mapkit.Point userLocation;

      if (isMock) {
        userLocation = const mapkit.Point(
          latitude: mockLatitude,
          longitude: mockLongitude,
        );
      } else {
        final position = await GeolocationService.instance.getCurrentPosition();
        userLocation = mapkit.Point(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }

      // Сохраняем геолокацию в пользователя
      await userRepository.saveGeolocation(userLocation);

      emit(state.copyWith(
        userLocation: userLocation,
        selectedLocation: userLocation,
        user: userRepository.user,
        isLoading: false,
      ));

      mapController?.moveCamera(
        mapkit.CameraUpdate.newCameraPosition(
          mapkit.CameraPosition(
            target: userLocation,
            zoom: 15,
          ),
        ),
      );

      // Определяем адрес
      await _detectAddressAndUpdateTemp(
          userLocation.latitude, userLocation.longitude, emit);
    } catch (e) {
      Logger.e('❌ Ошибка первого запроса геолокации: $e');
      emit(state.copyWith(
        errorMessage: 'Ошибка получения геопозиции: $e',
        isLoading: false,
      ));
    }
  }

  // НОВЫЙ метод - определяет адрес и создает/обновляет tempDeliveryAddress
  Future<void> _detectAddressAndUpdateTemp(
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

        Logger.i('🗺️ Полный адрес от геокодера: $fullAddress');

        // Парсим адрес
        final parsedAddress = _parseAddress(fullAddress);
        final city = parsedAddress['city'] ?? 'Зеленоград';
        final address = parsedAddress['address'] ?? '';

        // Сохраняем определенный город
        detectedCity ??= city;

        Logger.i('🏙️ Определен город: $city');
        Logger.i('🏠 Определен адрес: $address');

        // СОЗДАЕМ/ОБНОВЛЯЕМ tempDeliveryAddress
        // Если уже есть tempDeliveryAddress - сохраняем дополнительные поля
        final updatedTempAddress = DeliveryAddress(
          address: address, // НОВЫЙ адрес
          city: city, // НОВЫЙ город
          apartment: state.tempDeliveryAddress?.apartment ?? '', // Сохраняем
          entrance: state.tempDeliveryAddress?.entrance ?? '', // Сохраняем
          floor: state.tempDeliveryAddress?.floor ?? '', // Сохраняем
          intercom: state.tempDeliveryAddress?.intercom ?? '', // Сохраняем
          comment: state.tempDeliveryAddress?.comment ?? '', // Сохраняем
          coordinates: mapkit.Point(latitude: latitude, longitude: longitude),
        );

        // Обновляем состояние
        emit(state.copyWith(
          tempDeliveryAddress: () =>
              updatedTempAddress, // Создаем/обновляем temp
          detectedAddress: updatedTempAddress, // Обновляем detected
        ));

        Logger.i('✅ tempDeliveryAddress создан/обновлен');
      }
    } catch (e) {
      Logger.e('❌ Ошибка определения адреса: $e');
      detectedCity ??= 'Зеленоград';

      // Создаем базовый tempDeliveryAddress
      final fallbackAddress = DeliveryAddress(
        address: '',
        city: detectedCity!,
        apartment: state.tempDeliveryAddress?.apartment ?? '',
        entrance: state.tempDeliveryAddress?.entrance ?? '',
        floor: state.tempDeliveryAddress?.floor ?? '',
        intercom: state.tempDeliveryAddress?.intercom ?? '',
        comment: state.tempDeliveryAddress?.comment ?? '',
        coordinates: mapkit.Point(latitude: latitude, longitude: longitude),
      );

      emit(state.copyWith(
        tempDeliveryAddress: () => fallbackAddress,
        detectedAddress: fallbackAddress,
      ));
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
    // ИСПРАВЛЕНИЕ: Берем detectedAddress и делаем его tempDeliveryAddress
    if (state.detectedAddress != null) {
      emit(state.copyWith(
        tempDeliveryAddress: () =>
            state.detectedAddress!.copyWith(), // Копируем адрес
      ));
    } else {
      // Если нет detectedAddress, создаем новый с сохраненным городом
      final newAddress = DeliveryAddress(
        address: '',
        city: detectedCity ?? 'Зеленоград',
        apartment: '',
        entrance: '',
        floor: '',
        intercom: '',
        comment: '',
        coordinates: state.userLocation,
      );

      emit(state.copyWith(
        tempDeliveryAddress: () => newAddress,
        detectedAddress: newAddress,
      ));
    }
  }

  /// Обработка нажатия кнопки "Доставить сюда"
  void _onDeliverHerePressed(
      DeliverHerePressed event, Emitter<DeliveryMapState> emit) {
    Logger.i('🚚 Нажата кнопка "Доставить сюда"');

    // ТОЛЬКО разворачиваем панель, НЕ сохраняем!
    emit(state.copyWith(
      isPanelExpanded: true, // Разворачиваем панель для редактирования
    ));

    Logger.i('✅ Панель развернута для редактирования');
  }

  /// Обработка закрытия панели
  void _onClosePanel(ClosePanelEvent event, Emitter<DeliveryMapState> emit) {
    Logger.i('❌ Закрытие панели');

    // ТОЛЬКО здесь сворачиваем панель!
    emit(state.copyWith(
      isPanelExpanded: false, // ТОЛЬКО здесь!
    ));
  }

  /// выбор заведения на карте
  void _onSelectEstablishment(
      SelectEstablishment event, Emitter<DeliveryMapState> emit) {
    // Если нажали на уже выбранное заведение - убираем выделение
    if (state.selectedEstablishment?.id == event.establishment.id) {
      emit(state.copyWith(
        selectedEstablishment: () => null,
      ));
    } else {
      // Выбираем новое заведение
      emit(state.copyWith(
        selectedEstablishment: () => event.establishment,
      ));
    }
  }
}
