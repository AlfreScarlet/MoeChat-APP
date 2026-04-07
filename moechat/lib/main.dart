import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/constants/timeout_constants.dart';
import 'repositories/assistant_repository.dart';
import 'services/api/dio_api_client.dart';
import 'services/api_service.dart';
import 'services/audio_service.dart';
import 'services/loading_service.dart';
import 'services/recording_service.dart';
import 'services/socket_service.dart';
import 'controllers/home_controller.dart';
import 'controllers/settings_controller.dart';
import 'pages/home_page.dart';
import 'theme/app_theme.dart';

/// Global JSON encoder with indentation for debug logging.
const jsonEncoder = JsonEncoder.withIndent('  ');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsController.init();

  debugPrint('========================================');
  debugPrint('🚀 MoeChat 应用启动成功');
  debugPrint('📦 版本: 1.0.0+1 (Refactored)');
  debugPrint('========================================');

  // Pre-initialize audio service (global singleton)
  final audioService = AudioService();
  await audioService.init();
  Get.put(audioService);

  runApp(const MoeChatApp());
}

class MoeChatApp extends StatelessWidget {
  const MoeChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildThemeData(),
      initialBinding: _AppBindings(),
      builder: (context, child) {
        return DefaultTextStyle.merge(
          style: AppTheme.cjkStyle(),
          child: child!,
        );
      },
      home: const HomePage(),
    );
  }
}

/// Application dependency injection bindings.
class _AppBindings extends Bindings {
  @override
  void dependencies() {
    // Core services (legacy compatibility layer)
    final apiService = ApiService();
    Get.put(apiService);

    // New architecture: Dio HTTP client with debug logging
    final dioClient = _createDioClient();

    // New architecture: API clients
    final assistantApiClient = DioAssistantApiClient(
      dioClient,
      null, // Base URL set later via initialize()
    );
    // final assetsApiClient = DioAssetsApiClient(
    //   dioClient,
    //   null, // Base URL set later via initialize()
    // );

    // New architecture: Repositories
    Get.put<AssistantRepository>(
      AssistantRepositoryImpl(assistantApiClient),
    );

    // Legacy services
    Get.put(SocketService());
    Get.put(RecordingService());
    Get.put(LoadingService(), permanent: true);

    // Controllers
    Get.put(SettingsController());
    Get.put(HomeController());
  }

  /// Creates a configured Dio instance with debug logging.
  dio.Dio _createDioClient() {
    return dio.Dio(
      dio.BaseOptions(
        connectTimeout: TimeoutConstants.connectTimeout,
        receiveTimeout: TimeoutConstants.receiveTimeout,
        sendTimeout: TimeoutConstants.sendTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    )..interceptors.add(_DebugInterceptor());
  }
}

/// Debug logging interceptor for Dio.
class _DebugInterceptor extends dio.Interceptor {
  @override
  void onRequest(dio.RequestOptions options, dio.RequestInterceptorHandler handler) {
    final uri = '${options.baseUrl}${options.path}';
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════')
      ..writeln('║ ➡️  REQUEST')
      ..writeln('║ ${options.method} $uri')
      ..writeln('║ Headers: ${options.headers}');

    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('║ Query: ${options.queryParameters}');
    }

    if (options.data != null) {
      _writeBody(buffer, options.data);
    }

    buffer.writeln('╚══════════════════════════════════════');
    debugPrint(buffer.toString());

    handler.next(options);
  }

  @override
  void onResponse(dio.Response response, dio.ResponseInterceptorHandler handler) {
    final req = response.requestOptions;
    final uri = '${req.baseUrl}${req.path}';
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════')
      ..writeln('║ ✅ RESPONSE')
      ..writeln('║ ${response.statusCode} ${req.method} $uri');

    if (response.data != null) {
      _writeBody(buffer, response.data, isBinary: req.responseType == dio.ResponseType.bytes);
    }

    buffer.writeln('╚══════════════════════════════════════');
    debugPrint(buffer.toString());

    handler.next(response);
  }

  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) {
    final req = err.requestOptions;
    final uri = '${req.baseUrl}${req.path}';
    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════')
      ..writeln('║ ❌ ERROR')
      ..writeln('║ ${err.type} ${req.method} $uri')
      ..writeln('║ Message: ${err.message}');

    if (err.response != null) {
      buffer.writeln('║ Status: ${err.response?.statusCode}');
      _writeBody(buffer, err.response?.data);
    }

    buffer.writeln('╚══════════════════════════════════════');
    debugPrint(buffer.toString());

    handler.next(err);
  }

  void _writeBody(StringBuffer buffer, dynamic data, {bool isBinary = false}) {
    try {
      if (data is dio.FormData) {
        buffer.writeln('║ Body: [FormData] fields=${data.fields.length}, files=${data.files.length}');
      } else if (isBinary || data is List<int>) {
        final len = data is List ? data.length : '?';
        buffer.writeln('║ Body: [Binary] $len bytes');
      } else {
        final pretty = jsonEncoder.convert(data);
        buffer.writeln('║ Body:');
        for (final line in pretty.split('\n')) {
          buffer.writeln('║   $line');
        }
      }
    } catch (_) {
      buffer.writeln('║ Body: $data');
    }
  }
}
