// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateAssistantDtoImpl _$$CreateAssistantDtoImplFromJson(
  Map<String, dynamic> json,
) => _$CreateAssistantDtoImpl(
  name: json['name'] as String,
  avatar: json['avatar'] as String,
  birthday: json['birthday'] as String,
  height: json['height'] as String,
  weight: json['weight'] as String,
  personality: json['personality'] as String,
  description: json['description'] as String,
  userNickname: json['user'] as String?,
  userSetting: json['mask'] as String?,
  messageExamples: (json['messageExamples'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  extraDescription: json['extraDescription'] as String?,
  customPrompt: json['customPrompt'] as String?,
  greetings: (json['startWith'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  settings: json['settings'] == null
      ? null
      : FeatureSettingsDto.fromJson(json['settings'] as Map<String, dynamic>),
  gsvSetting: json['gsvSetting'] == null
      ? null
      : GsvSettingsDto.fromJson(json['gsvSetting'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$CreateAssistantDtoImplToJson(
  _$CreateAssistantDtoImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'avatar': instance.avatar,
  'birthday': instance.birthday,
  'height': instance.height,
  'weight': instance.weight,
  'personality': instance.personality,
  'description': instance.description,
  'user': instance.userNickname,
  'mask': instance.userSetting,
  'messageExamples': instance.messageExamples,
  'extraDescription': instance.extraDescription,
  'customPrompt': instance.customPrompt,
  'startWith': instance.greetings,
  'settings': instance.settings?.toJson(),
  'gsvSetting': instance.gsvSetting?.toJson(),
};

_$UpdateAssistantDtoImpl _$$UpdateAssistantDtoImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateAssistantDtoImpl(
  name: json['name'] as String,
  avatar: json['avatar'] as String?,
  birthday: json['birthday'] as String?,
  height: json['height'] as String?,
  weight: json['weight'] as String?,
  personality: json['personality'] as String?,
  description: json['description'] as String?,
  userNickname: json['user'] as String?,
  userSetting: json['mask'] as String?,
  messageExamples: (json['messageExamples'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  extraDescription: json['extraDescription'] as String?,
  customPrompt: json['customPrompt'] as String?,
  greetings: (json['startWith'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  settings: json['settings'] == null
      ? null
      : FeatureSettingsDto.fromJson(json['settings'] as Map<String, dynamic>),
  gsvSetting: json['gsvSetting'] == null
      ? null
      : GsvSettingsDto.fromJson(json['gsvSetting'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$UpdateAssistantDtoImplToJson(
  _$UpdateAssistantDtoImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'avatar': instance.avatar,
  'birthday': instance.birthday,
  'height': instance.height,
  'weight': instance.weight,
  'personality': instance.personality,
  'description': instance.description,
  'user': instance.userNickname,
  'mask': instance.userSetting,
  'messageExamples': instance.messageExamples,
  'extraDescription': instance.extraDescription,
  'customPrompt': instance.customPrompt,
  'startWith': instance.greetings,
  'settings': instance.settings?.toJson(),
  'gsvSetting': instance.gsvSetting?.toJson(),
};

_$FeatureSettingsDtoImpl _$$FeatureSettingsDtoImplFromJson(
  Map<String, dynamic> json,
) => _$FeatureSettingsDtoImpl(
  contextLength:
      (json['contextLength'] as num?)?.toInt() ??
      DefaultValueConstants.contextLength,
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
      (json['loreBooksDepth'] as num?)?.toInt() ??
      DefaultValueConstants.worldBookDepth,
  emotionSystem: json['enableEmotionSystem'] as bool? ?? false,
  emotionPersist: json['enableEmotionPersist'] as bool? ?? false,
);

Map<String, dynamic> _$$FeatureSettingsDtoImplToJson(
  _$FeatureSettingsDtoImpl instance,
) => <String, dynamic>{
  'contextLength': instance.contextLength,
  'enableLongMemory': instance.diary,
  'enableLongMemorySearchEnhance': instance.diarySearchBoost,
  'longMemoryThreshold': instance.diarySearchThreshold,
  'enableCoreMemory': instance.coreMemory,
  'enableLoreBooks': instance.worldBook,
  'loreBooksThreshold': instance.worldBookThreshold,
  'loreBooksDepth': instance.worldBookDepth,
  'enableEmotionSystem': instance.emotionSystem,
  'enableEmotionPersist': instance.emotionPersist,
};

_$GsvSettingsDtoImpl _$$GsvSettingsDtoImplFromJson(Map<String, dynamic> json) =>
    _$GsvSettingsDtoImpl(
      textLang: json['textLang'] as String?,
      gptModelPath: json['gptModelPath'] as String?,
      sovitsModelPath: json['sovitsModelPath'] as String?,
      refAudioPath: json['refAudioPath'] as String?,
      promptText: json['promptText'] as String?,
      promptLang: json['promptLang'] as String?,
      seed: (json['seed'] as num?)?.toInt() ?? DefaultValueConstants.gsvSeed,
      topK: (json['topK'] as num?)?.toInt() ?? DefaultValueConstants.gsvTopK,
      batchSize:
          (json['batchSize'] as num?)?.toInt() ??
          DefaultValueConstants.gsvBatchSize,
      extraSettings: json['extra'] as Map<String, dynamic>?,
      extraRefAudio: json['extraRefAudio'] as String?,
    );

Map<String, dynamic> _$$GsvSettingsDtoImplToJson(
  _$GsvSettingsDtoImpl instance,
) => <String, dynamic>{
  'textLang': instance.textLang,
  'gptModelPath': instance.gptModelPath,
  'sovitsModelPath': instance.sovitsModelPath,
  'refAudioPath': instance.refAudioPath,
  'promptText': instance.promptText,
  'promptLang': instance.promptLang,
  'seed': instance.seed,
  'topK': instance.topK,
  'batchSize': instance.batchSize,
  'extra': instance.extraSettings,
  'extraRefAudio': instance.extraRefAudio,
};
