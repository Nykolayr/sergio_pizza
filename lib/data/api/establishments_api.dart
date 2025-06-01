import 'package:sergio_pizza/domain/models/establishment.dart';
import 'package:sergio_pizza/domain/models/establishment_type.dart';
import 'package:sergio_pizza/main.dart';

class EstablishmentsApi {
  static const List<Map<String, dynamic>> _mockEstablishments = [
    {
      'id': '1',
      'address': 'Зеленоград, улица Академика Валиева, 2',
      'latitude': 56.009914,
      'longitude': 37.199164,
      'type': 'pickup',
      'working_hours': 'до 23:00',
      'status': 'Открыт',
      'estimated_time': 30,
    },
    {
      'id': '2',
      'address': 'Зеленоград, Центральный проспект, 1',
      'latitude': 56.005984,
      'longitude': 37.200350,
      'type': 'restaurant',
      'working_hours': 'до 22:30',
      'status': 'Открыт',
      'estimated_time': 25,
    },
    {
      'id': '3',
      'address': 'Зеленоград, корпус 1128',
      'latitude': 56.013090,
      'longitude': 37.221325,
      'type': 'pickup',
      'working_hours': 'до 23:00',
      'status': 'Открыт',
      'estimated_time': 35,
    },
    {
      'id': '4',
      'address': 'Зеленоград, корпус 1130А',
      'latitude': 56.013090,
      'longitude': 37.221325,
      'type': 'restaurant',
      'working_hours': 'до 23:30',
      'status': 'Временно закрыт',
      'estimated_time': null,
    },
    {
      'id': '5',
      'address': 'Зеленоград, корпус 1132',
      'latitude': 56.013090,
      'longitude': 37.221325,
      'type': 'pickup',
      'working_hours': 'до 22:00',
      'status': 'Открыт',
      'estimated_time': 40,
    },
    {
      'id': '6',
      'address': 'Андреевка, Жилинская улица, 1',
      'latitude': 55.971179,
      'longitude': 37.194133,
      'type': 'restaurant',
      'working_hours': 'до 23:00',
      'status': 'Открыт',
      'estimated_time': 20,
    },
  ];

  Future<List<Establishment>> getEstablishments() async {
    if (isMock) {
      // Имитируем задержку сети
      await Future.delayed(const Duration(milliseconds: 500));

      return _mockEstablishments
          .map((json) => Establishment.fromJson(json))
          .toList();
    } else {
      // Здесь будет реальный API запрос
      throw UnimplementedError('Real API not implemented yet');
    }
  }

  Future<List<Establishment>> searchEstablishments(String query) async {
    final allEstablishments = await getEstablishments();

    if (query.isEmpty) {
      return allEstablishments;
    }

    return allEstablishments.where((establishment) {
      return establishment.address.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<List<Establishment>> filterEstablishments({
    EstablishmentType? type,
    bool? onlyOpen,
  }) async {
    final allEstablishments = await getEstablishments();

    return allEstablishments.where((establishment) {
      if (type != null && establishment.type != type) {
        return false;
      }

      if (onlyOpen == true && !establishment.isOpen) {
        return false;
      }

      return true;
    }).toList();
  }
}
