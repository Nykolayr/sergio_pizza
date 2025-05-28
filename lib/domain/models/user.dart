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
  DateTime birthDate; // дата рождения
  String email; // почта

  Point point; // позиция на карте пользователя

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.birthDate,
    required this.email,
    required this.point,
  });

  factory User.fromJson(Map<String, dynamic> data) {
    return User(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      birthDate: data['birth_date'] != null
          ? DateTime.parse(data['birth_date'])
          : DateTime.now(),
      email: data['mail'] ?? '',
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
      birthDate: DateTime.now(),
      email: '',
      point: Point(latitude: 0, longitude: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'birth_date': birthDate.toIso8601String(),
      'mail': email,
      'point': point.toJson(),
    };
  }

  Map<String, dynamic> toJsonApi() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'birthdate':
          '${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',
    };
  }
}
