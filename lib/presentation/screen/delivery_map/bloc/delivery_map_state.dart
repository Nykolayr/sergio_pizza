part of 'delivery_map_bloc.dart';

class DeliveryMapState extends Equatable {
  final bool isLoading;
  final String error;
  final User user;
  final bool isListChange;

  bool get isReg => user.name.isNotEmpty;
  DeliveryType get deliveryType => user.deliveryType;

  const DeliveryMapState({
    required this.isLoading,
    required this.error,
    required this.user,
    required this.isListChange,
  });

  DeliveryMapState copyWith({
    bool? isLoading,
    String? error,
    User? user,
    bool? isListChange,
  }) {
    final shouldToggleList = user != null;

    return DeliveryMapState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      isListChange: shouldToggleList
          ? !this.isListChange
          : (isListChange ?? this.isListChange),
    );
  }

  factory DeliveryMapState.initial() => DeliveryMapState(
        isLoading: false,
        error: '',
        user: Get.find<UserRepository>().user,
        isListChange: false,
      );

  @override
  List<Object?> get props => [
        isLoading,
        error,
        user,
        isListChange,
      ];
}
