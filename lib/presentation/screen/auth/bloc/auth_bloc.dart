import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/models/user.dart';
import 'package:sergio_pizza/domain/repository/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  Timer? _errorTimer;

  AuthBloc() : super(AuthState.initial()) {
    on<AuthPhoneEvent>(_onAuthPhoneEvent);
    on<RegPhoneEvent>(_onRegPhoneEvent);
    on<SendAcceptEvent>(_onSendAcceptEvent);
    on<SendCodeEvent>(_onSendCodeEvent);
    on<UpdateUserEvent>(_onUpdateUserEvent);
    on<TryLoginEvent>(_onTryLoginEvent);
    on<ClearErrorEvent>(_onClearErrorEvent);
  }

  @override
  Future<void> close() {
    _errorTimer?.cancel();
    return super.close();
  }

  /// отправка телефона для авторизации
  Future<void> _onTryLoginEvent(
    TryLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    String phone = state.phone;
    if (event.phone.isNotEmpty) {
      phone = _cleanPhoneNumber(event.phone);
    }
    final answer = await repo.tryLogin(phone: phone);
    emit(state.copyWith(phone: phone));
    if (answer['error'] == null) {
      if (answer['status'] == 201) {
        final smsCode = _extractSmsCode(answer);
        emit(state.copyWith(
            status: AuthStatus.successEnter,
            code: smsCode ?? '',
            phone: phone));
      } else if (answer['status'] == 202) {
        emit(state.copyWith(status: AuthStatus.successTryLogin));
      }
    } else {
      if (answer['error'] == 'Номер телефона не подтверждён') {
        emit(state.copyWith(status: AuthStatus.loading));
        final sendAcceptAnswer = await repo.sendAccept(phone: phone);
        if (sendAcceptAnswer['error'] == null) {
          final smsCode = _extractSmsCode(sendAcceptAnswer);

          if (smsCode != null) {
            emit(state.copyWith(
              status: AuthStatus.successEnter,
              phone: phone,
              code: smsCode,
            ));
          }
        } else {
          clearErrorWithShow(emit, sendAcceptAnswer['error'] as String);
        }
      } else {
        clearErrorWithShow(emit, answer['error'] as String);
      }
    }
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
      clearErrorWithShow(emit, answer);
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
    if (answer['error'] == null) {
      final smsCode = _extractSmsCode(answer);

      emit(state.copyWith(
        status: AuthStatus.successAccept,
        phone: phone,
        code: smsCode ?? '',
      ));
    } else {
      clearErrorWithShow(emit, answer['error'] as String);
    }
  }

  /// регистрация
  Future<void> _onRegPhoneEvent(
    RegPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    if (event.password == event.confirmPassword) {
      final answer = await repo.regUser(
        name: event.name,
        birthDate: _convertDateFormat(event.birthDate),
        phone: state.phone,
        password: event.password,
        email: event.email,
      );
      if (answer.isEmpty) {
        emit(state.copyWith(status: AuthStatus.successRegister));
      } else {
        clearErrorWithShow(emit, answer);
      }
    } else {
      clearErrorWithShow(emit, 'Пароли не совпадают');
    }
  }

  /// преобразование даты из формата DD.MM.YYYY в YYYY-MM-DD
  String _convertDateFormat(String dateString) {
    final parts = dateString.split('.');
    if (parts.length == 3) {
      final day = parts[0].padLeft(2, '0');
      final month = parts[1].padLeft(2, '0');
      final year = parts[2];
      return '$year-$month-$day';
    }
    return '2000-01-01'; // значение по умолчанию
  }

  /// авторизация по телефону
  Future<void> _onAuthPhoneEvent(
    AuthPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final answer = await repo.authPhone(
      phone: state.phone,
      password: event.password,
    );

    if (answer.isEmpty) {
      emit(
        state.copyWith(
          user: repo.user,
          status: AuthStatus.successEnter,
          phone: state.phone,
        ),
      );
    } else {
      clearErrorWithShow(emit, answer);
    }
  }

  /// очистка ошибки и показа ошибки
  Future<void> clearErrorWithShow(Emitter<AuthState> emit, String error) async {
    emit(state.copyWith(error: error, status: AuthStatus.error));
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 8), () {
      add(const ClearErrorEvent());
    });
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

  /// извлечение SMS кода из ответа сервера
  String? _extractSmsCode(Map<String, dynamic> response) {
    // Проверяем в сообщении (message)
    if (response['message'] != null) {
      final message = response['message'] as String;
      final regex = RegExp(r'sms code: (\d+)');
      final match = regex.firstMatch(message);
      if (match != null) {
        return match.group(1);
      }
    }

    return null;
  }

  /// очистка ошибки
  Future<void> _onClearErrorEvent(
    ClearErrorEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(error: ''));
  }
}
