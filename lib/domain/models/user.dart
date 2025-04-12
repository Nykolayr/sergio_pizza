/// Модель пользователя
class User {
  int id;
  String name; //
  String phone; // телефон
  String email; // почта
  String lang; // язык
  String card; // банковская карта
  String formaterCard; // форматированная банковская карта
  int discount; // скидка
  int bonus; // бонусы
  int orders; // заказы
  bool isMailVerified; // почта верифицирована

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.lang,
    required this.card,
    required this.formaterCard,
    required this.discount,
    required this.bonus,
    required this.orders,
    required this.isMailVerified,
  });
  factory User.fromJson(Map<String, dynamic> data) {
    // for (var item in data.entries) {
    //   print(
    //       'item.key >>>>>>>> ${item.key} == ${item.value.runtimeType} === ${item.value}');
    // }
    return User(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      lang: data['lang'] ?? '',
      card: data['card'] ?? '',
      formaterCard: data['formatted_card'] ?? '',
      discount: data['discount'] ?? 0,
      isMailVerified: data['is_mail_verified'] ?? false,
      bonus: data['bonus'] ?? 0,
      orders: data['orders'] ?? 0,
    );
  }

  factory User.initial() {
    return User(
      id: 0,
      name: '',
      phone: '',
      email: '',
      lang: '',
      card: '',
      formaterCard: '',
      discount: 0,
      isMailVerified: false,
      bonus: 0,
      orders: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'lang': lang,
      'card': card,
      'formatted_card': formaterCard,
      'discount': discount,
      'is_mail_verified': isMailVerified,
      'bonus': bonus,
      'orders': orders,
    };
  }
}
