import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/models/delivery_address.dart';
import 'package:sergio_pizza/domain/models/user.dart';
import 'package:sergio_pizza/domain/repository/user_repository.dart';
import 'package:sergio_pizza/domain/models/delivery_type.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart' as mapkit;
import 'package:yandex_geocoder/yandex_geocoder.dart';

part 'delivery_map_event.dart';
part 'delivery_map_state.dart';

class DeliveryMapBloc extends Bloc<DeliveryMapEvent, DeliveryMapState> {
  final UserRepository userRepository = Get.find<UserRepository>();

  DeliveryMapBloc() : super(DeliveryMapState.initial()) {
    on<SetErrorEvent>(_onSetError);
    on<SelectDeliveryType>(_onSelectDeliveryType);
    on<MapTapped>(_onMapTapped);
    on<UpdateDeliveryAddress>(_onUpdateDeliveryAddress);
    on<SaveDeliveryAddress>(_onSaveDeliveryAddress);
    on<ClearDeliveryAddress>(_onClearDeliveryAddress);
    on<ClearTempDataOnExit>(_onClearTempDataOnExit);
  }

  /// установка ошибки
  void _onSetError(SetErrorEvent event, Emitter<DeliveryMapState> emit) {
    emit(state.copyWith(error: event.error));
  }

  void _onSelectDeliveryType(
      SelectDeliveryType event, Emitter<DeliveryMapState> emit) async {
    // Обновляем тип доставки в UserRepository
    await userRepository.setDeliveryType(event.deliveryType);

    // Обновляем состояние с новым пользователем
    emit(state.copyWith(user: userRepository.user));
  }

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

      String address = 'Адрес не найден';
      if (geocodeResult
              .response?.geoObjectCollection?.featureMember?.isNotEmpty ==
          true) {
        final geoObject = geocodeResult
            .response!.geoObjectCollection!.featureMember!.first.geoObject;
        address = geoObject?.metaDataProperty?.geocoderMetaData?.text ??
            'Адрес не найден';
      }

      // Создаем временный адрес с полученными данными
      final tempAddress = DeliveryAddress(
        address: address,
        apartment: '',
        entrance: '',
        floor: '',
        intercom: '',
        comment: '',
        coordinates: coordinates,
      );

      // Сохраняем во временную переменную
      emit(state.copyWith(
        tempDeliveryAddress: () => tempAddress,
      ));
    } catch (e) {
      // В случае ошибки используем координаты как адрес
      final coordinates =
          mapkit.Point(latitude: event.latitude, longitude: event.longitude);

      final tempAddress = DeliveryAddress(
        address:
            'Широта: ${event.latitude.toStringAsFixed(6)}, Долгота: ${event.longitude.toStringAsFixed(6)}',
        apartment: '',
        entrance: '',
        floor: '',
        intercom: '',
        comment: '',
        coordinates: coordinates,
      );

      emit(state.copyWith(
        tempDeliveryAddress: () => tempAddress,
      ));
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

  void _onClearDeliveryAddress(
      ClearDeliveryAddress event, Emitter<DeliveryMapState> emit) {
    print('🔥 ClearDeliveryAddress вызван!');

    // Очищаем временный адрес - панель должна свернуться
    emit(state.copyWith(tempDeliveryAddress: () => null));

    print('🔥 tempDeliveryAddress очищен!');
  }

  void _onClearTempDataOnExit(
      ClearTempDataOnExit event, Emitter<DeliveryMapState> emit) {
    // Очищаем временные данные при выходе со страницы
    emit(state.copyWith(tempDeliveryAddress: () => null));
  }
}
