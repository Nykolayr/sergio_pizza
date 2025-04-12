import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GeolocationService {
  // Создаем приватный конструктор
  GeolocationService._privateConstructor();

  // Экземпляр синглтона
  static final GeolocationService _instance =
      GeolocationService._privateConstructor();

  // Метод для получения экземпляра
  static GeolocationService get instance => _instance;

  // Переменная для хранения последнего известного адреса
  String? _lastKnownAddress;

  // Получение текущих координат
  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Проверка, включена ли служба геолокации
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Проверка разрешений
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // Получение текущей позиции
    return await Geolocator.getCurrentPosition();
  }

  // Получение адреса по текущим координатам
  Future<String> getAddress() async {
    try {
      Position position = await _getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        _lastKnownAddress =
            '${place.street}, ${place.locality}, ${place.country}';
        return _lastKnownAddress!;
      } else {
        return _lastKnownAddress ?? 'No address available';
      }
    } catch (e) {
      return _lastKnownAddress ?? 'Error: ${e.toString()}';
    }
  }
}
