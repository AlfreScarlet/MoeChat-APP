import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../core/constants/timeout_constants.dart';
import '../models/assistant.dart';
import 'api/assistant_parser.dart';

/// HTTP API 服务 - 助手管理接口
class ApiService extends GetxService {
  late dio.Dio _dio;
  String? _baseUrl;

  /// 初始化，设置 baseUrl
  void initialize(String baseUrl) {
    _baseUrl = baseUrl;
    developer.log('🌐 API 初始化: $baseUrl', name: 'ApiService');

    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: TimeoutConstants.connectTimeout,
        receiveTimeout: TimeoutConstants.receiveTimeout,
        sendTimeout: TimeoutConstants.sendTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // 详细调试拦截器 — 打印完整请求/响应
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          final uri = '${options.baseUrl}${options.path}';
          final buf = StringBuffer()
            ..writeln('╔══════════════════════════════════════')
            ..writeln('║ ➡️  REQUEST')
            ..writeln('║ ${options.method} $uri')
            ..writeln('║ Headers: ${options.headers}');
          if (options.queryParameters.isNotEmpty) {
            buf.writeln('║ Query: ${options.queryParameters}');
          }
          if (options.data != null) {
            try {
              if (options.data is dio.FormData) {
                final fd = options.data as dio.FormData;
                buf.writeln(
                  '║ Body: [FormData] fields=${fd.fields}, '
                  'files=${fd.files.map((f) => '${f.key}:${f.value.filename}'
                      '(${f.value.length}bytes)').toList()}',
                );
              } else {
                final pretty = const JsonEncoder.withIndent(
                  '  ',
                ).convert(options.data);
                buf.writeln('║ Body:');
                for (final line in pretty.split('\n')) {
                  buf.writeln('║   $line');
                }
              }
            } catch (_) {
              buf.writeln('║ Body: ${options.data}');
            }
          }
          buf.writeln('╚══════════════════════════════════════');
          debugPrint(buf.toString());
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final req = response.requestOptions;
          final uri = '${req.baseUrl}${req.path}';
          final buf = StringBuffer()
            ..writeln('╔══════════════════════════════════════')
            ..writeln('║ ✅ RESPONSE')
            ..writeln('║ ${response.statusCode} ${req.method} $uri');
          if (response.data != null) {
            if (req.responseType == dio.ResponseType.bytes ||
                response.data is List<int>) {
              final len = response.data is List
                  ? (response.data as List).length
                  : '?';
              buf.writeln('║ Body: [Binary] $len bytes');
            } else {
              try {
                final pretty = const JsonEncoder.withIndent(
                  '  ',
                ).convert(response.data);
                buf.writeln('║ Body:');
                for (final line in pretty.split('\n')) {
                  buf.writeln('║   $line');
                }
              } catch (_) {
                final s = response.data.toString();
                buf.writeln(
                  '║ Body: ${s.length > 500 ? '${s.substring(0, 500)}...' : s}',
                );
              }
            }
          }
          buf.writeln('╚══════════════════════════════════════');
          debugPrint(buf.toString());
          return handler.next(response);
        },
        onError: (error, handler) {
          final req = error.requestOptions;
          final uri = '${req.baseUrl}${req.path}';
          final buf = StringBuffer()
            ..writeln('╔══════════════════════════════════════')
            ..writeln('║ ❌ ERROR')
            ..writeln('║ ${error.type} ${req.method} $uri')
            ..writeln('║ Message: ${error.message}');
          if (error.response != null) {
            buf.writeln('║ Status: ${error.response?.statusCode}');
            try {
              final pretty = const JsonEncoder.withIndent(
                '  ',
              ).convert(error.response?.data);
              buf.writeln('║ Response:');
              for (final line in pretty.split('\n')) {
                buf.writeln('║   $line');
              }
            } catch (_) {
              buf.writeln('║ Response: ${error.response?.data}');
            }
          }
          buf.writeln('╚══════════════════════════════════════');
          debugPrint(buf.toString());
          return handler.next(error);
        },
      ),
    );
  }

  bool get isInitialized => _baseUrl != null;

  // ==================== 查询接口 ====================

  /// GET /assistants - 获取所有助手
  Future<List<Assistant>> fetchAssistants() async {
    if (!isInitialized) throw Exception('ApiService not initialized');

    try {
      final response = await _dio.get('/assistants');
      final data = response.data;

      if (data['data'] == null) return [];

      final list = (data['data'] as List)
          .map(
            (json) =>
                AssistantParser.parseAssistant(json as Map<String, dynamic>),
          )
          .toList();

      developer.log('✅ 获取助手列表成功: ${list.length}个', name: 'ApiService');
      return list;
    } on dio.DioException catch (e) {
      _handleDioError(e, '获取助手列表');
      rethrow;
    }
  }

  /// GET /assistant/current - 获取当前助手
  Future<Assistant?> fetchCurrentAssistant() async {
    if (!isInitialized) throw Exception('ApiService not initialized');

    try {
      final response = await _dio.get('/assistant/current');
      final data = response.data;

      if (data['data'] == null) return null;
      return AssistantParser.parseAssistant(
        data['data'] as Map<String, dynamic>,
      );
    } on dio.DioException catch (e) {
      _handleDioError(e, '获取当前助手');
      rethrow;
    }
  }

  /// POST /assistant/switch - 切换助手
  Future<Assistant> switchAssistant(String name) async {
    if (!isInitialized) throw Exception('ApiService not initialized');

    try {
      final response = await _dio.post(
        '/assistant/switch',
        data: {'name': name},
      );
      return AssistantParser.parseAssistant(
        response.data['data'] as Map<String, dynamic>,
      );
    } on dio.DioException catch (e) {
      _handleDioError(e, '切换助手');
      rethrow;
    }
  }

  // ==================== 增删改接口 ====================

  /// POST /assistant/info/add - 添加助手
  Future<Assistant> addAssistant({
    required String name,
    required String avatar,
    required String birthday,
    required String height,
    required String weight,
    required String personality,
    required String description,
    String? user,
    String? mask,
    List<String>? messageExamples,
    String? extraDescription,
    String? customPrompt,
    List<String>? startWith,
    FeatureSettings? settings,
    GsvSettings? gsvSetting,
  }) async {
    if (!isInitialized) throw Exception('ApiService not initialized');

    final data = <String, dynamic>{
      'name': name,
      'avatar': avatar,
      'birthday': birthday,
      'height': height,
      'weight': weight,
      'personality': personality,
      'description': description,
    };

    // 可选字段
    if (user != null) data['user'] = user;
    if (mask != null) data['mask'] = mask;
    if (messageExamples != null) data['messageExamples'] = messageExamples;
    if (extraDescription != null) data['extraDescription'] = extraDescription;
    if (customPrompt != null) data['customPrompt'] = customPrompt;
    if (startWith != null) data['startWith'] = startWith;
    if (settings != null)
      data['settings'] = AssistantParser.featureSettingsToJson(settings);
    if (gsvSetting != null)
      data['gsvSetting'] = AssistantParser.gsvSettingsToJson(gsvSetting);

    try {
      final response = await _dio.post('/assistant/info/add', data: data);
      final assistant = AssistantParser.parseAssistant(
        response.data['data'] as Map<String, dynamic>,
      );

      developer.log('✅ 添加助手成功: ${assistant.name}', name: 'ApiService');

      return assistant;
    } on dio.DioException catch (e) {
      _handleDioError(e, '添加助手');
      rethrow;
    }
  }

  /// POST /assistant/info/update - 更新助手
  Future<Assistant> updateAssistant({
    required String name,
    String? avatar,
    String? birthday,
    String? height,
    String? weight,
    String? personality,
    String? description,
    String? user,
    String? mask,
    List<String>? messageExamples,
    String? extraDescription,
    String? customPrompt,
    List<String>? startWith,
    FeatureSettings? settings,
    GsvSettings? gsvSetting,
  }) async {
    if (!isInitialized) throw Exception('ApiService not initialized');

    final data = <String, dynamic>{'name': name};

    // 只传入需要更新的字段（空字符串/空列表也会传递，表示清空该字段）
    if (avatar != null) data['avatar'] = avatar;
    if (birthday != null) data['birthday'] = birthday;
    if (height != null) data['height'] = height;
    if (weight != null) data['weight'] = weight;
    if (personality != null) data['personality'] = personality;
    if (description != null) data['description'] = description;
    // 以下字段允许传空值（空字符串/空列表），以支持清空操作
    data['user'] = user ?? '';
    data['mask'] = mask ?? '';
    data['messageExamples'] = messageExamples ?? [];
    data['extraDescription'] = extraDescription ?? '';
    data['customPrompt'] = customPrompt ?? '';
    data['startWith'] = startWith ?? [];
    if (settings != null)
      data['settings'] = AssistantParser.featureSettingsToJson(settings);
    if (gsvSetting != null)
      data['gsvSetting'] = AssistantParser.gsvSettingsToJson(gsvSetting);

    try {
      final response = await _dio.post('/assistant/info/update', data: data);
      final assistant = AssistantParser.parseAssistant(
        response.data['data'] as Map<String, dynamic>,
      );

      developer.log('✅ 更新助手成功: ${assistant.name}', name: 'ApiService');

      return assistant;
    } on dio.DioException catch (e) {
      _handleDioError(e, '更新助手');
      rethrow;
    }
  }

  /// POST /assistant/info/delete - 删除助手
  Future<void> deleteAssistant(String name) async {
    if (!isInitialized) throw Exception('ApiService not initialized');

    try {
      await _dio.post('/assistant/info/delete', data: {'name': name});

      developer.log('✅ 删除助手成功: $name', name: 'ApiService');
    } on dio.DioException catch (e) {
      _handleDioError(e, '删除助手');
      rethrow;
    }
  }

  // ==================== 资源管理接口 ====================

  /// POST /assistant/assets/check - 检查资源更新
  Future<AssetsUpdateResult> checkAssetsUpdate(
    String name,
    double lastModified,
  ) async {
    if (!isInitialized) throw Exception('ApiService not initialized');

    try {
      final response = await _dio.post(
        '/assistant/assets/check',
        data: {'name': name, 'lastModified': lastModified},
      );

      final data = response.data;
      return AssetsUpdateResult(
        needsUpdate: data['needsUpdate'] ?? false,
        assetsLastModified: (data['assetsLastModified'] ?? 0).toDouble(),
      );
    } on dio.DioException catch (e) {
      _handleDioError(e, '检查资源更新');
      rethrow;
    }
  }

  /// POST /assistant/assets/download - 下载资源包
  Future<Uint8List> downloadAssets(String name) async {
    if (!isInitialized) throw Exception('ApiService not initialized');

    try {
      final response = await _dio.post(
        '/assistant/assets/download',
        data: {'name': name},
        options: dio.Options(responseType: dio.ResponseType.bytes),
      );

      return Uint8List.fromList(response.data);
    } on dio.DioException catch (e) {
      _handleDioError(e, '下载资源包');
      rethrow;
    }
  }

  /// POST /assistant/assets/upload - 上传资源包
  Future<void> uploadAssets(String name, Uint8List zipData) async {
    if (!isInitialized) throw Exception('ApiService not initialized');

    final formData = dio.FormData.fromMap({
      'name': name,
      'assets_zip': dio.MultipartFile.fromBytes(
        zipData,
        filename: 'assets.zip',
      ),
    });

    try {
      await _dio.post('/assistant/assets/upload', data: formData);
    } on dio.DioException catch (e) {
      _handleDioError(e, '上传资源包');
      rethrow;
    }
  }

  // ==================== 错误处理 ====================

  void _handleDioError(dio.DioException e, String operation) {
    String errorMsg;
    switch (e.type) {
      case dio.DioExceptionType.connectionTimeout:
      case dio.DioExceptionType.sendTimeout:
      case dio.DioExceptionType.receiveTimeout:
        errorMsg = '$operation 超时，请检查网络连接';
        break;
      case dio.DioExceptionType.connectionError:
        errorMsg = '$operation 连接失败，请检查服务器地址';
        break;
      case dio.DioExceptionType.badResponse:
        errorMsg = '$operation 服务器错误: ${e.response?.statusCode}';
        break;
      default:
        errorMsg = '$operation 失败: ${e.message}';
    }
    developer.log('❌ $errorMsg', name: 'ApiService', error: e);
  }

  // ==================== 数据解析 ====================
  // Delegated to AssistantParser — see lib/services/api/assistant_parser.dart
}
