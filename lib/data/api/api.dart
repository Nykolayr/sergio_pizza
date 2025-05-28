import 'package:sergio_pizza/data/api/dio_client.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/models/response_api.dart';
import 'package:sergio_pizza/domain/models/user.dart';

class Api {
  final DioClient dio = Get.find<DioClient>();

  /// рефреш токена
  Future<ResponseApi> refreshToken() async {
    return await dio.post('/api/mobile/refresh');
  }

  /// апдейт пользователя
  Future<ResponseApi> updateUser({
    required User user,
  }) async {
    return await dio.post('/user', data: user.toJsonApi());
  }

  /// регистрация по телефону
  Future<ResponseApi> regUserPhone({
    required String phone,
    required String password,
    required String name,
    required String birthDate,
    required String email,
  }) async {
    return await dio.post('/login', data: {
      "name": name,
      "email": email,
      "phone": phone,
      "birthdate": birthDate,
      "password": password,
      "password_confirmation": password,
    });
  }

  /// отправка запроса на код в смс
  Future<ResponseApi> sendAccept({
    required String phone,
  }) async {
    return await dio.post('/sendAccept', data: {
      'phone': phone,
    });
  }

  /// проверка кода
  Future<ResponseApi> checkCode({
    required String code,
    required String phone,
  }) async {
    return await dio.post('/activateUser', data: {
      'code': code,
      'phone': phone,
    });
  }

  /// авторизация по телефону
  Future<ResponseApi> authPhone({
    required String phone,
    required String password,
  }) async {
    return await dio.post('/login', data: {
      "phone": phone,
      "password": password,
    });
  }

  /// получить пользователя
  Future<ResponseApi> getUser() async {
    return await dio.get('/user');
  }

  /// разлогиниться
  Future<ResponseApi> logout() async {
    return await dio.post('/logout');
  }

  /// разлогиниться со всех устройств
  Future<ResponseApi> logoutAll() async {
    return await dio.post('/api/mobile/logout/all');
  }
}
