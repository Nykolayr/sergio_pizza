part of 'delivery_map_bloc.dart';

class DeliveryMapState extends Equatable {
  final bool isLoading;
  final String error;
  final User user;
  final bool isListChange;
  final bool isPanelExpanded;
  final DeliveryAddress? tempDeliveryAddress;
  final mapkit.Point? userLocation;
  final DeliveryAddress? detectedAddress;
  final DeliveryType selectedDeliveryType;
  final String errorMessage;
  final mapkit.Point? selectedLocation;
  final int? remainingMinutes;

  bool get isReg => user.name.isNotEmpty;
  DeliveryType get deliveryType => user.deliveryType;

  const DeliveryMapState({
    required this.isLoading,
    required this.error,
    required this.user,
    required this.isListChange,
    required this.isPanelExpanded,
    this.tempDeliveryAddress,
    this.userLocation,
    this.detectedAddress,
    required this.selectedDeliveryType,
    required this.errorMessage,
    this.selectedLocation,
    this.remainingMinutes,
  });

  DeliveryMapState copyWith({
    bool? isLoading,
    String? error,
    User? user,
    bool? isListChange,
    bool? isPanelExpanded,
    DeliveryAddress? Function()? tempDeliveryAddress,
    mapkit.Point? userLocation,
    DeliveryAddress? detectedAddress,
    DeliveryType? selectedDeliveryType,
    String? errorMessage,
    mapkit.Point? selectedLocation,
    int? remainingMinutes,
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
      userLocation: userLocation ?? this.userLocation,
      detectedAddress: detectedAddress ?? this.detectedAddress,
      selectedDeliveryType: selectedDeliveryType ?? this.selectedDeliveryType,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
    );
  }

  factory DeliveryMapState.initial() {
    final userRepo = Get.find<UserRepository>();
    return DeliveryMapState(
      isLoading: false,
      error: '',
      user: userRepo.user,
      isListChange: false,
      isPanelExpanded: false,
      tempDeliveryAddress: null,
      userLocation: userRepo.user.deliveryType == DeliveryType.delivery
          ? userRepo.user.deliveryAddress?.coordinates
          : null,
      detectedAddress: null,
      selectedDeliveryType: userRepo.user.deliveryType,
      errorMessage: '',
      selectedLocation: null,
      remainingMinutes: 50,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        user,
        isListChange,
        isPanelExpanded,
        tempDeliveryAddress,
        userLocation,
        detectedAddress,
        selectedDeliveryType,
        errorMessage,
        selectedLocation,
        remainingMinutes,
      ];
}
