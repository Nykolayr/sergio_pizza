part of 'main_bloc.dart';

class MainState extends Equatable {
  final bool isLoading;
  final String error;
  final User user;
  final bool isListChange;

  bool get isReg => user.name.isNotEmpty;
  const MainState({
    required this.isLoading,
    required this.error,
    required this.user,
    required this.isListChange,
  });

  MainState copyWith({bool? isLoading, String? error, User? user}) {
    final shouldToggleList = user != null;

    return MainState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      isListChange: shouldToggleList ? !isListChange : isListChange,
    );
  }

  factory MainState.initial() => MainState(
    isLoading: false,
    error: '',
    user: Get.find<UserRepository>().user,
    isListChange: false,
  );

  @override
  List<Object?> get props => [isLoading, error, user, isListChange];
}
