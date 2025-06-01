/// Тип доставки
enum DeliveryType {
  delivery, // Доставка
  pickup; // Самовывоз

  bool get isDelivery => this == DeliveryType.delivery;
  bool get isPickup => this == DeliveryType.pickup;

  String get displayName {
    switch (this) {
      case DeliveryType.delivery:
        return 'Доставка';
      case DeliveryType.pickup:
        return 'Самовывоз';
    }
  }
}
