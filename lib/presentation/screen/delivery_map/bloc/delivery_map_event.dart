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
