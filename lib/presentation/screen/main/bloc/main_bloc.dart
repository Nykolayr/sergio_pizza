import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/models/main_repository.dart';
import 'package:sergio_pizza/domain/models/user.dart';
import 'package:sergio_pizza/domain/repository/user_repository.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainState.initial()) {
    _initializeLocation();
    on<SetErrorEvent>(_onSetErrorEvent);
  }

  /// обновление токена

  /// установка ошибки
  void _onSetErrorEvent(SetErrorEvent event, Emitter<MainState> emit) async {
    emit(state.copyWith(error: event.error));
  }

  /// определяем местоположение пользователя при инициализации
  Future<void> _initializeLocation() async {
    add(UpdateCurrentLocationEvent());
  }
}
