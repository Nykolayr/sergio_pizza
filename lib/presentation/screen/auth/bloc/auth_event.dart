part of 'auth_bloc.dart';

class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// авторизация по телефону
class AuthPhoneEvent extends AuthEvent {
  final String phone;
  const AuthPhoneEvent({required this.phone});
}

/// выслать новый код
class AuthCodeNewEvent extends AuthEvent {
  const AuthCodeNewEvent();
}

/// ввод кода
class AuthCodeEvent extends AuthEvent {
  final String code;
  const AuthCodeEvent({
    required this.code,
  });
}
