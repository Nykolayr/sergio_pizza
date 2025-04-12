part of 'auth_bloc.dart';

class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// смена регистрации на авторизацию
class AuthChangeRegEvent extends AuthEvent {}

/// смена авторизации на телефон или email
class AuthChangeEvent extends AuthEvent {}

/// авторизация по логину и паролю

class AuthUserEvent extends AuthEvent {
  final String login;
  final String password;
  const AuthUserEvent({required this.login, required this.password});
}

/// ввод кода
class AuthCodeEvent extends AuthEvent {
  final String code;
  const AuthCodeEvent({
    required this.code,
  });
}

/// регистрация по логину и паролю
class AuthRegisterEvent extends AuthEvent {
  final String name;
  final String phone;
  final String email;
  final String password;
  const AuthRegisterEvent({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
  });
}
