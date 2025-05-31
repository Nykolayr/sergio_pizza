import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/models/user.dart';
import 'package:sergio_pizza/domain/repository/user_repository.dart';

part 'delivery_map_event.dart';
part 'delivery_map_state.dart';

class DeliveryMapBloc extends Bloc<DeliveryMapEvent, DeliveryMapState> {
  DeliveryMapBloc() : super(DeliveryMapState.initial()) {
    on<SetErrorEvent>(_onSetErrorEvent);
  }

  /// получение пользователя
  Future<void> _onGetUserEvent(
      GetUserEvent event, Emitter<DeliveryMapState> emit) async {
    emit(state.copyWith(isLoading: true));
    UserRepository repo = Get.find<UserRepository>();
    final answer = await repo.getUser();
    emit(state.copyWith(isLoading: false));
    if (answer.isEmpty) {
      emit(state.copyWith(user: repo.user));
    } else {
      emit(state.copyWith(error: answer));
    }
  }

  /// установка ошибки
  void _onSetErrorEvent(
      SetErrorEvent event, Emitter<DeliveryMapState> emit) async {
    emit(state.copyWith(error: event.error));
  }
}
