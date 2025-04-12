class Loyalty {
  int level;
  String name;
  int up;
  int discount;
  int scores;
  int scorePickup;
  int scoreDelivery;
  DateTime createdAt;
  DateTime endCardDate;
  LoyaltyType type;

  Loyalty({
    required this.level,
    required this.name,
    required this.up,
    required this.discount,
    required this.createdAt,
    required this.endCardDate,
    required this.type,
    required this.scores,
    required this.scorePickup,
    required this.scoreDelivery,
  });

  factory Loyalty.fromJson(Map<String, dynamic> data) {
    return Loyalty(
      level: data['level'] ?? 0,
      name: data['name'] ?? '',
      up: data['up'] ?? 0,
      discount: data['discount'] ?? 0,
      createdAt:
          data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : DateTime.now(),
      endCardDate:
          data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : DateTime.now(),
      type:
          data['type'] != null
              ? LoyaltyType.values[data['type']]
              : LoyaltyType.guest,
      scores: data['scores'] ?? 0,
      scorePickup: data['score_pickup'] ?? 0,
      scoreDelivery: data['score_delivery'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'name': name,
      'up': up,
      'discount': discount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': endCardDate.toIso8601String(),
      'type': type.index,
      'scores': scores,
      'score_pickup': scorePickup,
      'score_delivery': scoreDelivery,
    };
  }

  factory Loyalty.init() {
    return Loyalty(
      level: 0,
      name: '',
      up: 0,
      discount: 0,
      createdAt: DateTime.now(),
      endCardDate: DateTime.now(),
      type: LoyaltyType.guest,
      scores: 0,
      scorePickup: 0,
      scoreDelivery: 0,
    );
  }
}

enum LoyaltyType {
  guest,
  connoisseur,
  expert,
  esthete,
  gourmet;

  String get name => switch (this) {
    LoyaltyType.guest => 'Гость',
    LoyaltyType.connoisseur => 'Ценитель',
    LoyaltyType.expert => 'Знаток',
    LoyaltyType.esthete => 'Эстет',
    LoyaltyType.gourmet => 'Гурман',
  };

  String get discount => switch (this) {
    LoyaltyType.guest => 'скидка 0-3%',
    LoyaltyType.connoisseur => 'скидка 6%',
    LoyaltyType.expert => 'скидка 9%',
    LoyaltyType.esthete => 'скидка 12% на доставку и самовывоз',
    LoyaltyType.gourmet => 'скидка 15% на доставку и самовывоз',
  };
}
