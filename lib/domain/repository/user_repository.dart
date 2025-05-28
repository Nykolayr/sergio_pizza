import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/common/function.dart';
import 'package:sergio_pizza/data/api/api.dart';
import 'package:sergio_pizza/data/local_data.dart';
import 'package:sergio_pizza/data/secure_storage_servis.dart';
import 'package:sergio_pizza/domain/models/response_api.dart';
import 'package:sergio_pizza/domain/models/user.dart';
import 'package:sergio_pizza/domain/routers/routers.dart';
import 'package:sergio_pizza/data/geolocation_servise.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// репо для юзера
class UserRepository extends GetxController {
  String token = '';
  User user = User.initial();
  bool isRefresh = false;

  bool get isReg => token.isNotEmpty;

  static final UserRepository _instance = UserRepository._internal();

  UserRepository._internal();

  factory UserRepository() => _instance;

  Future<bool> deleteUser() async {
    return false;
  }

  /// Начальная загрузка пользователя из локального хранилища
  Future init() async {
    // LocalData().clear();
    token = await SecureStorageService().getToken() ?? '';
    await loadUserFromLocal();
    Logger.i('token >>>>> $token');
  }

  /// регистрация пользователя
  Future<String> regUser({
    required String name,
    required String birthDate,
    required String phone,
    required String email,
    required String password,
  }) async {
    final answer = await Api().regUserPhone(
        name: name,
        birthDate: birthDate,
        email: email,
        phone: phone,
        password: password);
    if (answer is ResSuccess) {
      token = answer.data['token'];
      await SecureStorageService().saveToken(token);
      user.name = name;
      user.birthDate = parseRuDate(birthDate);
      user.phone = phone;

      // Получение геопозиции пользователя
      try {
        final position = await GeolocationService.instance.getCurrentPosition();
        user.point =
            Point(latitude: position.latitude, longitude: position.longitude);
      } catch (e) {
        Logger.e('error getCurrentPosition $e');
      }

      await saveUserToLocal();
      return '';
    } else if (answer is ResError) {
      return answer.errorMessage;
    }
    return '';
  }

  Future<void> logout() async {
    await LocalData().clear();
    await SecureStorageService().deleteToken();
    user = User.initial();
  }

  Future<void> deleteAccount() async {
    await Api().logout();
    await logout();
  }

  Future<String> refreshToken() async {
    if (isRefresh) {
      return '';
    }
    isRefresh = true;
    Future.delayed(const Duration(seconds: 15), () {
      isRefresh = false;
    });
    token = await SecureStorageService().getToken() ?? '';
    final response = await Api().refreshToken();
    if (response is ResError) {
      Logger.i('refreshToken error >>>>> ${response.errorMessage}');
      await Future.delayed(const Duration(seconds: 3));
      final context = router.routerDelegate.navigatorKey.currentContext;
      if (context != null) {
        router.push('/auth', extra: false);
      }
      return response.errorMessage;
    }
    if (response is ResSuccess) {
      token = response.data['token'];
      await SecureStorageService().saveToken(token);
      return '';
    }
    return '';
  }

  /// отправка запроса на код в смс
  Future<String> sendAccept({required String phone}) async {
    final answer = await Api().sendAccept(phone: phone);
    if (answer is ResSuccess) {
      return '';
    } else if (answer is ResError) {
      return answer.errorMessage;
    }
    return '';
  }

  /// отправка запроса на код в смс
  Future<String> sendCode({required String phone, required String code}) async {
    final answer = await Api().checkCode(phone: phone, code: code);
    if (answer is ResSuccess) {
      return '';
    } else if (answer is ResError) {
      return answer.errorMessage;
    }
    return '';
  }

  /// апдейт пользователя
  Future<String> updateUser({required User user}) async {
    final answer = await Api().updateUser(user: user);
    if (answer is ResSuccess) {
      return '';
    } else if (answer is ResError) {
      return answer.errorMessage;
    }
    return '';
  }

  /// получить изера
  Future<String> getUser() async {
    Logger.i('getUser token >>>>> $token');
    final response = await Api().getUser();
    if (response is ResSuccess) {
      // user = User.fromJson(response.data);
      // saveUserToLocal();
      return '';
    } else if (response is ResError) {
      Logger.e('error getUser ${response.errorMessage}');
      return response.errorMessage;
    }
    return '';
  }

  /// Удаление пользователя из локального хранилища и инициализация
  Future clearUser() async {
    await LocalData().clear();
    await SecureStorageService().deleteToken();
    user = User.initial();
  }

  /// Авторизация пользователя
  Future<String> authPhone({
    required String phone,
    required String password,
  }) async {
    final answer = await Api().authPhone(phone: phone, password: password);
    if (answer is ResSuccess) {
      token = answer.data['token'];
      await SecureStorageService().saveToken(token);
      final resultUser = await loadUserFromApi();
      if (resultUser.isNotEmpty) {
        await saveUserToLocal();
      } else {
        await SecureStorageService().deleteToken();
        return resultUser;
      }
      return '';
    } else if (answer is ResError) {
      return answer.errorMessage;
    }
    return '';
  }

  /// загрузка пользователя из api
  Future<String> loadUserFromApi() async {
    final answer = await Api().getUser();
    if (answer is ResSuccess) {
      user = User.fromJson(answer.data);
      return '';
    } else if (answer is ResError) {
      Logger.e('error loadUserFromApi ${answer.errorMessage}');
      return answer.errorMessage;
    }
    return '';
  }

  /// Загрузка пользователя из локального хранилища
  Future<void> loadUserFromLocal() async {
    try {
      final data = await LocalData.loadJson(key: LocalDataKey.user);
      Logger.e('loadUserFromLocal $data');
      if (data['error'] == null) {
        user = User.fromJson(data);
      } else {
        await saveUserToLocal();
      }
    } catch (e) {
      Logger.e('user error $e');
      try {
        await saveUserToLocal();
      } catch (e) {
        Logger.e('saveUserToLocal error $e');
      }
    }
  }

  /// Сохранение пользователя в локальное хранилище
  Future<void> saveUserToLocal() async {
    await LocalData.saveJson(json: user.toJson(), key: LocalDataKey.user);
  }

  /// Сохранение истории сессий в локальное хранилище
}
