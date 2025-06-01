import 'package:equatable/equatable.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class DeliveryAddress extends Equatable {
  final String address;
  final String city;
  final String apartment;
  final String entrance;
  final String floor;
  final String intercom;
  final String comment;
  final Point? coordinates;

  const DeliveryAddress({
    required this.address,
    required this.city,
    required this.apartment,
    required this.entrance,
    required this.floor,
    required this.intercom,
    required this.comment,
    this.coordinates,
  });

  factory DeliveryAddress.initial() => DeliveryAddress(
        address: '',
        city: '',
        apartment: '',
        entrance: '',
        floor: '',
        intercom: '',
        comment: '',
      );

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      apartment: json['apartment'] ?? '',
      entrance: json['entrance'] ?? '',
      floor: json['floor'] ?? '',
      intercom: json['intercom'] ?? '',
      comment: json['comment'] ?? '',
      coordinates: Point(
        latitude: json['latitude'] ?? 0.0,
        longitude: json['longitude'] ?? 0.0,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'apartment': apartment,
      'entrance': entrance,
      'floor': floor,
      'intercom': intercom,
      'comment': comment,
      'latitude': coordinates?.latitude,
      'longitude': coordinates?.longitude,
    };
  }

  DeliveryAddress copyWith({
    String? address,
    String? city,
    String? apartment,
    String? entrance,
    String? floor,
    String? intercom,
    String? comment,
    Point? coordinates,
  }) {
    return DeliveryAddress(
      address: address ?? this.address,
      city: city ?? this.city,
      apartment: apartment ?? this.apartment,
      entrance: entrance ?? this.entrance,
      floor: floor ?? this.floor,
      intercom: intercom ?? this.intercom,
      comment: comment ?? this.comment,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  String get fullAddress => city.isNotEmpty ? '$city, $address' : address;

  static DeliveryAddress empty() {
    return const DeliveryAddress(
      address: '',
      city: '',
      apartment: '',
      entrance: '',
      floor: '',
      intercom: '',
      comment: '',
    );
  }

  bool get isEmpty => address.isEmpty && city.isEmpty;
  bool get isNotEmpty => address.isNotEmpty || city.isNotEmpty;

  @override
  List<Object?> get props => [
        address,
        city,
        apartment,
        entrance,
        floor,
        intercom,
        comment,
        coordinates,
      ];
}
