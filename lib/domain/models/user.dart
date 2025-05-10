import 'package:sergio_pizza/domain/models/delivery_address.dart';
import 'package:sergio_pizza/domain/models/loyalty.dart';
import 'package:sergio_pizza/domain/models/pickup_point.dart';
import 'package:sergio_pizza/domain/models/promocode.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Модель пользователя
class User {
  int id;
  String name; // имя
  String phone; // телефон
  String lastName; // фамилия
  DateTime birthDate; // дата рождения
  Loyalty loyalty; // лоял
  String email; // почта
  bool isPush; // признак отправки push
  Promocode promocode; // промокод
  UserSex sex; // пол
  DeliveryAddress deliveryAddress; // адрес доставки
  PickupPoint pickupPoint; // пункт выдачи
  bool isDelivery; // признак доставки
  Point point; // позиция на карте пользователя

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.lastName,
    required this.birthDate,
    required this.email,
    required this.isPush,
    required this.loyalty,
    required this.promocode,
    required this.sex,
    required this.deliveryAddress,
    required this.pickupPoint,
    required this.isDelivery,
    required this.point,
  });

  factory User.fromJson(Map<String, dynamic> data) {
    return User(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      lastName: data['last_name'] ?? '',
      birthDate: data['birth_date'] != null
          ? DateTime.parse(data['birth_date'])
          : DateTime.now(),
      email: data['mail'] ?? '',
      isPush: data['is_push'] ?? false,
      loyalty: data['loyalty'] != null
          ? Loyalty.fromJson(data['loyalty'])
          : Loyalty.init(),
      promocode: data['promocode'] != null
          ? Promocode.fromJson(data['promocode'])
          : Promocode.init(),
      sex: data['sex'] != null ? UserSex.values[data['sex']] : UserSex.male,
      deliveryAddress: data['delivery_address'] != null
          ? DeliveryAddress.fromJson(data['delivery_address'])
          : DeliveryAddress.init(),
      pickupPoint: data['pickup_point'] != null
          ? PickupPoint.fromJson(data['pickup_point'])
          : PickupPoint.init(),
      isDelivery: data['is_delivery'] ?? false,
      point: data['point'] != null
          ? Point(
              latitude: data['point']['latitude'],
              longitude: data['point']['longitude'],
            )
          : Point(latitude: 0, longitude: 0),
    );
  }

  factory User.initial() {
    return User(
      id: 0,
      name: '',
      phone: '',
      lastName: '',
      birthDate: DateTime.now(),
      email: '',
      isPush: false,
      loyalty: Loyalty.init(),
      promocode: Promocode.init(),
      sex: UserSex.male,
      deliveryAddress: DeliveryAddress.init(),
      pickupPoint: PickupPoint.init(),
      isDelivery: true,
      point: Point(latitude: 0, longitude: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'last_name': lastName,
      'birth_date': birthDate.toIso8601String(),
      'mail': email,
      'is_push': isPush,
      'loyalty': loyalty.toJson(),
      'promocode': promocode.toJson(),
      'sex': sex.index,
      'delivery_address': deliveryAddress.toJson(),
      'pickup_point': pickupPoint.toJson(),
      'is_delivery': isDelivery,
      'point': point.toJson(),
    };
  }
}

enum UserSex {
  male,
  female;

  String get name => switch (this) {
        UserSex.male => 'Мужчина',
        UserSex.female => 'Женщина',
      };
}
