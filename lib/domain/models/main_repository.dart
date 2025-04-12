import 'dart:async';
import 'package:get/get.dart';

/// репо  для всего приложения
class MainRepository extends GetxController {
  static final MainRepository _instance = MainRepository._internal();

  MainRepository._internal();

  factory MainRepository() => _instance;

  /// Начальная загрузка
  Future init() async {
    // LocalData().clear();
  }
}
