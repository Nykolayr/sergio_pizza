part of 'delivery_map_bloc.dart';

class DeliveryMapState extends Equatable {
  final bool isLoading;
  final String error;
  final User user;
  final bool isListChange;
  final bool isPanelExpanded;
  final DeliveryAddress? tempDeliveryAddress;

  bool get isReg => user.name.isNotEmpty;
  DeliveryType get deliveryType => user.deliveryType;

  const DeliveryMapState({
    required this.isLoading,
    required this.error,
    required this.user,
    required this.isListChange,
    required this.isPanelExpanded,
    this.tempDeliveryAddress,
  });

  DeliveryMapState copyWith({
    bool? isLoading,
    String? error,
    User? user,
    bool? isListChange,
    bool? isPanelExpanded,
    DeliveryAddress? Function()? tempDeliveryAddress,
  }) {
    return DeliveryMapState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      user: user ?? this.user,
      isListChange: isListChange ?? this.isListChange,
      isPanelExpanded: isPanelExpanded ?? this.isPanelExpanded,
      tempDeliveryAddress: tempDeliveryAddress != null
          ? tempDeliveryAddress()
          : this.tempDeliveryAddress,
    );
  }

  factory DeliveryMapState.initial() => DeliveryMapState(
        isLoading: false,
        error: '',
        user: Get.find<UserRepository>().user,
        isListChange: false,
        isPanelExpanded: false,
        tempDeliveryAddress: null,
      );

  @override
  List<Object?> get props => [
        isLoading,
        error,
        user,
        isListChange,
        isPanelExpanded,
        tempDeliveryAddress,
      ];
}
