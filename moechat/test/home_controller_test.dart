import 'package:flutter_test/flutter_test.dart';
import 'package:moechat/models/assistant.dart';

void main() {
  group('HomeController Logic Tests', () {
    test('Message parsing - list field', () {
      // 模拟列表字段解析
      String input = 'Line 1\nLine 2\nLine 3';
      List<String>? result = input
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      expect(result, equals(['Line 1', 'Line 2', 'Line 3']));
    });

    test('Message parsing - empty input', () {
      String input = '';
      List<String>? result = input.trim().isEmpty
          ? null
          : input
                .split('\n')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
      expect(result, isNull);
    });

    test('Message parsing - multiline with empty lines', () {
      String input = 'Line 1\n\nLine 2\n  \nLine 3\n';
      List<String>? result = input
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      expect(result, equals(['Line 1', 'Line 2', 'Line 3']));
    });

    test('FeatureSettings creation', () {
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
      expect(settings.diarySearchBoost, isTrue);
      expect(settings.diarySearchThreshold, equals(0.38));
      expect(settings.emotionSystem, isFalse);
    });

    test('GsvSettings creation', () {
      const gsv = GsvSettings(
        textLang: 'zh',
        gptModelPath: 'models/test.ckpt',
        seed: -1,
        topK: 30,
      );

      expect(gsv.textLang, equals('zh'));
      expect(gsv.gptModelPath, equals('models/test.ckpt'));
      expect(gsv.seed, equals(-1));
    });

    test('GsvSettings null values', () {
      const gsv = GsvSettings();
      expect(gsv.textLang, isNull);
      expect(gsv.gptModelPath, isNull);
      expect(gsv.seed, isNull);
    });

    test('ChatMessage creation', () {
      final message = ChatMessage(sender: MessageSender.user, content: 'Hello');

      expect(message.sender, equals(MessageSender.user));
      expect(message.content, equals('Hello'));
      expect(message.isTyping, isFalse);
    });

    test('ChatMessage copyWith', () {
      final message = ChatMessage(
        sender: MessageSender.bot,
        content: 'Hi',
        isTyping: true,
      );

      final updated = message.copyWith(content: 'Hello there', isTyping: false);

      expect(updated.sender, equals(MessageSender.bot));
      expect(updated.content, equals('Hello there'));
      expect(updated.isTyping, isFalse);
    });

    test('MessageSender enum values', () {
      expect(MessageSender.bot.index, equals(0));
      expect(MessageSender.user.index, equals(1));
    });
  });
}
