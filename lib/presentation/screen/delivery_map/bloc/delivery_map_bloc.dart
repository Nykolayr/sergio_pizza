import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/models/user.dart';
import 'package:sergio_pizza/domain/repository/user_repository.dart';
import 'package:sergio_pizza/domain/models/delivery_type.dart';

part 'delivery_map_event.dart';
part 'delivery_map_state.dart';

class DeliveryMapBloc extends Bloc<DeliveryMapEvent, DeliveryMapState> {
  final UserRepository userRepository = Get.find<UserRepository>();

  DeliveryMapBloc() : super(DeliveryMapState.initial()) {
    on<SetErrorEvent>(_onSetError);
    on<SelectDeliveryType>(_onSelectDeliveryType);
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
}
