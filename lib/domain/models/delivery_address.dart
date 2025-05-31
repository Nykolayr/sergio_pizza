import 'package:equatable/equatable.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class DeliveryAddress extends Equatable {
  final String address;
  final String apartment;
  final String entrance;
  final String floor;
  final String intercom;
  final String comment;
  final Point coordinates;

  const DeliveryAddress({
    required this.address,
    required this.apartment,
    required this.entrance,
    required this.floor,
    required this.intercom,
    required this.comment,
    required this.coordinates,
  });

  factory DeliveryAddress.initial() => DeliveryAddress(
        address: '',
        apartment: '',
        entrance: '',
        floor: '',
        intercom: '',
        comment: '',
        coordinates: Point(latitude: 0.0, longitude: 0.0),
      );

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      address: json['address'] ?? '',
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
      'apartment': apartment,
      'entrance': entrance,
      'floor': floor,
      'intercom': intercom,
      'comment': comment,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
    };
  }

  DeliveryAddress copyWith({
    String? address,
    String? apartment,
    String? entrance,
    String? floor,
    String? intercom,
    String? comment,
    Point? coordinates,
  }) {
    return DeliveryAddress(
      address: address ?? this.address,
      apartment: apartment ?? this.apartment,
      entrance: entrance ?? this.entrance,
      floor: floor ?? this.floor,
      intercom: intercom ?? this.intercom,
      comment: comment ?? this.comment,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  bool get isEmpty => address.isEmpty;
  bool get isNotEmpty => address.isNotEmpty;

  @override
  List<Object?> get props => [
        address,
        apartment,
        entrance,
        floor,
        intercom,
        comment,
        coordinates,
      ];
}
