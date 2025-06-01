import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/data/api/api.dart';
import 'package:sergio_pizza/data/local_data.dart';
import 'package:sergio_pizza/data/secure_storage_servis.dart';
import 'package:sergio_pizza/domain/models/response_api.dart';
import 'package:sergio_pizza/domain/models/user.dart';
import 'package:sergio_pizza/domain/routers/routers.dart';
import 'package:sergio_pizza/data/geolocation_servise.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:sergio_pizza/domain/models/delivery_address.dart';
import 'package:sergio_pizza/domain/models/pickup_address.dart';
import 'package:sergio_pizza/domain/models/delivery_type.dart';

/// репо для юзера
class UserRepository extends GetxController {
  String token = '';
  User user = User.initial();
  bool isRefresh = false;

  bool get isReg => token.isNotEmpty;
  bool get hasDeliveryAddress => user.deliveryAddress.isNotEmpty;
  bool get hasPickupAddress => user.pickupAddress.isNotEmpty;
  bool get hasAnyAddress => hasDeliveryAddress || hasPickupAddress;

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
  }

  /// регистрация пользователя
  Future<String> regUser({
    required String name,
    required String birthDate,
    required String phone,
    required String email,
    required String password,
  }) async {
    final answer = await Api().updateUser(
      name: name,
      birthDate: birthDate,
      email: email,
      password: password,
    );
    if (answer is ResSuccess) {
      user = User.fromJsonApi(answer.data);
      // Получение геопозиции пользователя
      try {
        final position = await GeolocationService.instance.getCurrentPosition();
        user = user.copyWith(
          point: Point(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        );
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
    await LocalData.saveJson(
        json: User.initial().toJson(), key: LocalDataKey.user);
    await SecureStorageService().deleteToken();
    user = User.initial();
    token = '';
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

  /// отправка телефона для авторизации
  Future<Map<String, dynamic>> tryLogin({required String phone}) async {
    final answer = await Api().tryLoginApi(phone: phone);
    if (answer is ResSuccess) {
      return answer.data;
    } else if (answer is ResError) {
      return {'error': answer.errorMessage};
    }
    return {};
  }

  /// отправка запроса на код в смс
  Future<Map<String, dynamic>> sendAccept({required String phone}) async {
    final answer = await Api().sendAccept(phone: phone);
    if (answer is ResSuccess) {
      return answer.data;
    } else if (answer is ResError) {
      return {'error': answer.errorMessage};
    }
    return {};
  }

  /// отправка запроса на код в смс
  Future<String> sendCode({required String phone, required String code}) async {
    final answer = await Api().checkCode(phone: phone, code: code);
    if (answer is ResSuccess) {
      if (answer.data['data'] != null && answer.data['data']['token'] != null) {
        token = answer.data['data']['token'];

        await SecureStorageService().saveToken(token);
      }
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
      user = User.fromJsonApi(response.data);
      saveUserToLocal();
      return '';
    } else if (response is ResError) {
      Logger.e('error getUser ${response.errorMessage}');
      return response.errorMessage;
    }
    return '';
  }

  /// Удаление пользователя из локального хранилища и инициализация
  Future clearUser() async {
    await LocalData.saveJson(
        json: User.initial().toJson(), key: LocalDataKey.user);
    await SecureStorageService().deleteToken();
    user = User.initial();
    token = '';
  }

  /// Авторизация пользователя
  Future<String> authPhone({
    required String phone,
    required String password,
  }) async {
    final answer = await Api().authPhone(phone: phone, password: password);
    if (answer is ResSuccess) {
      if (answer.data['data'] != null && answer.data['data']['token'] != null) {
        token = answer.data['data']['token'];
        await SecureStorageService().saveToken(token);
        final resultUser = await loadUserFromApi();
        if (resultUser.isEmpty) {
          await saveUserToLocal();
        } else {
          await SecureStorageService().deleteToken();
          return resultUser;
        }
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
      user = User.fromJsonApi(answer.data);
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

  /// Сохранение адреса доставки
  Future<void> setDeliveryAddress(DeliveryAddress address) async {
    user = user.copyWith(deliveryAddress: address);
    await saveUserToLocal();
  }

  /// Сохранение адреса самовывоза
  Future<void> setPickupAddress(PickupAddress address) async {
    user = user.copyWith(pickupAddress: address);
    await saveUserToLocal();
  }

  /// Изменение типа доставки
  Future<void> setDeliveryType(DeliveryType type) async {
    user = user.copyWith(deliveryType: type);
    await saveUserToLocal();
  }
}
