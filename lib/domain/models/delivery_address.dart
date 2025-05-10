class DeliveryAddress {
  final String town;
  final String street;
  final String house;
  final String apartment;
  final String entrance;
  final String floor;
  final String intercom;
  final String comment;
  final double? latitude;
  final double? longitude;

  DeliveryAddress({
    required this.town,
    required this.street,
    required this.house,
    required this.apartment,
    required this.entrance,
    required this.floor,
    required this.intercom,
    required this.comment,
    this.latitude,
    this.longitude,
  });

  factory DeliveryAddress.init() => DeliveryAddress(
        town: '',
        street: '',
        house: '',
        apartment: '',
        entrance: '',
        floor: '',
        intercom: '',
        comment: '',
        latitude: null,
        longitude: null,
      );

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      DeliveryAddress(
        town: json['town'] ?? '',
        street: json['street'] ?? '',
        house: json['house'] ?? '',
        apartment: json['apartment'] ?? '',
        entrance: json['entrance'] ?? '',
        floor: json['floor'] ?? '',
        intercom: json['intercom'] ?? '',
        comment: json['comment'] ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'town': town,
        'street': street,
        'house': house,
        'apartment': apartment,
        'entrance': entrance,
        'floor': floor,
        'intercom': intercom,
        'comment': comment,
        'latitude': latitude,
        'longitude': longitude,
      };
}
