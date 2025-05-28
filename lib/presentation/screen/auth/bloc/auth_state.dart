part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final User user;
  final AuthStatus status;
  final String error;
  final String phone;
  final bool isReg;

  const AuthState({
    required this.user,
    required this.status,
    required this.error,
    required this.phone,
    required this.isReg,
  });

  factory AuthState.initial() => AuthState(
        user: User.initial(),
        status: AuthStatus.initial,
        error: '',
        phone: '',
        isReg: false,
      );

  AuthState copyWith({
    User? user,
    AuthStatus? status,
    String? error,
    String? phone,
    bool? isReg,
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      error: error ?? this.error,
      phone: phone ?? this.phone,
      isReg: isReg ?? this.isReg,
    );
  }

  @override
  List<Object?> get props => [user, status, error, phone, isReg];
}

enum AuthStatus {
  initial,
  loading,
  successEnter,
  successRegister,
  successCode,
  successAccept,
  successUpdateUser,
  error;

  bool get isSuccessEnter => this == AuthStatus.successEnter;
  bool get isSuccessRegister => this == AuthStatus.successRegister;
  bool get isSuccessCode => this == AuthStatus.successCode;
  bool get isSuccessAccept => this == AuthStatus.successAccept;
  bool get isError => this == AuthStatus.error;
  bool get isLoading => this == AuthStatus.loading;
  bool get isInitial => this == AuthStatus.initial;
  bool get isSuccessUpdateUser => this == AuthStatus.successUpdateUser;
}
