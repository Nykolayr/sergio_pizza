import 'dart:async';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:get/get.dart';
import 'package:sergio_pizza/data/api/api.dart';
import 'package:sergio_pizza/domain/models/establishment.dart';
import 'package:sergio_pizza/domain/models/response_api.dart';

/// репо для всего приложения
class MainRepository extends GetxController {
  static final MainRepository _instance = MainRepository._internal();

  MainRepository._internal();

  factory MainRepository() => _instance;

  final Api _api = Get.find<Api>();

  List<Establishment> _establishments = [];

  List<Establishment> get establishments => _establishments;

  /// Начальная загрузка
  Future init() async {
    // Загружаем заведения при старте приложения
    await loadEstablishments();
  }

  // Загружаем заведения
  Future<String> loadEstablishments() async {
    try {
      final response = await _api.getEstablishments();

      if (response is ResSuccess) {
        final data = response.data['data'] as List;
        _establishments =
            data.map((json) => Establishment.fromJson(json)).toList();
        Logger.i('Загружено ${_establishments.length} заведений');
        return 'success';
      } else if (response is ResError) {
        Logger.e('Ошибка загрузки заведений: ${response.errorMessage}');
        _establishments = [];
        return response.errorMessage;
      }
    } catch (e) {
      String errorMessage = 'Ошибка загрузки заведений: $e';
      Logger.e(errorMessage);
      _establishments = [];
      return errorMessage;
    }
    return '';
  }
}
