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

  /// очистка номера телефона от символов форматирования
  String _cleanPhoneNumber(String phone) {
    if (phone.isEmpty) return phone;
    // Удаляем все символы кроме цифр
    String cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    // Если номер начинается с 7, оставляем как есть
    // Если начинается с 8, заменяем на 7
    if (cleaned.startsWith('8') && cleaned.length == 11) {
      cleaned = '7${cleaned.substring(1)}';
    }
    return cleaned;
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
    String phone = state.phone;
    if (event.phone.isNotEmpty) {
      phone = _cleanPhoneNumber(event.phone);
    }
    final answer = await repo.sendAccept(phone: phone);
    if (answer.isEmpty) {
      emit(state.copyWith(status: AuthStatus.successAccept, phone: phone));
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
      final cleanedPhone = _cleanPhoneNumber(event.phone);
      final answer = await repo.regUser(
        name: event.name,
        birthDate: event.birthDate,
        phone: cleanedPhone,
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
    final cleanedPhone = _cleanPhoneNumber(event.phone);
    final answer = await repo.authPhone(
      phone: cleanedPhone,
      password: event.password,
    );

    if (answer.isEmpty) {
      emit(
        state.copyWith(
          user: repo.user,
          status: AuthStatus.successEnter,
          phone: cleanedPhone,
        ),
      );
    } else {
      emit(state.copyWith(error: answer, status: AuthStatus.error));
      await Future.delayed(const Duration(seconds: 4));
      emit(state.copyWith(error: ''));
    }
  }
}
