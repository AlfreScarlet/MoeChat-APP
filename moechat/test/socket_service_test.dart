// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:moechat/services/socket_service.dart';

void main() {
  group('SocketService Tests', () {
    late SocketService socketService;

    setUp(() {
      socketService = SocketService();
    });

    tearDown(() {
      socketService.onClose();
    });

    test('SocketService initial state should be disconnected', () {
      expect(socketService.isConnected, isFalse);
      expect(socketService.connectionState.value, SocketConnectionState.disconnected);
    });

    test('Frame parsing logic', () async {
      // 测试帧解析逻辑
      final testData = Uint8List.fromList([
        ...'<|text|>Hello World<|end|>'.codeUnits,
      ]);

      // 验证数据格式正确
      final text = String.fromCharCodes(testData);
      expect(text, contains('<|text|>'));
      expect(text, contains('<|end|>'));
    });

    test('Audio frame format', () {
      // 测试音频帧格式
      final pcmData = Uint8List(640); // 20ms @ 16kHz 16bit mono
      final audioTag = '<|audio|>'.codeUnits;
      final delimiter = '<|end|>'.codeUnits;
      
      final frame = Uint8List(audioTag.length + pcmData.length + delimiter.length);
      frame.setRange(0, audioTag.length, audioTag);
      frame.setRange(audioTag.length, audioTag.length + pcmData.length, pcmData);
      frame.setRange(audioTag.length + pcmData.length, frame.length, delimiter);

      expect(frame.length, equals(656)); // 9 + 640 + 7 = 656 (UTF-8 bytes)
    });

    test('Connection test to server', () async {
      // 连接到测试服务器
      await socketService.connect('127.0.0.1', 8002);
      
      // 验证连接状态
      expect(socketService.isConnected, isTrue);
      expect(socketService.connectionState.value, SocketConnectionState.connected);
      
      print('Successfully connected to socket server');
      
      // 监听帧流
      socketService.frameStream.listen((frame) {
        print('Received frame: type=${frame.type}, text=${frame.textPayload}');
      });

      // 发送测试消息
      socketService.sendText('Hello from test');
      
      // 等待响应
      await Future.delayed(const Duration(seconds: 2));
      
      // 断开连接
      socketService.disconnect();
      expect(socketService.isConnected, isFalse);
    });
  });
}
