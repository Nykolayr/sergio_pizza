part of 'main_bloc.dart';

sealed class MainEvent extends Equatable {
  const MainEvent();

  @override
  List<Object> get props => [];
}

/// получение пользователя
class GetUserEvent extends MainEvent {}

/// обновление текущего местоположения
class UpdateCurrentLocationEvent extends MainEvent {}

/// установка ошибки
class SetErrorEvent extends MainEvent {
  final String error;
  const SetErrorEvent(this.error);
}
