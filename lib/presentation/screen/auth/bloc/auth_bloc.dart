import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/models/user.dart';
import 'package:sergio_pizza/domain/repository/user_repository.dart';
import 'package:sergio_pizza/presentation/screen/main/bloc/main_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState.initial()) {
    on<AuthPhoneEvent>(_onAuthPhoneEvent);
    on<AuthCodeEvent>(_onAuthCodeEvent);
    on<AuthCodeNewEvent>(_onAuthCodeNewEvent);
    on<AuthRegEvent>(_onAuthRegEvent);
  }

  /// регистрация
  Future<void> _onAuthRegEvent(
    AuthRegEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    UserRepository repo = Get.find<UserRepository>();
    final answer = await repo.regUser(
      name: event.name,
      lastName: event.lastName,
      birthDate: event.birthDate,
      phone: state.phone,
    );

    if (answer.isEmpty) {
      Get.find<MainBloc>().add(GetUserEvent());
      emit(state.copyWith(status: AuthStatus.successRegister));
    } else {
      emit(state.copyWith(error: answer, status: AuthStatus.error));
      await Future.delayed(const Duration(seconds: 4));
      emit(state.copyWith(error: ''));
    }
  }

  /// выслать новый код
  Future<void> _onAuthCodeNewEvent(
    AuthCodeNewEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    UserRepository repo = Get.find<UserRepository>();

    final answer = await repo.authPhone(phone: state.phone);
    if (answer.isEmpty) {
      emit(state.copyWith(status: AuthStatus.initial));
    } else {
      emit(state.copyWith(error: answer, status: AuthStatus.error));
    }
  }

  /// ввод кода
  Future<void> _onAuthCodeEvent(
    AuthCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    UserRepository repo = Get.find<UserRepository>();
    final answer = await repo.checkCode(code: event.code);
    if (answer.isEmpty) {
      emit(state.copyWith(status: AuthStatus.successCode));
    } else {
      emit(state.copyWith(error: answer, status: AuthStatus.error));
      await Future.delayed(const Duration(seconds: 12));
      emit(state.copyWith(error: '', status: AuthStatus.initial));
    }
  }

  /// авторизация по телефону
  Future<void> _onAuthPhoneEvent(
    AuthPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    UserRepository repo = Get.find<UserRepository>();
    final answer = await repo.authPhone(
      phone: event.phone,
    );

    if (answer.isEmpty) {
      emit(
        state.copyWith(
          user: repo.user,
          status: AuthStatus.successEnter,
          phone: event.phone,
        ),
      );
    } else {
      emit(state.copyWith(error: answer, status: AuthStatus.error));
      await Future.delayed(const Duration(seconds: 4));
      emit(state.copyWith(error: ''));
    }
  }
}
