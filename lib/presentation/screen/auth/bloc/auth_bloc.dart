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
    on<AuthUserEvent>(_onAuthEvent);
    on<AuthRegisterEvent>(_onAuthRegisterEvent);
    on<AuthCodeEvent>(_onAuthCodeEvent);
    on<AuthChangeEvent>(_onAuthChangeEvent);
    on<AuthChangeRegEvent>(_onAuthChangeRegEvent);
  }

  /// смена регистрации на авторизацию
  Future<void> _onAuthChangeRegEvent(
    AuthChangeRegEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isReg: !state.isReg));
  }

  /// смена авторизации на телефон или email

  Future<void> _onAuthChangeEvent(
    AuthChangeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isPhone: !state.isPhone));
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
      User user = await repo.getUser();
      Get.find<MainBloc>().add(GetUserEvent());
      emit(state.copyWith(status: AuthStatus.successCode, user: user));
    } else {
      emit(state.copyWith(error: answer, status: AuthStatus.error));
      await Future.delayed(const Duration(seconds: 4));
      emit(state.copyWith(error: ''));
    }
  }

  /// авторизация по телефону или email
  Future<void> _onAuthEvent(
    AuthUserEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    UserRepository repo = Get.find<UserRepository>();
    final answer = await repo.authUser(
      login: event.login,
      password: event.password,
      isPhone: state.isPhone,
    );

    if (answer.isEmpty) {
      emit(
        state.copyWith(
          isReg: false,
          user: repo.user,
          status: AuthStatus.successEnter,
        ),
      );
    } else {
      emit(state.copyWith(error: answer, status: AuthStatus.error));
      await Future.delayed(const Duration(seconds: 4));
      emit(state.copyWith(error: ''));
    }
  }

  /// регистрация по логину
  Future<void> _onAuthRegisterEvent(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    UserRepository repo = Get.find<UserRepository>();
    final answer = await repo.registerUser(
      name: event.name,
      phone: event.phone,
      email: event.email,
      password: event.password,
    );
    if (answer.isEmpty) {
      emit(
        state.copyWith(
          isReg: true,
          user: repo.user,
          status: AuthStatus.successEnter,
        ),
      );
    } else {
      emit(state.copyWith(error: answer, status: AuthStatus.error));
      await Future.delayed(const Duration(seconds: 4));
      emit(state.copyWith(error: ''));
    }
  }
}
