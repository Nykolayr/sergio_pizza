class Promocode {
  String name;
  String description;
  DateTime validDate;
  PromocodeType type;

  Promocode({
    required this.name,
    required this.description,
    required this.validDate,
    required this.type,
  });

  factory Promocode.fromJson(Map<String, dynamic> data) {
    return Promocode(
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      validDate:
          data['valid_date'] != null
              ? DateTime.parse(data['valid_date'])
              : DateTime.now(),
      type:
          data['type'] != null
              ? PromocodeType.values[data['type']]
              : PromocodeType.discount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'valid_date': validDate.toIso8601String(),
      'type': type.index,
    };
  }

  factory Promocode.init() {
    return Promocode(
      name: '',
      description: '',
      validDate: DateTime.now(),
      type: PromocodeType.discount,
    );
  }
}

enum PromocodeType { discount, bonus }
