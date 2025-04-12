import 'package:dio/dio.dart';
import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:sergio_pizza/presentation/widgets/alerts.dart';

class DioExceptions implements Exception {
  late String errorText;

  DioExceptions.fromDioError(DioException dioError) {
    Logger.e(
      ' dioError  ${dioError.requestOptions.method} ${dioError.requestOptions.uri} ${dioError.requestOptions.data}',
    );
    Logger.i(
      'DioExceptions.fromDioError dioError $dioError ${dioError.response?.statusCode}',
    );
    switch (dioError.type) {
      case DioExceptionType.cancel:
        errorText = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        errorText = "Connection timeout with API server";
        break;
      case DioExceptionType.receiveTimeout:
        errorText = "Receive timeout in connection with API server";
        break;
      case DioExceptionType.badCertificate:
        errorText = "Неправильный сертификат";
        break;
      case DioExceptionType.badResponse:
        errorText = handleError(
          dioError.response?.statusCode,
          dioError.response?.data,
        );
        break;
      case DioExceptionType.sendTimeout:
        errorText = "Send timeout in connection with API server";
        break;
      case DioExceptionType.unknown:
        if (dioError.message != null &&
            dioError.message!.contains("SocketException")) {
          errorText = 'No Internet';
          break;
        }
        errorText = "Unexpected error occurred";
        break;
      default:
        errorText =
            "path:  ${dioError.requestOptions.uri}  message:  ${dioError.message}";
        break;
    }

    Logger.e('Ошибка fromDioError  $errorText');
    showErrorDialog(errorText);
  }

  String handleError(int? statusCode, dynamic error) {
    Logger.e('Ошибка handleError statusCode $statusCode error $error');
    String errorText = 'Ошибка handleError statusCode $statusCode error $error';

    switch (statusCode) {
      case 400:
        if (error is Map) {
          if (error['code'] == 3) {
            errorText = 'Data is busy, try to select other days';
          } else {
            errorText = 'Bad request error 400';
          }
        } else {
          errorText = 'Bad request error 400';
        }
        break;
      case 401:
        errorText = 'Unauthorized error 401';
        // Проверяем сообщение об ошибке
        if (error is Map && error['error'] == 'not auth') {
          // Пропускаем рефреш токена для ошибки не авторизации
          break;
        }

        break;
      case 403:
        errorText = 'Forbidden error 403';
        if (error['error'] != null) {
          errorText = error['error'];
        }
      case 404:
        errorText = 'ошибка 404, страница не найдена';

      case 422:
        if (error is Map && error['errors'] is Map) {
          final errors = error['errors'] as Map;
          final firstErrorKey = errors.keys.first;
          errorText = errors[firstErrorKey]?.first;
        } else {
          errorText = 'Unprocessable Entity error 422';
        }
        break;
      case 429:
        errorText = 'Too many requests error 429';
        break;
      case 500:
        errorText = 'Internal server error error 500';
      case 502:
        errorText = 'Bad gateway error 502';
      default:
        errorText = 'Oops something went wrong';
    }
    showErrorDialog(errorText);
    return errorText;
  }

  @override
  String toString() => errorText;
}
