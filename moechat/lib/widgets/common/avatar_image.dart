import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/avatar_cache_service.dart';

/// 通用头像显示组件
///
/// 支持以下格式：
/// 1. HTTP/HTTPS URL - 从网络加载
/// 2. Base64 字符串 - 直接解码显示
/// 3. 空或无效 - 显示默认logo
///
/// 如果 [avatar] 是 URL 或 base64，直接使用；
/// 如果 [assistantName] 不为空，会尝试从 AvatarCacheService 获取缓存的头像
class AvatarImage extends StatelessWidget {
  /// 头像数据（URL 或 base64）
  final String? avatar;

  /// 助手名称（用于从缓存获取头像）
  final String? assistantName;

  /// 显示尺寸
  final double size;

  /// 填充模式
  final BoxFit fit;

  /// 是否为圆形
  final bool circular;

  const AvatarImage({
    super.key,
    this.avatar,
    this.assistantName,
    this.size = 40,
    this.fit = BoxFit.cover,
    this.circular = true,
  });

  @override
  Widget build(BuildContext context) {
    // 尝试从缓存获取头像
    String? effectiveAvatar = avatar;
    if (effectiveAvatar == null || effectiveAvatar.isEmpty) {
      if (assistantName != null && assistantName!.isNotEmpty) {
        effectiveAvatar = AvatarCacheService.to.getAvatar(assistantName!);
      }
    }

    Widget image;
    if (effectiveAvatar == null || effectiveAvatar.isEmpty) {
      // 使用默认图片
      image = Image.asset('assets/logo1.png', fit: fit);
    } else if (_isBase64(effectiveAvatar)) {
      // 显示 base64 图片
      image = _buildBase64Image(effectiveAvatar);
    } else if (_isUrl(effectiveAvatar)) {
      // 显示网络图片
      image = Image.network(
        effectiveAvatar,
        fit: fit,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/logo1.png', fit: fit),
      );
    } else {
      // 未知格式，使用默认图片
      image = Image.asset('assets/logo1.png', fit: fit);
    }

    if (circular) {
      return ClipOval(
        child: SizedBox(width: size, height: size, child: image),
      );
    }

    return SizedBox(width: size, height: size, child: image);
  }

  /// 检查是否为 base64 数据
  bool _isBase64(String str) {
    // 去除空白字符
    final trimmed = str.trim();
    // 检查是否包含 base64 特征（通常以 data:image 开头，或者是纯 base64 字符串）
    if (trimmed.startsWith('data:image')) {
      return true;
    }
    // 检查是否为纯 base64 字符串（长度是4的倍数，只包含 base64 字符）
    final base64Pattern = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return base64Pattern.hasMatch(trimmed) && trimmed.length % 4 == 0;
  }

  /// 检查是否为 URL
  bool _isUrl(String str) {
    return str.startsWith('http://') || str.startsWith('https://');
  }

  /// 构建 base64 图片
  Widget _buildBase64Image(String base64Data) {
    try {
      String data = base64Data.trim();

      // 处理 data:image/xxx;base64, 前缀
      if (data.startsWith('data:image')) {
        final commaIndex = data.indexOf(',');
        if (commaIndex != -1) {
          data = data.substring(commaIndex + 1);
        }
      }

      final bytes = base64Decode(data);
      return Image.memory(
        bytes,
        fit: fit,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/logo1.png', fit: fit),
      );
    } catch (e) {
      return Image.asset('assets/logo1.png', fit: fit);
    }
  }
}

/// 响应式头像组件
///
/// 使用 Obx 监听头像缓存变化，当缓存更新时自动刷新
/// 只在以下情况刷新：
/// 1. 启动时预加载完成
/// 2. 用户修改头像后
class ReactiveAvatarImage extends StatelessWidget {
  /// 助手名称（必需，用于从缓存获取头像）
  final String assistantName;

  /// 备用头像数据（URL 或 base64）
  final String? fallbackAvatar;

  /// 显示尺寸
  final double size;

  /// 填充模式
  final BoxFit fit;

  /// 是否为圆形
  final bool circular;

  const ReactiveAvatarImage({
    super.key,
    required this.assistantName,
    this.fallbackAvatar,
    this.size = 40,
    this.fit = BoxFit.cover,
    this.circular = true,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final service = AvatarCacheService.to;
      
      // 只读取缓存，不触发任何获取逻辑
      final cachedAvatar = service.getCachedAvatar(assistantName);
      
      // 有缓存显示缓存，没有显示默认头像
      return AvatarImage(
        avatar: cachedAvatar ?? fallbackAvatar,
        assistantName: assistantName,
        size: size,
        fit: fit,
        circular: circular,
      );
    });
  }
}
