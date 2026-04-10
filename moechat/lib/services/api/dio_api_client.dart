import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;

import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../../models/assistant.dart';
import 'api_client_interface.dart';
import 'assistant_parser.dart';

/// Dio implementation of [AssistantApiClient].
class DioAssistantApiClient implements AssistantApiClient {
  final dio.Dio _dio;
  final String? _baseUrl;

  DioAssistantApiClient(this._dio, this._baseUrl);

  void _ensureInitialized() {
    if (_baseUrl == null) {
      throw ApiException.notInitialized();
    }
  }

  @override
  Future<List<Assistant>> fetchAssistants() async {
    _ensureInitialized();

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

      developer.log(
        '✅ 获取助手列表成功: ${list.length}个',
        name: 'DioAssistantApiClient',
      );
      return list;
    } on dio.DioException catch (e) {
      throw _handleDioError(e, '获取助手列表');
    } catch (e, st) {
      throw ErrorHandler.handle(e, stackTrace: st);
    }
  }

  @override
  Future<Assistant?> fetchCurrentAssistant() async {
    _ensureInitialized();

    try {
      final response = await _dio.get('/assistant/current');
      final data = response.data;

      if (data['data'] == null) return null;
      return AssistantParser.parseAssistant(
        data['data'] as Map<String, dynamic>,
      );
    } on dio.DioException catch (e) {
      throw _handleDioError(e, '获取当前助手');
    } catch (e, st) {
      throw ErrorHandler.handle(e, stackTrace: st);
    }
  }

  @override
  Future<Assistant> switchAssistant(String name) async {
    _ensureInitialized();

    try {
      final response = await _dio.post(
        '/assistant/switch',
        data: {'name': name},
      );
      return AssistantParser.parseAssistant(
        response.data['data'] as Map<String, dynamic>,
      );
    } on dio.DioException catch (e) {
      throw _handleDioError(e, '切换助手');
    } catch (e, st) {
      throw ErrorHandler.handle(e, stackTrace: st);
    }
  }

  @override
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
    _ensureInitialized();

    final data = <String, dynamic>{
      'name': name,
      'avatar': avatar,
      'birthday': birthday,
      'height': height,
      'weight': weight,
      'personality': personality,
      'description': description,
    };

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

      developer.log(
        '✅ 添加助手成功: ${assistant.name}',
        name: 'DioAssistantApiClient',
      );
      return assistant;
    } on dio.DioException catch (e) {
      throw _handleDioError(e, '添加助手');
    } catch (e, st) {
      throw ErrorHandler.handle(e, stackTrace: st);
    }
  }

  @override
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
    _ensureInitialized();

    final data = <String, dynamic>{'name': name};

    if (avatar != null) data['avatar'] = avatar;
    if (birthday != null) data['birthday'] = birthday;
    if (height != null) data['height'] = height;
    if (weight != null) data['weight'] = weight;
    if (personality != null) data['personality'] = personality;
    if (description != null) data['description'] = description;
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

      developer.log(
        '✅ 更新助手成功: ${assistant.name}',
        name: 'DioAssistantApiClient',
      );
      return assistant;
    } on dio.DioException catch (e) {
      throw _handleDioError(e, '更新助手');
    } catch (e, st) {
      throw ErrorHandler.handle(e, stackTrace: st);
    }
  }

  @override
  Future<void> deleteAssistant(String name) async {
    _ensureInitialized();

    try {
      await _dio.post('/assistant/info/delete', data: {'name': name});
      developer.log('✅ 删除助手成功: $name', name: 'DioAssistantApiClient');
    } on dio.DioException catch (e) {
      throw _handleDioError(e, '删除助手');
    } catch (e, st) {
      throw ErrorHandler.handle(e, stackTrace: st);
    }
  }

  ApiException _handleDioError(dio.DioException e, String operation) {
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
    developer.log('❌ $errorMsg', name: 'DioAssistantApiClient', error: e);
    return ApiException(errorMsg, originalError: e);
  }
}

/// Dio implementation of [AssetsApiClient].
class DioAssetsApiClient implements AssetsApiClient {
  final dio.Dio _dio;
  final String? _baseUrl;

  DioAssetsApiClient(this._dio, this._baseUrl);

  void _ensureInitialized() {
    if (_baseUrl == null) {
      throw ApiException.notInitialized();
    }
  }

  @override
  Future<AssetsUpdateResult> checkAssetsUpdate(
    String name,
    double lastModified,
  ) async {
    _ensureInitialized();

    try {
      final response = await _dio.post(
        '/assistant/assets/check',
        data: {'name': name, 'lastModified': lastModified},
      );

      final data = response.data as Map<String, dynamic>;
      return AssetsUpdateResult(
        needsUpdate: data['needsUpdate'] as bool? ?? false,
        assetsLastModified: (data['assetsLastModified'] as num? ?? 0)
            .toDouble(),
      );
    } on dio.DioException catch (e) {
      throw _handleDioError(e, '检查资源更新');
    } catch (e, st) {
      throw ErrorHandler.handle(e, stackTrace: st);
    }
  }

  @override
  Future<Uint8List> downloadAssets(String name) async {
    _ensureInitialized();

    try {
      final response = await _dio.post(
        '/assistant/assets/download',
        data: {'name': name},
        options: dio.Options(responseType: dio.ResponseType.bytes),
      );

      return Uint8List.fromList(response.data as List<int>);
    } on dio.DioException catch (e) {
      throw _handleDioError(e, '下载资源包');
    } catch (e, st) {
      throw ErrorHandler.handle(e, stackTrace: st);
    }
  }

  @override
  Future<void> uploadAssets(String name, Uint8List zipData) async {
    _ensureInitialized();

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
      throw _handleDioError(e, '上传资源包');
    } catch (e, st) {
      throw ErrorHandler.handle(e, stackTrace: st);
    }
  }

  ApiException _handleDioError(dio.DioException e, String operation) {
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
    developer.log('❌ $errorMsg', name: 'DioAssetsApiClient', error: e);
    return ApiException(errorMsg, originalError: e);
  }
}
