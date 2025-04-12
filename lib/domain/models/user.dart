import 'package:sergio_pizza/domain/models/loyalty.dart';
import 'package:sergio_pizza/domain/models/promocode.dart';

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
  });

  factory User.fromJson(Map<String, dynamic> data) {
    return User(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      lastName: data['last_name'] ?? '',
      birthDate:
          data['birth_date'] != null
              ? DateTime.parse(data['birth_date'])
              : DateTime.now(),
      email: data['mail'] ?? '',
      isPush: data['is_push'] ?? false,
      loyalty:
          data['loyalty'] != null
              ? Loyalty.fromJson(data['loyalty'])
              : Loyalty.init(),
      promocode:
          data['promocode'] != null
              ? Promocode.fromJson(data['promocode'])
              : Promocode.init(),
      sex: data['sex'] != null ? UserSex.values[data['sex']] : UserSex.male,
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
