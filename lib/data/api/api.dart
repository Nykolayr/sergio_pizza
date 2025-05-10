import 'package:sergio_pizza/data/api/dio_client.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/domain/models/response_api.dart';

class Api {
  final DioClient dio = Get.find<DioClient>();

  /// рефреш токена
  Future<ResponseApi> refreshToken() async {
    return await dio.post('/api/mobile/refresh');
  }

  /// регистрация
  Future<ResponseApi> apiRegUser({
    required String name,
    required String lastName,
    required String birthDate,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return ResSuccess({'token': '1234567890'});
    // return await dio.post('/api/mobile/reg', data: {'name': name, 'lastName': lastName, 'birthDate': birthDate});
  }

  /// проверка кода
  Future<ResponseApi> checkCode({required String code}) async {
    await Future.delayed(const Duration(seconds: 2));
    if (code == '5555') {
      return ResSuccess({'token': '1234567890'});
    } else {
      return ResError(errorMessage: 'Введен неверный код');
    }
    // return await dio.post('/api/mobile/check_code', data: {'code': code});
  }

  /// авторизация по телефону
  Future<ResponseApi> authPhone({
    required String phone,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return ResSuccess({'token': '1234567890'});
    // return await dio.post(
    //   '/api/mobile/login',
    //   data: {
    //     'identifier': phone,
    //   },
    // );
  }

  /// получить пользователя
  Future<ResponseApi> getUser({bool isLoyalty = true}) async {
    await Future.delayed(const Duration(seconds: 2));
    return ResSuccess({'token': '1234567890'});
    // return await dio.post('/api/mobile/user', data: {'loyalty': isLoyalty});
  }

  /// разлогиниться
  Future<ResponseApi> logout() async {
    return await dio.post('/api/mobile/logout');
  }

  /// разлогиниться со всех устройств
  Future<ResponseApi> logoutAll() async {
    return await dio.post('/api/mobile/logout/all');
  }
}
