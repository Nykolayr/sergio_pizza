part of 'delivery_map_bloc.dart';

abstract class DeliveryMapEvent extends Equatable {
  const DeliveryMapEvent();

  @override
  List<Object> get props => [];
}

/// получение пользователя
class GetUserEvent extends DeliveryMapEvent {}

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

class SelectPickupTab extends DeliveryMapEvent {
  const SelectPickupTab();
}

class TogglePanelExpansion extends DeliveryMapEvent {
  const TogglePanelExpansion();
}

class MapTapped extends DeliveryMapEvent {
  final double latitude;
  final double longitude;

  const MapTapped({required this.latitude, required this.longitude});

  @override
  List<Object> get props => [latitude, longitude];
}

class UpdateDeliveryAddress extends DeliveryMapEvent {
  final DeliveryAddress address;

  const UpdateDeliveryAddress(this.address);

  @override
  List<Object> get props => [address];
}

class SaveDeliveryAddress extends DeliveryMapEvent {
  const SaveDeliveryAddress();

  @override
  List<Object> get props => [];
}

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
