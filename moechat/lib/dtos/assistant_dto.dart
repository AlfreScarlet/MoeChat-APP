import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/constants/default_value_constants.dart';

part 'assistant_dto.freezed.dart';
part 'assistant_dto.g.dart';

/// DTO for creating a new assistant.
@freezed
class CreateAssistantDto with _$CreateAssistantDto {
  const factory CreateAssistantDto({
    required String name,
    required String avatar,
    required String birthday,
    required String height,
    required String weight,
    required String personality,
    required String description,
    @JsonKey(name: 'user') String? userNickname,
    @JsonKey(name: 'mask') String? userSetting,
    @JsonKey(name: 'messageExamples') List<String>? messageExamples,
    String? extraDescription,
    String? customPrompt,
    @JsonKey(name: 'startWith') List<String>? greetings,
    FeatureSettingsDto? settings,
    GsvSettingsDto? gsvSetting,
  }) = _CreateAssistantDto;

  factory CreateAssistantDto.fromJson(Map<String, dynamic> json) =>
      _$CreateAssistantDtoFromJson(json);
}

/// DTO for updating an existing assistant.
@freezed
class UpdateAssistantDto with _$UpdateAssistantDto {
  const factory UpdateAssistantDto({
    required String name,
    String? avatar,
    String? birthday,
    String? height,
    String? weight,
    String? personality,
    String? description,
    @JsonKey(name: 'user') String? userNickname,
    @JsonKey(name: 'mask') String? userSetting,
    @JsonKey(name: 'messageExamples') List<String>? messageExamples,
    String? extraDescription,
    String? customPrompt,
    @JsonKey(name: 'startWith') List<String>? greetings,
    FeatureSettingsDto? settings,
    GsvSettingsDto? gsvSetting,
  }) = _UpdateAssistantDto;

  factory UpdateAssistantDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateAssistantDtoFromJson(json);
}

/// DTO for feature settings.
@freezed
class FeatureSettingsDto with _$FeatureSettingsDto {
  const factory FeatureSettingsDto({
    @Default(DefaultValueConstants.contextLength) int contextLength,
    @Default(false) @JsonKey(name: 'enableLongMemory') bool diary,
    @Default(false)
    @JsonKey(name: 'enableLongMemorySearchEnhance')
    bool diarySearchBoost,
    @Default(DefaultValueConstants.diarySearchThreshold)
    @JsonKey(name: 'longMemoryThreshold')
    double diarySearchThreshold,
    @Default(false)
    @JsonKey(name: 'enableCoreMemory')
    bool coreMemory,
    @Default(false) @JsonKey(name: 'enableLoreBooks') bool worldBook,
    @Default(DefaultValueConstants.worldBookThreshold)
    @JsonKey(name: 'loreBooksThreshold')
    double worldBookThreshold,
    @Default(DefaultValueConstants.worldBookDepth)
    @JsonKey(name: 'loreBooksDepth')
    int worldBookDepth,
    @Default(false)
    @JsonKey(name: 'enableEmotionSystem')
    bool emotionSystem,
    @Default(false)
    @JsonKey(name: 'enableEmotionPersist')
    bool emotionPersist,
  }) = _FeatureSettingsDto;

  factory FeatureSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$FeatureSettingsDtoFromJson(json);
}

/// DTO for GSV (GPT-SoVITS) voice synthesis settings.
@freezed
class GsvSettingsDto with _$GsvSettingsDto {
  const factory GsvSettingsDto({
    String? textLang,
    String? gptModelPath,
    String? sovitsModelPath,
    String? refAudioPath,
    String? promptText,
    String? promptLang,
    @Default(DefaultValueConstants.gsvSeed) int? seed,
    @Default(DefaultValueConstants.gsvTopK) int? topK,
    @Default(DefaultValueConstants.gsvBatchSize) int? batchSize,
    @JsonKey(name: 'extra') Map<String, dynamic>? extraSettings,
    String? extraRefAudio,
  }) = _GsvSettingsDto;

  factory GsvSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$GsvSettingsDtoFromJson(json);
}
