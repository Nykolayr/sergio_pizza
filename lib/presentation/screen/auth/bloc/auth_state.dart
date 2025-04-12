part of 'auth_bloc.dart';

class AuthState extends Equatable {
  final User user;
  final AuthStatus status;
  final String error;
  final bool isPhone;
  final bool isReg;

  const AuthState({
    required this.user,
    required this.status,
    required this.error,
    required this.isPhone,
    required this.isReg,
  });

  factory AuthState.initial() => AuthState(
    user: User.initial(),
    status: AuthStatus.initial,
    error: '',
    isPhone: false,
    isReg: false,
  );

  AuthState copyWith({
    User? user,
    AuthStatus? status,
    String? error,
    bool? isPhone,
    bool? isReg,
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      error: error ?? this.error,
      isPhone: isPhone ?? this.isPhone,
      isReg: isReg ?? this.isReg,
    );
  }

  @override
  List<Object?> get props => [user, status, error, isPhone, isReg];
}

enum AuthStatus {
  initial,
  loading,
  successEnter,
  successRegister,
  successCode,
  error;

  bool get isSuccessEnter => this == AuthStatus.successEnter;
  bool get isSuccessRegister => this == AuthStatus.successRegister;
  bool get isSuccessCode => this == AuthStatus.successCode;
  bool get isError => this == AuthStatus.error;
  bool get isLoading => this == AuthStatus.loading;
  bool get isInitial => this == AuthStatus.initial;
}
