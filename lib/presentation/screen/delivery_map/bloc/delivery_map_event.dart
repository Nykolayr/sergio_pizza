part of 'delivery_map_bloc.dart';

abstract class DeliveryMapEvent extends Equatable {
  const DeliveryMapEvent();

  @override
  List<Object> get props => [];
}

/// событие выбора заведения для пункта самовывоза
class SelectPickupEstablishment extends DeliveryMapEvent {
  const SelectPickupEstablishment();
}

/// установка ошибки
class SetErrorEvent extends DeliveryMapEvent {
  final String error;

  const SetErrorEvent({required this.error});

  @override
  List<Object> get props => [error];
}

// Один универсальный event для смены типа доставки
class SelectDeliveryType extends DeliveryMapEvent {
  final DeliveryType deliveryType;

  const SelectDeliveryType(this.deliveryType);

  @override
  List<Object> get props => [deliveryType];
}

// Добавляем новые события для табов
class SelectDeliveryTab extends DeliveryMapEvent {
  const SelectDeliveryTab();
}

/// выбор таба типа доставки
class SelectPickupTab extends DeliveryMapEvent {
  const SelectPickupTab();
}

/// переключение панели
class TogglePanelExpansion extends DeliveryMapEvent {
  const TogglePanelExpansion();
}

/// событие нажатия на карту
class MapTapped extends DeliveryMapEvent {
  final double latitude;
  final double longitude;

  const MapTapped({required this.latitude, required this.longitude});

  @override
  List<Object> get props => [latitude, longitude];
}

/// событие обновления адреса доставки
class UpdateDeliveryAddress extends DeliveryMapEvent {
  final DeliveryAddress address;

  const UpdateDeliveryAddress(this.address);

  @override
  List<Object> get props => [address];
}

/// событие сохранения адреса доставки
class SaveDeliveryAddress extends DeliveryMapEvent {
  const SaveDeliveryAddress();

  @override
  List<Object> get props => [];
}

/// событие очистки адреса доставки
class ClearDeliveryAddress extends DeliveryMapEvent {
  const ClearDeliveryAddress();

  @override
  List<Object> get props => [];
}

// Новое событие для очистки временных данных при выходе
class ClearTempDataOnExit extends DeliveryMapEvent {
  const ClearTempDataOnExit();

  @override
  List<Object> get props => [];
}

/// событие получения текущей локации
class GetCurrentLocation extends DeliveryMapEvent {
  const GetCurrentLocation();

  @override
  List<Object> get props => [];
}

/// событие инициализации карты
class InitializeMap extends DeliveryMapEvent {
  const InitializeMap();

  @override
  List<Object> get props => [];
}

/// событие нажатия кнопки "Доставить сюда" в свернутом состоянии
class ExpandDeliveryPanel extends DeliveryMapEvent {
  const ExpandDeliveryPanel();

  @override
  List<Object> get props => [];
}

/// Событие нажатия кнопки "Доставить сюда"
class DeliverHerePressed extends DeliveryMapEvent {
  const DeliverHerePressed();

  @override
  List<Object> get props => [];
}

/// Событие закрытия панели
class ClosePanelEvent extends DeliveryMapEvent {
  const ClosePanelEvent();

  @override
  List<Object> get props => [];
}

// Добавляем новое событие
class UpdateUserLocationSilently extends DeliveryMapEvent {
  final mapkit.Point location;

  const UpdateUserLocationSilently(this.location);

  @override
  List<Object> get props => [location];
}

// Загрузка заведений
class LoadEstablishments extends DeliveryMapEvent {
  const LoadEstablishments();

  @override
  List<Object> get props => [];
}

// Выбор заведения на карте
class SelectEstablishment extends DeliveryMapEvent {
  final Establishment establishment;

  const SelectEstablishment(this.establishment);

  @override
  List<Object> get props => [establishment];
}
