import '../../core/constants/default_value_constants.dart';
import '../../models/assistant.dart';

/// Shared Assistant JSON parsing/serialization utility.
///
/// Eliminates duplicated parsing code between [ApiService] and
/// [DioAssistantApiClient].
class AssistantParser {
  const AssistantParser._();

  /// Parse a JSON map into an [Assistant] model.
  static Assistant parseAssistant(Map<String, dynamic> json) {
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
      loveLevel: json['love'] as int? ?? DefaultValueConstants.defaultLoveLevel,
      firstMeet: formatTimestamp(json['firstMeetTime']),
      lastUpdate: formatTimestamp(json['updatedAt']),
      assetsLastModified:
          (json['assetsLastModified'] as num? ??
                  DefaultValueConstants.defaultAssetsLastModified)
              .toDouble(),
      gsv: parseGsvSettings(json['gsvSetting'] as Map<String, dynamic>?),
      features: parseFeatureSettings(json['settings'] as Map<String, dynamic>?),
      emotionConfig: json['emotionSetting']?.toString(),
    );
  }

  /// Parse GSV voice synthesis settings from JSON.
  static GsvSettings parseGsvSettings(Map<String, dynamic>? json) {
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

  /// Parse feature toggle settings from JSON.
  static FeatureSettings parseFeatureSettings(Map<String, dynamic>? json) {
    if (json == null) {
      return const FeatureSettings(
        contextLength: DefaultValueConstants.contextLength,
        diary: false,
        diarySearchBoost: false,
        diarySearchThreshold: DefaultValueConstants.diarySearchThreshold,
        coreMemory: false,
        worldBook: false,
        worldBookThreshold: DefaultValueConstants.worldBookThreshold,
        worldBookDepth: DefaultValueConstants.worldBookDepth,
        emotionSystem: false,
        emotionPersist: false,
      );
    }
    return FeatureSettings(
      contextLength:
          json['contextLength'] as int? ?? DefaultValueConstants.contextLength,
      diary: json['enableLongMemory'] as bool? ?? false,
      diarySearchBoost: json['enableLongMemorySearchEnhance'] as bool? ?? false,
      diarySearchThreshold:
          (json['longMemoryThreshold'] as num?)?.toDouble() ??
          DefaultValueConstants.diarySearchThreshold,
      coreMemory: json['enableCoreMemory'] as bool? ?? false,
      worldBook: json['enableLoreBooks'] as bool? ?? false,
      worldBookThreshold:
          (json['loreBooksThreshold'] as num?)?.toDouble() ??
          DefaultValueConstants.worldBookThreshold,
      worldBookDepth:
          json['loreBooksDepth'] as int? ??
          DefaultValueConstants.worldBookDepth,
      emotionSystem: json['enableEmotionSystem'] as bool? ?? false,
      emotionPersist: json['enableEmotionPersist'] as bool? ?? false,
    );
  }

  /// Serialize [FeatureSettings] to a JSON map.
  static Map<String, dynamic> featureSettingsToJson(FeatureSettings settings) {
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

  /// Serialize [GsvSettings] to a JSON map.
  static Map<String, dynamic> gsvSettingsToJson(GsvSettings settings) {
    final json = <String, dynamic>{
      'textLang': settings.textLang ?? DefaultValueConstants.defaultTextLang,
      'promptLang':
          settings.promptLang ?? DefaultValueConstants.defaultPromptLang,
      'seed': settings.seed ?? DefaultValueConstants.gsvSeed,
      'topK': settings.topK ?? DefaultValueConstants.gsvTopK,
      'batchSize': settings.batchSize ?? DefaultValueConstants.gsvBatchSize,
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

  /// Format a timestamp value to a date string (yyyy-MM-dd).
  static String formatTimestamp(dynamic timestamp) {
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
