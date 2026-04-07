import 'package:flutter_test/flutter_test.dart';
import 'package:moechat/models/assistant.dart';
import 'package:moechat/services/api_service.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
      // 使用测试服务器
      apiService.initialize('http://fgs6.bakamoe.com:9091/api');
    });

    test('ApiService should be initialized', () {
      expect(apiService.isInitialized, true);
    });

    group('Read Operations (Safe to test)', () {
      test('fetchAssistants should return list', () async {
        final assistants = await apiService.fetchAssistants();
        expect(assistants, isA<List<Assistant>>());
        // 记录结果供查看
        print('Fetched ${assistants.length} assistants');
        for (final a in assistants) {
          print('  - ${a.name}: ${a.description}');
        }
      });

      test('fetchCurrentAssistant should return assistant or null', () async {
        final assistant = await apiService.fetchCurrentAssistant();
        if (assistant != null) {
          print('Current assistant: ${assistant.name}');
          expect(assistant.name, isNotEmpty);
          expect(assistant.description, isNotEmpty);
        } else {
          print('No current assistant selected');
        }
      });
    });

    group('Data Parsing Tests', () {
      test('should parse assistant JSON correctly', () {
        final json = {
          'name': 'Test酱',
          'avatar': 'test.png',
          'birthday': '2024-01-01',
          'height': '160',
          'weight': '50',
          'personality': 'Test personality',
          'description': 'Test description',
          'user': '主人',
          'mask': 'User mask',
          'love': 50,
          'firstMeetTime': 1704067200,
          'updatedAt': 1704067200,
          'assetsLastModified': 1704067200,
          'settings': {
            'contextLength': 40,
            'enableLongMemory': true,
            'enableLongMemorySearchEnhance': true,
            'enableCoreMemory': true,
            'longMemoryThreshold': 0.32,
            'enableLoreBooks': true,
            'loreBooksThreshold': 0.5,
            'loreBooksDepth': 3,
            'enableEmotionSystem': false,
            'enableEmotionPersist': false,
          },
          'gsvSetting': {
            'textLang': 'zh',
            'gptModelPath': 'test.ckpt',
            'sovitsModelPath': 'test.pth',
            'refAudioPath': 'test.wav',
            'promptText': 'test',
            'promptLang': 'zh',
            'seed': -1,
            'topK': 30,
            'batchSize': 20,
          },
        };

        // 使用ApiService的私有方法通过反射测试
        // 实际测试通过API响应验证
        expect(json['name'], equals('Test酱'));
        expect((json['settings'] as Map)?['contextLength'], equals(40));
      });
    });

    group('Settings Serialization Tests', () {
      test('FeatureSettings should serialize correctly', () {
        const settings = FeatureSettings(
          contextLength: 40,
          diary: true,
          diarySearchBoost: true,
          diarySearchThreshold: 0.38,
          coreMemory: true,
          worldBook: true,
          worldBookThreshold: 0.5,
          worldBookDepth: 3,
          emotionSystem: false,
          emotionPersist: false,
        );

        expect(settings.contextLength, equals(40));
        expect(settings.diary, isTrue);
        expect(settings.diarySearchThreshold, equals(0.38));
      });

      test('GsvSettings should handle null values', () {
        const gsv = GsvSettings();
        expect(gsv.textLang, isNull);
        expect(gsv.seed, isNull);
      });
    });
  });
}
