import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../services/loading_service.dart';
import '../controllers/home_controller.dart';

/// Persistent configuration controller for client-side connection settings.
class SettingsController extends GetxController {
  static const _boxName = 'settings';
  late final GetStorage _box;

  // 连接配置
  final httpApiUrl = ''.obs;
  final socketUrl = ''.obs;

  // 服务初始化状态
  final isApiInitialized = false.obs;
  final isSocketInitialized = false.obs;
  final isConnecting = false.obs; // 新增：连接中状态

  static Future<void> init() async {
    await GetStorage.init(_boxName);
  }

  @override
  void onInit() {
    super.onInit();
    _box = GetStorage(_boxName);

    // 读取保存的配置
    httpApiUrl.value = _box.read('httpApiUrl') ?? '';
    socketUrl.value = _box.read('socketUrl') ?? '';

    debugPrint('⚙️ SettingsController 初始化');
    debugPrint(
      '   HTTP API: ${httpApiUrl.value.isEmpty ? "未配置" : httpApiUrl.value}',
    );
    debugPrint(
      '   Socket: ${socketUrl.value.isEmpty ? "未配置" : socketUrl.value}',
    );

    // 启动时自动连接（延迟到所有控制器注册完成后）
    Future.delayed(Duration.zero, _autoConnect);
  }

  /// 启动时自动连接（静默，不阻塞 UI）
  Future<void> _autoConnect() async {
    if (httpApiUrl.value.isEmpty) return;

    debugPrint('🔄 启动时自动连接...');
    _initApiService();
    if (!isApiInitialized.value) return;

    // 静默加载助手列表（不显示 loading 弹窗）
    try {
      await Get.find<HomeController>().loadAssistants();
    } catch (e) {
      debugPrint('⚠️ 自动加载助手列表失败: $e');
    }

    // 静默连接 Socket
    if (socketUrl.value.isNotEmpty) {
      try {
        final parsed = _parseSocketUrl(socketUrl.value);
        await Get.find<SocketService>().connect(parsed.$1, parsed.$2);
        isSocketInitialized.value = Get.find<SocketService>().isConnected;
        debugPrint('✅ 自动连接 Socket 成功');
      } catch (e) {
        debugPrint('⚠️ 自动连接 Socket 失败: $e');
      }
    }
  }

  /// 解析 Socket URL 为 (host, port)
  (String, int) _parseSocketUrl(String url) {
    var cleaned = url.trim();
    if (!cleaned.contains('://')) cleaned = 'tcp://$cleaned';
    cleaned = cleaned
        .replaceAll(RegExp(r'^tcp://'), '')
        .replaceAll(RegExp(r'^socket://'), '');

    if (cleaned.contains(':')) {
      final parts = cleaned.split(':');
      return (parts[0], int.tryParse(parts[1]) ?? 9092);
    }
    return (cleaned, 9092);
  }

  /// 测试连接（带加载动画和取消）
  Future<bool> testConnection() async {
    bool apiSuccess = false;
    bool isCancelled = false;

    // 使用单个加载对话框，避免闪烁
    LoadingService.to.showLoading(
      message: '正在连接API服务器...',
      showCancel: true,
      onCancel: () {
        isCancelled = true;
        debugPrint('⛔ 用户取消连接');
        Get.find<SocketService>().disconnect();
      },
    );

    try {
      // 测试API连接
      if (httpApiUrl.value.isNotEmpty && !isCancelled) {
        try {
          apiSuccess = await _testApiConnectionWithTimeout();
        } catch (e) {
          LoadingService.to.hideLoading();
          if (!isCancelled) {
            LoadingService.to.showError('API服务器连接失败: $e');
          }
          return false;
        }
      }

      // 更新加载消息，测试Socket连接
      if (socketUrl.value.isNotEmpty && apiSuccess && !isCancelled) {
        LoadingService.to.updateMessage('正在连接Socket服务器...');
        try {
          await _testSocketConnectionWithTimeout();
        } catch (e) {
          LoadingService.to.hideLoading();
          if (!isCancelled) {
            LoadingService.to.showError('Socket服务器连接失败: $e');
          }
          return false;
        }
      }

      // 连接成功，隐藏加载对话框
      LoadingService.to.hideLoading();

      if (apiSuccess && !isCancelled) {
        LoadingService.to.showSuccess('连接成功');
        // 加载助手列表
        await Get.find<HomeController>().loadAssistants();
      }

      return apiSuccess && !isCancelled;
    } catch (e) {
      LoadingService.to.hideLoading();
      if (!isCancelled) {
        LoadingService.to.showError('连接失败: $e');
      }
      return false;
    }
  }

  /// 带超时的API连接测试
  Future<bool> _testApiConnectionWithTimeout() async {
    try {
      _initApiService();
      if (!isApiInitialized.value) return false;

      // 测试获取助手列表（3秒超时）
      await Get.find<ApiService>().fetchAssistants().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('API连接超时'),
      );

      return true;
    } on TimeoutException {
      isApiInitialized.value = false;
      throw Exception('API连接超时，请检查地址');
    } catch (e) {
      isApiInitialized.value = false;
      throw Exception('API连接失败: $e');
    }
  }

  /// 带超时的Socket连接测试
  Future<bool> _testSocketConnectionWithTimeout() async {
    try {
      final (host, port) = _parseSocketUrl(socketUrl.value);

      await Get.find<SocketService>()
          .connect(host, port)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException('Socket连接超时');
            },
          );

      isSocketInitialized.value = Get.find<SocketService>().isConnected;
      return isSocketInitialized.value;
    } on TimeoutException {
      isSocketInitialized.value = false;
      throw Exception('Socket连接超时');
    } catch (e) {
      isSocketInitialized.value = false;
      throw Exception('Socket连接失败: $e');
    }
  }

  /// 保存配置并连接
  Future<bool> saveAndConnect(String httpUrl, String socketUrlValue) async {
    // 保存配置
    httpApiUrl.value = httpUrl.trim();
    socketUrl.value = socketUrlValue.trim();
    _box.write('httpApiUrl', httpApiUrl.value);
    _box.write('socketUrl', socketUrl.value);

    debugPrint('💾 保存配置:');
    debugPrint('   HTTP API: ${httpApiUrl.value}');
    debugPrint('   Socket: ${socketUrl.value}');

    // 测试连接
    return await testConnection();
  }

  void _initApiService() {
    try {
      final url = httpApiUrl.value.trim();
      if (url.isEmpty) {
        isApiInitialized.value = false;
        return;
      }

      final uri = Uri.parse(url);

      final path = uri.path.endsWith('/')
          ? uri.path.substring(0, uri.path.length - 1)
          : uri.path;
      // 只有当 URL 中显式包含端口时才在 baseUrl 中包含端口
      final hasExplicitPort = uri.hasPort;
      final authority = hasExplicitPort ? '${uri.host}:${uri.port}' : uri.host;
      final baseUrl = '${uri.scheme}://$authority$path';

      debugPrint('🌐 解析URL: $url -> $baseUrl');

      Get.find<ApiService>().initialize(baseUrl);
      isApiInitialized.value = true;
    } catch (e) {
      isApiInitialized.value = false;
      debugPrint('❌ API 初始化失败: $e');
    }
  }

  /// 刷新连接（设置变更后调用）
  Future<void> refreshConnections() async {
    await testConnection();
  }

  /// 清除配置
  void clearConfig() {
    httpApiUrl.value = '';
    socketUrl.value = '';
    isApiInitialized.value = false;
    isSocketInitialized.value = false;
    _box.remove('httpApiUrl');
    _box.remove('socketUrl');
    debugPrint('🗑️ 配置已清除');
  }
}
