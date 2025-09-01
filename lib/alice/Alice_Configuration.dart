import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_alice/alice.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioProvider {
  static final DioProvider _singleton = DioProvider._internal();
  static final PrettyDioLogger _logger = PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
      error: true,
      compact: false,
      maxWidth: 500,
      request: true);
  factory DioProvider() => _singleton;

  DioProvider._internal();

  late Dio dio;
  Alice alice = Alice(
      showNotification: true,
      showInspectorOnShake: true,
      notificationIcon: Headers.jsonContentType,
      darkTheme: true);

  void initAlice(Alice aliceInstance) {
    alice = aliceInstance;
    dio = Dio();
    dio.interceptors.add(alice.getDioInterceptor());
    dio.interceptors.add(_logger);
  }

  GlobalKey<NavigatorState>? get navigatorKey => alice.getNavigatorKey();
}
final dioProvider = DioProvider();