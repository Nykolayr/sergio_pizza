import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/data/api/api.dart';
import 'package:sergio_pizza/data/api/dio_client.dart';
import 'package:sergio_pizza/data/geolocation_servise.dart';
import 'package:sergio_pizza/domain/models/main_repository.dart';
import 'package:sergio_pizza/domain/repository/user_repository.dart';
import 'package:sergio_pizza/presentation/screen/auth/bloc/auth_bloc.dart';

/// внедряем зависимости
Future initMain() async {
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

  // try {
  //   Get.put<MainBloc>(MainBloc());
  //   Get.find<MainBloc>().add(GetUserEvent());
  // } catch (e) {
  //   Logger.e('MainBloc error = $e');
  //   return 'bloc $e';
  // }
  await Future.delayed(const Duration(seconds: 2));
  return '';
}
