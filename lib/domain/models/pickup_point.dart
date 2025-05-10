class PickupPoint {
  final String city;
  final String street;
  final String house;
  final String name;
  final int openHour;
  final int openMinute;
  final int closeHour;
  final int closeMinute;
  final double? latitude;
  final double? longitude;
  final PickupType type;

  PickupPoint({
    required this.city,
    required this.street,
    required this.house,
    required this.name,
    required this.openHour,
    required this.openMinute,
    required this.closeHour,
    required this.closeMinute,
    this.latitude,
    this.longitude,
    this.type = PickupType.pickup,
  });

  factory PickupPoint.init() => PickupPoint(
        city: '',
        street: '',
        house: '',
        name: '',
        openHour: 10,
        openMinute: 0,
        closeHour: 23,
        closeMinute: 0,
        latitude: null,
        longitude: null,
        type: PickupType.pickup,
      );

  factory PickupPoint.fromJson(Map<String, dynamic> json) => PickupPoint(
        city: json['city'] ?? '',
        street: json['street'] ?? '',
        house: json['house'] ?? '',
        name: json['name'] ?? '',
        openHour: json['openHour'] ?? 10,
        openMinute: json['openMinute'] ?? 0,
        closeHour: json['closeHour'] ?? 23,
        closeMinute: json['closeMinute'] ?? 0,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        type: json['type'] != null
            ? PickupType.fromString(json['type'])
            : PickupType.pickup,
      );

  Map<String, dynamic> toJson() => {
        'city': city,
        'street': street,
        'house': house,
        'name': name,
        'openHour': openHour,
        'openMinute': openMinute,
        'closeHour': closeHour,
        'closeMinute': closeMinute,
        'latitude': latitude,
        'longitude': longitude,
        'type': type.toJson(),
      };

  /// Проверка, открыт ли пункт сейчас
  bool isOpenNow() {
    final now = DateTime.now();
    final open = DateTime(now.year, now.month, now.day, openHour, openMinute);
    final close =
        DateTime(now.year, now.month, now.day, closeHour, closeMinute);
    return now.isAfter(open) && now.isBefore(close);
  }
}

enum PickupType {
  pickup,
  restaurant;

  String get displayName {
    switch (this) {
      case PickupType.pickup:
        return 'Пункт самовывоза';
      case PickupType.restaurant:
        return 'Ресторан';
    }
  }

  String get svgAsset {
    switch (this) {
      case PickupType.pickup:
        return 'assets/svg/pickup_point.svg';
      case PickupType.restaurant:
        return 'assets/svg/restaurant.svg';
    }
  }

  static PickupType fromString(String value) {
    switch (value) {
      case 'pickup':
        return PickupType.pickup;
      case 'restaurant':
        return PickupType.restaurant;
      default:
        return PickupType.pickup;
    }
  }

  String toJson() {
    switch (this) {
      case PickupType.pickup:
        return 'pickup';
      case PickupType.restaurant:
        return 'restaurant';
    }
  }
}
