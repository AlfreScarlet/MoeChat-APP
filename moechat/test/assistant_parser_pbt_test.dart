@Tags(['project-modular-refactor'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:moechat/core/constants/default_value_constants.dart';
import 'package:moechat/models/assistant.dart';
import 'package:moechat/services/api/assistant_parser.dart';
import 'package:wheatley/wheatley.dart';

// ---------------------------------------------------------------------------
// Generators
// ---------------------------------------------------------------------------

/// Generator for arbitrary [FeatureSettings].
Generator<FeatureSettings> featureSettingsGen() {
  final contextLengthGen = integer(min: 1, max: 200);
  final thresholdGen = float(min: 0.0, max: 1.0);
  final depthGen = integer(min: 1, max: 20);
  final boolGen = oneOf([true, false]);

  return (
    contextLengthGen,
    thresholdGen,
    depthGen,
    boolGen,
    boolGen,
    boolGen,
    thresholdGen,
    boolGen,
  ).zip.flatMap((outer) {
    final (
      ctxLen,
      diaryThresh,
      wbDepth,
      diary,
      diaryBoost,
      coreMem,
      wbThresh,
      worldBook,
    ) = outer;
    return (boolGen, boolGen).zip.map((inner) {
      final (emotionSys, emotionPersist) = inner;
      return FeatureSettings(
        contextLength: ctxLen,
        diary: diary,
        diarySearchBoost: diaryBoost,
        diarySearchThreshold: diaryThresh,
        coreMemory: coreMem,
        worldBook: worldBook,
        worldBookThreshold: wbThresh,
        worldBookDepth: wbDepth,
        emotionSystem: emotionSys,
        emotionPersist: emotionPersist,
      );
    });
  });
}

/// Generator for arbitrary [GsvSettings].
Generator<GsvSettings> gsvSettingsGen() {
  final strGen = string(minSize: 0, maxSize: 30);
  final seedGen = integer(min: -1, max: 1000);
  final topKGen = integer(min: 1, max: 100);
  final batchGen = integer(min: 1, max: 100);

  return (
    strGen,
    strGen,
    strGen,
    strGen,
    strGen,
    strGen,
    seedGen,
    topKGen,
  ).zip.flatMap((outer) {
    final (
      textLang,
      gptModel,
      sovitsModel,
      refAudio,
      promptText,
      promptLang,
      seed,
      topK,
    ) = outer;
    return batchGen.map((batch) {
      return GsvSettings(
        textLang: textLang,
        gptModelPath: gptModel,
        sovitsModelPath: sovitsModel,
        refAudioPath: refAudio,
        promptText: promptText,
        promptLang: promptLang,
        seed: seed,
        topK: topK,
        batchSize: batch,
      );
    });
  });
}

/// All JSON keys used by [AssistantParser.featureSettingsToJson].
const _featureJsonKeys = [
  'contextLength',
  'enableLongMemory',
  'enableLongMemorySearchEnhance',
  'longMemoryThreshold',
  'enableCoreMemory',
  'enableLoreBooks',
  'loreBooksThreshold',
  'loreBooksDepth',
  'enableEmotionSystem',
  'enableEmotionPersist',
];

/// Generator that produces a JSON map with a random subset of feature-settings
/// keys removed or set to null.
Generator<Map<String, dynamic>> partialFeatureJsonGen() {
  return featureSettingsGen().flatMap((settings) {
    final fullJson = AssistantParser.featureSettingsToJson(settings);
    // Generate a bitmask to decide which keys to keep/remove.
    return integer(min: 0, max: (1 << _featureJsonKeys.length) - 1).map((mask) {
      final partial = Map<String, dynamic>.from(fullJson);
      for (var i = 0; i < _featureJsonKeys.length; i++) {
        if (mask & (1 << i) == 0) {
          if (mask.isEven) {
            partial.remove(_featureJsonKeys[i]);
          } else {
            partial[_featureJsonKeys[i]] = null;
          }
        }
      }
      return partial;
    });
  });
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('Property 1: AssistantParser JSON round-trip', () {
    test('FeatureSettings round-trip: '
        'parseFeatureSettings(featureSettingsToJson(s)) ≡ s', () async {
      /// **Validates: Requirements 3.3**
      await forAll(featureSettingsGen())((settings) {
        final json = AssistantParser.featureSettingsToJson(settings);
        final parsed = AssistantParser.parseFeatureSettings(json);

        expect(parsed.contextLength, equals(settings.contextLength));
        expect(parsed.diary, equals(settings.diary));
        expect(parsed.diarySearchBoost, equals(settings.diarySearchBoost));
        expect(
          parsed.diarySearchThreshold,
          equals(settings.diarySearchThreshold),
        );
        expect(parsed.coreMemory, equals(settings.coreMemory));
        expect(parsed.worldBook, equals(settings.worldBook));
        expect(parsed.worldBookThreshold, equals(settings.worldBookThreshold));
        expect(parsed.worldBookDepth, equals(settings.worldBookDepth));
        expect(parsed.emotionSystem, equals(settings.emotionSystem));
        expect(parsed.emotionPersist, equals(settings.emotionPersist));
      });
    });

    test(
      'GsvSettings round-trip: '
      'parseGsvSettings(gsvSettingsToJson(s)) preserves core fields',
      () async {
        /// **Validates: Requirements 3.3**
        await forAll(gsvSettingsGen())((settings) {
          final json = AssistantParser.gsvSettingsToJson(settings);
          final parsed = AssistantParser.parseGsvSettings(json);

          // textLang and promptLang get defaults when null in toJson,
          // so compare against the serialized value.
          expect(parsed.textLang, equals(json['textLang']));
          expect(parsed.promptLang, equals(json['promptLang']));
          expect(parsed.gptModelPath, equals(json['gptModelPath']));
          expect(parsed.sovitsModelPath, equals(json['sovitsModelPath']));
          expect(parsed.refAudioPath, equals(json['refAudioPath']));
          expect(parsed.promptText, equals(json['promptText']));
          expect(parsed.seed, equals(json['seed']));
          expect(parsed.topK, equals(json['topK']));
          expect(parsed.batchSize, equals(json['batchSize']));
        });
      },
    );
  });

  group('Property 2: AssistantParser default value invariant', () {
    test('parseFeatureSettings(null) returns all defaults', () {
      /// **Validates: Requirements 3.4**
      final defaults = AssistantParser.parseFeatureSettings(null);

      expect(
        defaults.contextLength,
        equals(DefaultValueConstants.contextLength),
      );
      expect(defaults.diary, isFalse);
      expect(defaults.diarySearchBoost, isFalse);
      expect(
        defaults.diarySearchThreshold,
        equals(DefaultValueConstants.diarySearchThreshold),
      );
      expect(defaults.coreMemory, isFalse);
      expect(defaults.worldBook, isFalse);
      expect(
        defaults.worldBookThreshold,
        equals(DefaultValueConstants.worldBookThreshold),
      );
      expect(
        defaults.worldBookDepth,
        equals(DefaultValueConstants.worldBookDepth),
      );
      expect(defaults.emotionSystem, isFalse);
      expect(defaults.emotionPersist, isFalse);
    });

    test(
      'Partial JSON: missing/null fields get defaults, present fields preserved',
      () async {
        /// **Validates: Requirements 3.4**
        await forAll(partialFeatureJsonGen())((partialJson) {
          final parsed = AssistantParser.parseFeatureSettings(partialJson);

          // contextLength
          if (_hasValue(partialJson, 'contextLength')) {
            expect(parsed.contextLength, equals(partialJson['contextLength']));
          } else {
            expect(
              parsed.contextLength,
              equals(DefaultValueConstants.contextLength),
            );
          }

          // diary (enableLongMemory)
          if (_hasValue(partialJson, 'enableLongMemory')) {
            expect(parsed.diary, equals(partialJson['enableLongMemory']));
          } else {
            expect(parsed.diary, isFalse);
          }

          // diarySearchBoost (enableLongMemorySearchEnhance)
          if (_hasValue(partialJson, 'enableLongMemorySearchEnhance')) {
            expect(
              parsed.diarySearchBoost,
              equals(partialJson['enableLongMemorySearchEnhance']),
            );
          } else {
            expect(parsed.diarySearchBoost, isFalse);
          }

          // diarySearchThreshold (longMemoryThreshold)
          if (_hasValue(partialJson, 'longMemoryThreshold')) {
            expect(
              parsed.diarySearchThreshold,
              equals((partialJson['longMemoryThreshold'] as num).toDouble()),
            );
          } else {
            expect(
              parsed.diarySearchThreshold,
              equals(DefaultValueConstants.diarySearchThreshold),
            );
          }

          // coreMemory
          if (_hasValue(partialJson, 'enableCoreMemory')) {
            expect(parsed.coreMemory, equals(partialJson['enableCoreMemory']));
          } else {
            expect(parsed.coreMemory, isFalse);
          }

          // worldBook (enableLoreBooks)
          if (_hasValue(partialJson, 'enableLoreBooks')) {
            expect(parsed.worldBook, equals(partialJson['enableLoreBooks']));
          } else {
            expect(parsed.worldBook, isFalse);
          }

          // worldBookThreshold (loreBooksThreshold)
          if (_hasValue(partialJson, 'loreBooksThreshold')) {
            expect(
              parsed.worldBookThreshold,
              equals((partialJson['loreBooksThreshold'] as num).toDouble()),
            );
          } else {
            expect(
              parsed.worldBookThreshold,
              equals(DefaultValueConstants.worldBookThreshold),
            );
          }

          // worldBookDepth (loreBooksDepth)
          if (_hasValue(partialJson, 'loreBooksDepth')) {
            expect(
              parsed.worldBookDepth,
              equals(partialJson['loreBooksDepth']),
            );
          } else {
            expect(
              parsed.worldBookDepth,
              equals(DefaultValueConstants.worldBookDepth),
            );
          }

          // emotionSystem
          if (_hasValue(partialJson, 'enableEmotionSystem')) {
            expect(
              parsed.emotionSystem,
              equals(partialJson['enableEmotionSystem']),
            );
          } else {
            expect(parsed.emotionSystem, isFalse);
          }

          // emotionPersist
          if (_hasValue(partialJson, 'enableEmotionPersist')) {
            expect(
              parsed.emotionPersist,
              equals(partialJson['enableEmotionPersist']),
            );
          } else {
            expect(parsed.emotionPersist, isFalse);
          }
        });
      },
    );
  });
}

/// Helper: returns true if [json] contains [key] with a non-null value.
bool _hasValue(Map<String, dynamic> json, String key) =>
    json.containsKey(key) && json[key] != null;
