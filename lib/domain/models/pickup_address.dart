import 'package:equatable/equatable.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class PickupAddress extends Equatable {
  final int id;
  final String name;
  final String address;
  final String workingHours;
  final String phone;
  final Point coordinates;
  final bool isSelected;

  const PickupAddress({
    required this.id,
    required this.name,
    required this.address,
    required this.workingHours,
    required this.phone,
    required this.coordinates,
    required this.isSelected,
  });

  factory PickupAddress.initial() => PickupAddress(
        id: 0,
        name: '',
        address: '',
        workingHours: '',
        phone: '',
        coordinates: Point(latitude: 0.0, longitude: 0.0),
        isSelected: false,
      );

  factory PickupAddress.fromJson(Map<String, dynamic> json) {
    return PickupAddress(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      workingHours: json['working_hours'] ?? '',
      phone: json['phone'] ?? '',
      coordinates: Point(
        latitude: json['latitude'] ?? 0.0,
        longitude: json['longitude'] ?? 0.0,
      ),
      isSelected: json['is_selected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'working_hours': workingHours,
      'phone': phone,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'is_selected': isSelected,
    };
  }

  PickupAddress copyWith({
    int? id,
    String? name,
    String? address,
    String? workingHours,
    String? phone,
    Point? coordinates,
    bool? isSelected,
  }) {
    return PickupAddress(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      workingHours: workingHours ?? this.workingHours,
      phone: phone ?? this.phone,
      coordinates: coordinates ?? this.coordinates,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  bool get isEmpty => address.isEmpty;
  bool get isNotEmpty => address.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        workingHours,
        phone,
        coordinates,
        isSelected,
      ];
}
