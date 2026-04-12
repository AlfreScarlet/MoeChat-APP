import 'dart:developer' as developer;
import 'package:get/get.dart';
import '../repositories/assistant_repository.dart';

/// 头像缓存服务
///
/// 管理助手头像的 base64 数据缓存，提供异步获取和缓存功能。
class AvatarCacheService extends GetxService {
  static AvatarCacheService get to => Get.find<AvatarCacheService>();

  /// 头像缓存Map: 助手名称 -> base64数据
  final _cache = <String, String>{}.obs;

  /// 正在加载的头像集合（防止重复请求）
  final _loadingSet = <String>{};

  /// 获取头像数据（从缓存或服务器）
  ///
  /// 如果缓存中有，直接返回；否则会异步从服务器获取并缓存
  String? getAvatar(String assistantName) {
    // 如果缓存中有，直接返回
    if (_cache.containsKey(assistantName)) {
      return _cache[assistantName];
    }

    // 异步获取头像
    _fetchAvatarAsync(assistantName);
    return null;
  }

  /// 预加载头像（用于批量加载）
  Future<void> preloadAvatars(List<String> names) async {
    for (final name in names) {
      if (!_cache.containsKey(name) && !_loadingSet.contains(name)) {
        await _fetchAvatarAsync(name);
      }
    }
  }

  /// 异步获取头像并缓存
  Future<void> _fetchAvatarAsync(String assistantName) async {
    // 防止重复请求
    if (_loadingSet.contains(assistantName)) return;
    _loadingSet.add(assistantName);

    try {
      final repository = Get.find<AssistantRepository>();
      final base64Image = await repository.fetchAvatar(assistantName);

      _cache[assistantName] = base64Image;
      developer.log(
        '✅ 头像加载成功: $assistantName',
        name: 'AvatarCacheService',
      );
    } catch (e) {
      // 头像加载失败是允许的，静默处理
      developer.log(
        '⚠️ 头像加载失败: $assistantName - $e',
        name: 'AvatarCacheService',
      );
    } finally {
      _loadingSet.remove(assistantName);
    }
  }

  /// 更新头像缓存
  void updateAvatar(String assistantName, String base64Data) {
    _cache[assistantName] = base64Data;
    developer.log(
      '✅ 头像缓存已更新: $assistantName',
      name: 'AvatarCacheService',
    );
  }

  /// 获取缓存的头像（不触发异步加载）
  String? getCachedAvatar(String assistantName) {
    return _cache[assistantName];
  }

  /// 清除指定助手的头像缓存
  void clearAvatar(String assistantName) {
    _cache.remove(assistantName);
  }

  /// 清除所有缓存
  void clearAll() {
    _cache.clear();
    _loadingSet.clear();
  }
}
