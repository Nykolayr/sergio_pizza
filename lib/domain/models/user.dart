import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:equatable/equatable.dart';
import 'package:sergio_pizza/domain/models/delivery_address.dart';
import 'package:sergio_pizza/domain/models/pickup_address.dart';

/// Модель пользователя
class User extends Equatable {
  final int id;
  final String name;
  final String phone;
  final DateTime birthDate;
  final String mail;
  final Point point;
  final int role;
  final DeliveryAddress deliveryAddress;
  final PickupAddress pickupAddress;

  bool get isReg => name.isNotEmpty;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.birthDate,
    required this.mail,
    required this.point,
    required this.role,
    required this.deliveryAddress,
    required this.pickupAddress,
  });

  factory User.initial() => User(
        id: 0,
        name: '',
        phone: '',
        birthDate: DateTime.now(),
        mail: '',
        point: Point(latitude: 0.0, longitude: 0.0),
        role: 3,
        deliveryAddress: DeliveryAddress.initial(),
        pickupAddress: PickupAddress.initial(),
      );

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      birthDate: DateTime.tryParse(json['birth_date'] ?? '') ?? DateTime.now(),
      mail: json['mail'] ?? '',
      point: Point(
        latitude: json['point']?['latitude'] ?? 0.0,
        longitude: json['point']?['longitude'] ?? 0.0,
      ),
      role: json['role'] ?? 3,
      deliveryAddress: json['delivery_address'] != null
          ? DeliveryAddress.fromJson(json['delivery_address'])
          : DeliveryAddress.initial(),
      pickupAddress: json['pickup_address'] != null
          ? PickupAddress.fromJson(json['pickup_address'])
          : PickupAddress.initial(),
    );
  }

  factory User.fromJsonApi(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      birthDate: DateTime.tryParse(json['birthdate'] ?? '') ?? DateTime.now(),
      mail: json['email'] ?? '',
      point: Point(latitude: 0.0, longitude: 0.0),
      role: json['role'] ?? 3,
      deliveryAddress: DeliveryAddress.initial(),
      pickupAddress: PickupAddress.initial(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'birth_date': birthDate.toIso8601String(),
      'mail': mail,
      'point': {
        'latitude': point.latitude,
        'longitude': point.longitude,
      },
      'role': role,
      'delivery_address': deliveryAddress.toJson(),
      'pickup_address': pickupAddress.toJson(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? phone,
    DateTime? birthDate,
    String? mail,
    Point? point,
    int? role,
    DeliveryAddress? deliveryAddress,
    PickupAddress? pickupAddress,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      mail: mail ?? this.mail,
      point: point ?? this.point,
      role: role ?? this.role,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      pickupAddress: pickupAddress ?? this.pickupAddress,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        birthDate,
        mail,
        point,
        role,
        deliveryAddress,
        pickupAddress,
      ];
}
