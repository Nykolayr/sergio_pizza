import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DeviceService {
  static const String _deviceIdKey = 'device_id';
  static String? _cachedDeviceId;

  /// Получить уникальный идентификатор устройства
  static Future<String> getDeviceId() async {
    // Если уже есть кэшированный ID, возвращаем его
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    // Проверяем сохраненный ID в SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? savedDeviceId = prefs.getString(_deviceIdKey);

    if (savedDeviceId != null && savedDeviceId.isNotEmpty) {
      _cachedDeviceId = savedDeviceId;
      return savedDeviceId;
    }

    // Генерируем новый ID на основе информации об устройстве
    String deviceId = await _generateDeviceId();

    // Сохраняем в SharedPreferences
    await prefs.setString(_deviceIdKey, deviceId);
    _cachedDeviceId = deviceId;

    Logger.i('Generated new device ID: $deviceId');
    return deviceId;
  }

  /// Генерация уникального ID устройства
  static Future<String> _generateDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String identifier = '';

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // Используем комбинацию характеристик Android устройства
        identifier =
            '${androidInfo.model}_${androidInfo.brand}_${androidInfo.device}_${androidInfo.hardware}';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        // Используем identifierForVendor для iOS
        identifier = iosInfo.identifierForVendor ??
            '${iosInfo.model}_${iosInfo.systemVersion}';
      } else {
        // Для других платформ используем базовую информацию
        identifier =
            'unknown_platform_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      Logger.e('Error getting device info: $e');
      // Fallback: генерируем ID на основе времени
      identifier = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }

    // Создаем хэш для получения стабильного ID
    var bytes = utf8.encode(identifier);
    var digest = sha256.convert(bytes);

    return digest.toString().substring(0, 32); // Берем первые 32 символа
  }

  /// Очистить сохраненный Device ID (для тестирования)
  static Future<void> clearDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
    _cachedDeviceId = null;
  }
}
