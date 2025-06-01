import 'package:equatable/equatable.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart' as mapkit;
import 'establishment_type.dart';

class Establishment extends Equatable {
  final String id;
  final String address;
  final mapkit.Point coordinates;
  final EstablishmentType type;
  final String? workingHours; // например "до 23:00"
  final String? status; // например "Открыт", "Закрыт", "Временно закрыт"
  final int? estimatedTime; // время в минутах для готовности заказа
  final double? distance; // расстояние в км от пользователя

  const Establishment({
    required this.id,
    required this.address,
    required this.coordinates,
    required this.type,
    this.workingHours,
    this.status,
    this.estimatedTime,
    this.distance,
  });

  Establishment copyWith({
    String? id,
    String? address,
    mapkit.Point? coordinates,
    EstablishmentType? type,
    String? workingHours,
    String? status,
    int? estimatedTime,
    double? distance,
  }) {
    return Establishment(
      id: id ?? this.id,
      address: address ?? this.address,
      coordinates: coordinates ?? this.coordinates,
      type: type ?? this.type,
      workingHours: workingHours ?? this.workingHours,
      status: status ?? this.status,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      distance: distance ?? this.distance,
    );
  }

  factory Establishment.fromJson(Map<String, dynamic> json) {
    return Establishment(
      id: json['id'] as String,
      address: json['address'] as String,
      coordinates: mapkit.Point(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      ),
      type: EstablishmentType.fromString(json['type'] as String),
      workingHours: json['working_hours'] as String?,
      status: json['status'] as String?,
      estimatedTime: json['estimated_time'] as int?,
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'type': type.value,
      'working_hours': workingHours,
      'status': status,
      'estimated_time': estimatedTime,
      'distance': distance,
    };
  }

  // Геттеры для удобства
  bool get isOpen => status == 'Открыт';
  bool get isClosed => status == 'Закрыт';
  bool get isPickup => type == EstablishmentType.pickup;
  bool get isRestaurant => type == EstablishmentType.restaurant;

  // Форматированное время работы
  String get formattedWorkingHours {
    if (workingHours != null) {
      return 'Открыт $workingHours';
    }
    return status ?? 'Статус неизвестен';
  }

  // Форматированное время готовности
  String get formattedEstimatedTime {
    if (estimatedTime != null) {
      return 'В этом ${type.displayName.toLowerCase()} можно забрать в течение $estimatedTime минут';
    }
    return '';
  }

  // Форматированное расстояние
  String get formattedDistance {
    if (distance != null) {
      return '${distance!.toStringAsFixed(1)} км';
    }
    return '';
  }

  @override
  List<Object?> get props => [
        id,
        address,
        coordinates,
        type,
        workingHours,
        status,
        estimatedTime,
        distance,
      ];
}
