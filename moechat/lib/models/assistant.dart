/// Voice sender type for chat messages.
enum MessageSender { bot, user }

/// GSV voice synthesis settings.
///
/// All fields are nullable — `null` indicates "未设置" (not configured).
class GsvSettings {
  final String? textLang;
  final String? gptModelPath;
  final String? sovitsModelPath;
  final String? refAudioPath;
  final String? promptText;
  final String? promptLang;
  final int? seed;
  final int? topK;
  final int? batchSize;
  final String? textSplitMethod;
  final String? extraRefAudio;

  const GsvSettings({
    this.textLang,
    this.gptModelPath,
    this.sovitsModelPath,
    this.refAudioPath,
    this.promptText,
    this.promptLang,
    this.seed,
    this.topK,
    this.batchSize,
    this.textSplitMethod,
    this.extraRefAudio,
  });
}

/// Feature toggle and threshold settings for an assistant.
class FeatureSettings {
  final int contextLength;
  final bool diary;
  final bool diarySearchBoost;
  final double diarySearchThreshold;
  final bool coreMemory;
  final bool worldBook;
  final double worldBookThreshold;
  final int worldBookDepth;
  final bool emotionSystem;
  final bool emotionPersist;

  const FeatureSettings({
    required this.contextLength,
    required this.diary,
    required this.diarySearchBoost,
    required this.diarySearchThreshold,
    required this.coreMemory,
    required this.worldBook,
    required this.worldBookThreshold,
    required this.worldBookDepth,
    required this.emotionSystem,
    required this.emotionPersist,
  });
}

/// A single chat message.
class ChatMessage {
  final String id;
  final MessageSender sender;
  final String content;
  final bool isTyping;
  final DateTime? timestamp;

  ChatMessage({
    String? id,
    required this.sender,
    required this.content,
    this.isTyping = false,
    this.timestamp,
  }) : id = id ?? '${sender.name}_${DateTime.now().microsecondsSinceEpoch}';

  ChatMessage copyWith({
    String? id,
    MessageSender? sender,
    String? content,
    bool? isTyping,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      isTyping: isTyping ?? this.isTyping,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// An AI assistant character with profile, settings, and metadata.
class Assistant {
  // Required fields
  final String name;
  final String avatar;
  final String description;
  final String birthday;
  final String height;
  final String weight;

  // Nullable text fields
  final String? personality;
  final String? roleDescription;
  final String? userNickname;
  final String? userSetting;
  final String? customPrompt;
  final List<String>? messageExamples;
  final List<String>? greetings;
  final String? extraDescription;

  // Status & metadata
  final int loveLevel;
  final String firstMeet;
  final String lastUpdate;
  final double assetsLastModified;

  // Nested settings
  final GsvSettings gsv;
  final FeatureSettings features;
  final String? emotionConfig;

  const Assistant({
    required this.name,
    required this.avatar,
    required this.description,
    required this.birthday,
    required this.height,
    required this.weight,
    this.personality,
    this.roleDescription,
    this.userNickname,
    this.userSetting,
    this.customPrompt,
    this.messageExamples,
    this.greetings,
    this.extraDescription,
    required this.loveLevel,
    required this.firstMeet,
    required this.lastUpdate,
    this.assetsLastModified = 0.0,
    required this.gsv,
    required this.features,
    this.emotionConfig,
  });
}

/// LLM backend configuration.
class LlmConfig {
  final String baseUrl;
  final String model;
  final String apiKey;

  const LlmConfig({
    required this.baseUrl,
    required this.model,
    required this.apiKey,
  });
}

/// TTS backend configuration.
class TtsConfig {
  final String url;
  final String refAudio;

  const TtsConfig({required this.url, required this.refAudio});
}

/// Agent runtime status.
class AgentStatus {
  final bool isUp;
  final String name;

  const AgentStatus({required this.isUp, required this.name});
}

/// Aggregated settings shown in the SettingsModal.
class SettingsConfig {
  final LlmConfig llm;
  final TtsConfig tts;
  final AgentStatus agent;

  const SettingsConfig({
    required this.llm,
    required this.tts,
    required this.agent,
  });
}

/// 资源更新检查结果
class AssetsUpdateResult {
  final bool needsUpdate;
  final double assetsLastModified;

  const AssetsUpdateResult({
    required this.needsUpdate,
    required this.assetsLastModified,
  });
}
