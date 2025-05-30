part of 'auth_bloc.dart';

class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// отправка телефона для авторизации
class TryLoginEvent extends AuthEvent {
  final String phone;
  const TryLoginEvent({required this.phone});
}

/// апдейт пользователя
class UpdateUserEvent extends AuthEvent {
  final User user;
  const UpdateUserEvent({required this.user});
}

/// отправка запроса на код в смс
class SendAcceptEvent extends AuthEvent {
  final String phone;
  const SendAcceptEvent({required this.phone});
}

/// отправка запроса кода для проверки
class SendCodeEvent extends AuthEvent {
  final String code;
  const SendCodeEvent({required this.code});
}

/// регистрация по телефону
class RegPhoneEvent extends AuthEvent {
  final String password;
  final String confirmPassword;
  final String name;
  final String email;
  final String birthDate;
  const RegPhoneEvent({
    required this.password,
    required this.confirmPassword,
    required this.name,
    required this.email,
    required this.birthDate,
  });
}

/// авторизация по телефону
class AuthPhoneEvent extends AuthEvent {
  final String phone;
  final String password;
  const AuthPhoneEvent({required this.phone, required this.password});
}

/// очистка ошибки
class ClearErrorEvent extends AuthEvent {
  const ClearErrorEvent();
}
