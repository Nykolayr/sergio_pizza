import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/models/user.dart';
import 'package:sergio_pizza/domain/repository/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState.initial()) {
    on<AuthPhoneEvent>(_onAuthPhoneEvent);
    on<RegPhoneEvent>(_onRegPhoneEvent);
    on<SendAcceptEvent>(_onSendAcceptEvent);
    on<SendCodeEvent>(_onSendCodeEvent);
    on<UpdateUserEvent>(_onUpdateUserEvent);
  }

  /// апдейт пользователя
  Future<void> _onUpdateUserEvent(
    UpdateUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(user: event.user));
  }

  UserRepository repo = Get.find<UserRepository>();

  /// отправка кода для проверки
  Future<void> _onSendCodeEvent(
    SendCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final answer = await repo.sendCode(phone: state.phone, code: event.code);
    if (answer.isEmpty) {
      emit(state.copyWith(status: AuthStatus.successCode));
    } else {
      emit(state.copyWith(error: answer, status: AuthStatus.error));
    }
  }

  /// отправка запроса на код в смс
  Future<void> _onSendAcceptEvent(
    SendAcceptEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final answer = await repo.sendAccept(
        phone: event.phone.isEmpty ? state.phone : event.phone);
    if (answer.isEmpty) {
      emit(state.copyWith(status: AuthStatus.successAccept));
    } else {
      emit(state.copyWith(error: answer, status: AuthStatus.error));
    }
  }

  /// регистрация по телефону
  Future<void> _onRegPhoneEvent(
    RegPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    if (event.password == event.confirmPassword) {
      final answer = await repo.regUser(
        name: event.name,
        birthDate: event.birthDate,
        phone: event.phone,
        password: event.password,
        email: event.email,
      );
      if (answer.isEmpty) {
        emit(state.copyWith(status: AuthStatus.successRegister));
      } else {
        emit(state.copyWith(error: answer, status: AuthStatus.error));
      }
    } else {
      emit(state.copyWith(
          error: 'Пароли не совпадают', status: AuthStatus.error));
    }
  }

  /// авторизация по телефону
  Future<void> _onAuthPhoneEvent(
    AuthPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final answer = await repo.authPhone(
      phone: event.phone,
      password: event.password,
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
