import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/data/api/api.dart';
import 'package:sergio_pizza/data/api/dio_client.dart';
import 'package:sergio_pizza/data/device_service.dart';
import 'package:sergio_pizza/data/geolocation_servise.dart';
import 'package:sergio_pizza/domain/repository/main_repository.dart';

import 'package:sergio_pizza/domain/repository/user_repository.dart';
import 'package:sergio_pizza/presentation/screen/auth/bloc/auth_bloc.dart';
import 'package:sergio_pizza/presentation/screen/delivery_map/bloc/delivery_map_bloc.dart';
import 'package:sergio_pizza/presentation/screen/main/bloc/main_bloc.dart';

/// внедряем зависимости
Future initMain() async {
  // Инициализируем Device ID в самом начале
  try {
    final deviceId = await DeviceService.getDeviceId();
    Logger.i('Device ID initialized: $deviceId');
  } catch (e) {
    Logger.e('DeviceService initialization error = $e');
  }

  await Get.putAsync(() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  });

  try {
    await Get.putAsync(() async {
      final userRepository = UserRepository();
      await userRepository.init();
      return userRepository;
    });
  } catch (e) {
    Logger.e('UserRepository error1 = $e');
    return 'user $e';
  }
  try {
    Get.put<DioClient>(DioClient(Dio()));
    Get.put<Api>(Api());
  } catch (e) {
    Logger.e('DioClient error = $e');
    return 'DioClient $e';
  }
  try {
    Get.put<AuthBloc>(AuthBloc());
  } catch (e) {
    Logger.e('AuthBloc error = $e');
    return 'bloc $e';
  }

  try {
    await Get.putAsync(() async {
      final mainRepository = MainRepository();
      return mainRepository;
    });
  } catch (e) {
    Logger.e('MainRepository error = $e');
    return 'MainRepository $e';
  }

  try {
    Get.put<GeolocationService>(GeolocationService.instance);
  } catch (e) {
    Logger.e('GeolocationService error = $e');
    return 'GeolocationService $e';
  }

  try {
    await Get.find<MainRepository>().init();
  } catch (e) {
    Logger.e('MainRepository error = $e');
    return 'MainRepository $e';
  }

  try {
    Get.put<MainBloc>(MainBloc());
  } catch (e) {
    Logger.e('MainBloc error = $e');
    return 'bloc $e';
  }

  try {
    Get.put<DeliveryMapBloc>(DeliveryMapBloc());
  } catch (e) {
    Logger.e('DeliveryMapBloc error = $e');
    return 'bloc $e';
  }

  await Future.delayed(const Duration(seconds: 3));
  return '';
}
