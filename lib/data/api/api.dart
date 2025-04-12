import 'package:sergio_pizza/data/api/dio_client.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/models/response_api.dart';

class Api {
  final DioClient dio = Get.find<DioClient>();

  /// получить html политики
  Future<ResponseApi> getPrivacyPolicy(String lang) async {
    return await dio.get('/api/mobile/page/$lang/privacy_policy');
  }

  /// получить html terms_of_use
  Future<ResponseApi> getTermsOfUse(String lang) async {
    return await dio.get('/api/mobile/page/$lang/terms_of_use');
  }

  /// получить html about_the_app
  Future<ResponseApi> getAboutTheApp(String lang) async {
    return await dio.get('/api/mobile/page/$lang/about_the_app');
  }

  /// получить список изображений авто для кэша
  Future<ResponseApi> getItemAllImage() async {
    return await dio.get('/api/mobile/catalog/get_item_all_image');
  }

  /// получить список типов автомобилей
  Future<ResponseApi> getTypeAutos() async {
    return await dio.post('/api/mobile/catalog/get_types');
  }

  /// Получить банера
  Future<ResponseApi> getBanners({String brand = 'y'}) async {
    return await dio.get('/api/mobile/get_banner');
  }

  /// получить машину по id
  Future<ResponseApi> getCar(int carId) async {
    return await dio.post('/api/mobile/catalog/get_car', data: {"id": carId});
  }

  /// рефреш токена
  Future<ResponseApi> refreshToken() async {
    return await dio.post('/api/mobile/refresh');
  }

  /// проверка кода
  Future<ResponseApi> checkCode({required String code}) async {
    return await dio.post('/api/mobile/check_code', data: {'code': code});
  }

  /// регистрация по логину и паролю, возвращает токен
  Future<ResponseApi> registerUser({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    return await dio.post(
      '/api/mobile/register',
      data: {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      },
    );
  }

  /// авторизация по телефону
  Future<ResponseApi> authUserByPhone({
    required String phone,
    required String password,
  }) async {
    return await dio.post(
      '/api/mobile/login',
      data: {'identifier': phone, 'password': password},
    );
  }

  /// авторизация по логину и паролю
  Future<ResponseApi> authUserByEmail({
    required String mail,
    required String password,
  }) async {
    return await dio.post(
      '/api/mobile/login',
      data: {'identifier': mail, 'password': password},
    );
  }

  /// получить пользователя
  Future<ResponseApi> getUser({bool isLoyalty = true}) async {
    return await dio.post('/api/mobile/user', data: {'loyalty': isLoyalty});
  }

  /// разлогиниться
  Future<ResponseApi> logout() async {
    return await dio.post('/api/mobile/logout');
  }

  /// разлогиниться со всех устройств
  Future<ResponseApi> logoutAll() async {
    return await dio.post('/api/mobile/logout/all');
  }

  /// получить языки с сервера
  Future<ResponseApi> getLang() async {
    return await dio.get('/api/get_lang/list');
  }

  /// получить уровель лояльности
  Future<ResponseApi> getLoyalty() async {
    return await dio.post('/api/mobile/get_loyalty_level');
  }

  /// Получить только бренды
  Future<ResponseApi> getBrands({String brand = 'y'}) async {
    return await dio.post(
      '/api/mobile/catalog/get_section',
      data: {'brand': brand},
    );
  }

  /// Получение автомобилей
  Future<ResponseApi> getCars({
    int page = 1,
    int count = 5,
    String search = '',
    String section = '',
    int endPrice = 1500,
    int startPrice = 0,
    bool isAvailable = true,
    List<String> carBrands = const [],
    String dateStart = '',
    String dateEnd = '',
    String typeAuto = '',
  }) async {
    Map<String, dynamic> filter = {
      "section": section, //Секция по коду
      "search": search, //для поиска
      "page": page, //Страница каталога
      "count": count, //Количество на странице
      "from_date": dateStart,
      "to_date": dateEnd,
      "filter": {
        "price": startPrice,
        "end_price": endPrice,
        "carBrand": carBrands,
        "available": isAvailable,
        "type": typeAuto,
      },
    };
    return await dio.post('/api/mobile/catalog/get_cars', data: filter);
  }

  /// Получение забронированных дат автомобиля
  Future<ResponseApi> getBookedDates({required int carId}) async {
    Logger.i('getBookedDates $carId');
    return await dio.post(
      '/api/mobile/catalog/get_booked_dates',
      queryParameters: {'car_id': carId},
    );
  }

  /// Получение фильтров ввода
  Future<ResponseApi> getFilters() async {
    return await dio.post('/api/mobile/catalog/get_filter_input');
  }

  /// Получение данных с эндпоинта
  Future<ResponseApi> getAssetEndpoint() async {
    return await dio.get('/api/mobile/get_asset_endpoint');
  }
}
