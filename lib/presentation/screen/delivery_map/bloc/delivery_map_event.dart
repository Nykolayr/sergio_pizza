part of 'delivery_map_bloc.dart';

sealed class DeliveryMapEvent extends Equatable {
  const DeliveryMapEvent();

  @override
  List<Object> get props => [];
}

/// получение пользователя
class GetUserEvent extends DeliveryMapEvent {}

/// установка ошибки
class SetErrorEvent extends DeliveryMapEvent {
  final String error;
  const SetErrorEvent(this.error);
}
