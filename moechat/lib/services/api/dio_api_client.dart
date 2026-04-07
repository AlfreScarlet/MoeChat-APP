import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/error_handler.dart';
import '../../models/assistant.dart';
import 'api_client_interface.dart';

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
          .map((json) => _parseAssistant(json as Map<String, dynamic>))
          .toList();

      developer.log('✅ 获取助手列表成功: ${list.length}个', name: 'DioAssistantApiClient');
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
      return _parseAssistant(data['data'] as Map<String, dynamic>);
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
      return _parseAssistant(response.data['data'] as Map<String, dynamic>);
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
    if (settings != null) data['settings'] = _featureSettingsToJson(settings);
    if (gsvSetting != null) data['gsvSetting'] = _gsvSettingsToJson(gsvSetting);

    try {
      final response = await _dio.post('/assistant/info/add', data: data);
      final assistant = _parseAssistant(response.data['data'] as Map<String, dynamic>);

      developer.log('✅ 添加助手成功: ${assistant.name}', name: 'DioAssistantApiClient');
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
    if (settings != null) data['settings'] = _featureSettingsToJson(settings);
    if (gsvSetting != null) data['gsvSetting'] = _gsvSettingsToJson(gsvSetting);

    try {
      final response = await _dio.post('/assistant/info/update', data: data);
      final assistant = _parseAssistant(response.data['data'] as Map<String, dynamic>);

      developer.log('✅ 更新助手成功: ${assistant.name}', name: 'DioAssistantApiClient');
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

  Assistant _parseAssistant(Map<String, dynamic> json) {
    return Assistant(
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      description: json['description'] as String? ?? '',
      birthday: json['birthday'] as String? ?? '',
      height: json['height']?.toString() ?? '',
      weight: json['weight']?.toString() ?? '',
      personality: json['personality'] as String?,
      roleDescription: json['description'] as String?,
      userNickname: json['user'] as String?,
      userSetting: json['mask'] as String?,
      customPrompt: json['customPrompt'] as String?,
      messageExamples: (json['messageExamples'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      greetings: (json['startWith'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      extraDescription: json['extraDescription'] as String?,
      loveLevel: json['love'] as int? ?? 0,
      firstMeet: _formatTimestamp(json['firstMeetTime']),
      lastUpdate: _formatTimestamp(json['updatedAt']),
      assetsLastModified: (json['assetsLastModified'] as num? ?? 0).toDouble(),
      gsv: _parseGsvSettings(json['gsvSetting'] as Map<String, dynamic>?),
      features: _parseFeatureSettings(json['settings'] as Map<String, dynamic>?),
      emotionConfig: json['emotionSetting']?.toString(),
    );
  }

  GsvSettings _parseGsvSettings(Map<String, dynamic>? json) {
    if (json == null) return const GsvSettings();
    return GsvSettings(
      textLang: json['textLang'] as String?,
      gptModelPath: json['gptModelPath'] as String?,
      sovitsModelPath: json['sovitsModelPath'] as String?,
      refAudioPath: json['refAudioPath'] as String?,
      promptText: json['promptText'] as String?,
      promptLang: json['promptLang'] as String?,
      seed: json['seed'] as int?,
      topK: json['topK'] as int?,
      batchSize: json['batchSize'] as int?,
      textSplitMethod: json['extra']?['text_split_method'] as String?,
      extraRefAudio: json['extraRefAudio']?.toString(),
    );
  }

  FeatureSettings _parseFeatureSettings(Map<String, dynamic>? json) {
    if (json == null) {
      return const FeatureSettings(
        contextLength: 40,
        diary: false,
        diarySearchBoost: false,
        diarySearchThreshold: 0.32,
        coreMemory: false,
        worldBook: false,
        worldBookThreshold: 0.5,
        worldBookDepth: 3,
        emotionSystem: false,
        emotionPersist: false,
      );
    }
    return FeatureSettings(
      contextLength: json['contextLength'] as int? ?? 40,
      diary: json['enableLongMemory'] as bool? ?? false,
      diarySearchBoost: json['enableLongMemorySearchEnhance'] as bool? ?? false,
      diarySearchThreshold: (json['longMemoryThreshold'] as num?)?.toDouble() ?? 0.32,
      coreMemory: json['enableCoreMemory'] as bool? ?? false,
      worldBook: json['enableLoreBooks'] as bool? ?? false,
      worldBookThreshold: (json['loreBooksThreshold'] as num?)?.toDouble() ?? 0.5,
      worldBookDepth: json['loreBooksDepth'] as int? ?? 3,
      emotionSystem: json['enableEmotionSystem'] as bool? ?? false,
      emotionPersist: json['enableEmotionPersist'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _featureSettingsToJson(FeatureSettings settings) {
    return {
      'contextLength': settings.contextLength,
      'enableLongMemory': settings.diary,
      'enableLongMemorySearchEnhance': settings.diarySearchBoost,
      'longMemoryThreshold': settings.diarySearchThreshold,
      'enableCoreMemory': settings.coreMemory,
      'enableLoreBooks': settings.worldBook,
      'loreBooksThreshold': settings.worldBookThreshold,
      'loreBooksDepth': settings.worldBookDepth,
      'enableEmotionSystem': settings.emotionSystem,
      'enableEmotionPersist': settings.emotionPersist,
    };
  }

  Map<String, dynamic> _gsvSettingsToJson(GsvSettings settings) {
    final json = <String, dynamic>{
      'textLang': settings.textLang ?? 'zh',
      'promptLang': settings.promptLang ?? 'zh',
      'seed': settings.seed ?? -1,
      'topK': settings.topK ?? 30,
      'batchSize': settings.batchSize ?? 20,
    };

    json['gptModelPath'] = settings.gptModelPath ?? '';
    json['sovitsModelPath'] = settings.sovitsModelPath ?? '';
    json['refAudioPath'] = settings.refAudioPath ?? '';
    json['promptText'] = settings.promptText ?? '';
    if (settings.textSplitMethod != null) {
      json['extra'] = {'text_split_method': settings.textSplitMethod};
    }

    return json;
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final seconds = (timestamp is String)
          ? double.parse(timestamp)
          : (timestamp as num).toDouble();
      final date = DateTime.fromMillisecondsSinceEpoch(
        (seconds * 1000).toInt(),
      );
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
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
        assetsLastModified: (data['assetsLastModified'] as num? ?? 0).toDouble(),
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
