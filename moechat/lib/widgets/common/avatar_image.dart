import 'dart:convert';
import 'dart:typed_data';
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
///
/// 使用 StatefulWidget 缓存解码后的图片数据，避免每次重建时重新解码导致的闪烁
class AvatarImage extends StatefulWidget {
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
  State<AvatarImage> createState() => _AvatarImageState();
}

class _AvatarImageState extends State<AvatarImage> {
  /// 缓存解码后的 base64 图片数据
  Uint8List? _cachedBytes;
  String? _cachedAvatar;

  @override
  void initState() {
    super.initState();
    _processAvatar();
  }

  @override
  void didUpdateWidget(AvatarImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 只有当 avatar 数据变化时才重新处理
    if (oldWidget.avatar != widget.avatar ||
        oldWidget.assistantName != widget.assistantName) {
      _processAvatar();
    }
  }

  void _processAvatar() {
    String? effectiveAvatar = widget.avatar;
    if (effectiveAvatar == null || effectiveAvatar.isEmpty) {
      if (widget.assistantName != null && widget.assistantName!.isNotEmpty) {
        effectiveAvatar = AvatarCacheService.to.getAvatar(
          widget.assistantName!,
        );
      }
    }

    _cachedAvatar = effectiveAvatar;

    if (effectiveAvatar != null &&
        effectiveAvatar.isNotEmpty &&
        _isBase64(effectiveAvatar)) {
      try {
        String data = effectiveAvatar.trim();
        // 处理 data:image/xxx;base64, 前缀
        if (data.startsWith('data:image')) {
          final commaIndex = data.indexOf(',');
          if (commaIndex != -1) {
            data = data.substring(commaIndex + 1);
          }
        }
        _cachedBytes = base64Decode(data);
      } catch (e) {
        _cachedBytes = null;
      }
    } else {
      _cachedBytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    String? effectiveAvatar = _cachedAvatar;

    Widget image;
    if (effectiveAvatar == null || effectiveAvatar.isEmpty) {
      // 使用默认图片
      image = Image.asset('assets/logo1.png', fit: widget.fit);
    } else if (_cachedBytes != null) {
      // 使用缓存的解码数据，gaplessPlayback 防止闪烁
      image = Image.memory(
        _cachedBytes!,
        fit: widget.fit,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/logo1.png', fit: widget.fit),
      );
    } else if (_isUrl(effectiveAvatar)) {
      // 显示网络图片
      image = Image.network(
        effectiveAvatar,
        fit: widget.fit,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/logo1.png', fit: widget.fit),
      );
    } else {
      // 未知格式，使用默认图片
      image = Image.asset('assets/logo1.png', fit: widget.fit);
    }

    if (widget.circular) {
      return ClipOval(
        child: SizedBox(width: widget.size, height: widget.size, child: image),
      );
    }

    return SizedBox(width: widget.size, height: widget.size, child: image);
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
