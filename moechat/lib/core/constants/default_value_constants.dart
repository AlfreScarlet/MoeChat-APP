/// Default value constants for assistant settings.
abstract class DefaultValueConstants {
  // FeatureSettings defaults
  /// Default context length.
  static const int contextLength = 40;

  /// Default diary search threshold.
  static const double diarySearchThreshold = 0.32;

  /// Default world book threshold.
  static const double worldBookThreshold = 0.5;

  /// Default world book depth.
  static const int worldBookDepth = 3;

  // GsvSettings defaults
  /// Default GSV seed value.
  static const int gsvSeed = -1;

  /// Default topK value.
  static const int gsvTopK = 30;

  /// Default batch size.
  static const int gsvBatchSize = 20;

  /// Default text language.
  static const String defaultTextLang = 'zh';

  /// Default prompt language.
  static const String defaultPromptLang = 'zh';

  // Assistant defaults
  /// Default love level.
  static const int defaultLoveLevel = 0;

  /// Default assets last modified timestamp.
  static const double defaultAssetsLastModified = 0.0;
}
