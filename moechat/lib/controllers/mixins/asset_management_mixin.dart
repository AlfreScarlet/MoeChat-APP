import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/assistant.dart';
import '../../services/api_service.dart';
import '../../services/loading_service.dart';

/// 资源管理 mixin
///
/// 提取自 HomeController，负责助手资源包的检查、下载、上传和一键更新。
mixin AssetManagementMixin on GetxController {
  // ==================== 依赖（由 HomeController 实现） ====================

  ApiService get apiService;
  RxList<Assistant> get assistants;

  // ==================== 内部状态 ====================

  /// 资源管理状态
  final isCheckingAssets = false.obs;
  final isDownloadingAssets = false.obs;
  final isUploadingAssets = false.obs;
  final assetsError = Rxn<String>();

  // ==================== 资源管理 ====================

  /// 检查资源更新
  Future<AssetsUpdateResult?> checkAssetsUpdate(String name) async {
    isCheckingAssets.value = true;
    assetsError.value = null;

    final assistant = assistants.firstWhereOrNull((a) => a.name == name);
    final lastModified = assistant?.assetsLastModified ?? 0.0;

    final result = await LoadingService.to.wrapLoading(
      () => apiService.checkAssetsUpdate(name, lastModified),
      message: '正在检查资源更新...',
    );

    isCheckingAssets.value = false;
    return result;
  }

  /// 下载并解压资源包
  Future<bool> downloadAssets(String name) async {
    isDownloadingAssets.value = true;
    assetsError.value = null;

    final zipData = await LoadingService.to.wrapLoading(
      () => apiService.downloadAssets(name),
      message: '正在下载资源包...',
    );

    if (zipData == null) {
      isDownloadingAssets.value = false;
      return false;
    }

    try {
      // 解压到本地缓存目录
      final tempDir = await getTemporaryDirectory();
      final assistantDir = Directory('${tempDir.path}/assets/$name');

      // 清理旧目录
      if (await assistantDir.exists()) {
        await assistantDir.delete(recursive: true);
      }
      await assistantDir.create(recursive: true);

      // 解压zip
      final archive = ZipDecoder().decodeBytes(zipData);
      for (final file in archive) {
        // 安全检查：防止路径遍历攻击
        final normalizedName = file.name.replaceAll('\\', '/');
        if (normalizedName.contains('..') || normalizedName.startsWith('/')) {
          debugPrint('⚠️ 跳过不安全的文件路径: ${file.name}');
          continue;
        }

        final filePath = '${assistantDir.path}/$normalizedName';
        if (file.isFile) {
          final data = file.content as List<int>;
          await File(filePath).create(recursive: true);
          await File(filePath).writeAsBytes(data);
        } else {
          await Directory(filePath).create(recursive: true);
        }
      }

      LoadingService.to.showSuccess('资源包已下载并解压');
      return true;
    } catch (e) {
      assetsError.value = e.toString();
      return false;
    } finally {
      isDownloadingAssets.value = false;
    }
  }

  /// 上传资源包
  Future<bool> uploadAssets(String name) async {
    isUploadingAssets.value = true;
    assetsError.value = null;

    try {
      // 选择zip文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        isUploadingAssets.value = false;
        return false;
      }

      final file = result.files.first;
      if (file.bytes == null) {
        isUploadingAssets.value = false;
        return false;
      }

      final uploadResult = await LoadingService.to.wrapLoading(
        () => apiService
            .uploadAssets(name, Uint8List.fromList(file.bytes!))
            .then((_) => true),
        message: '正在上传资源包...',
      );

      if (uploadResult == true) {
        LoadingService.to.showSuccess('资源包上传成功');
        return true;
      }
      return false;
    } catch (e) {
      assetsError.value = e.toString();
      return false;
    } finally {
      isUploadingAssets.value = false;
    }
  }

  /// 检查并更新资源（一键操作）
  Future<bool> checkAndUpdateAssets(String name) async {
    final checkResult = await checkAssetsUpdate(name);
    if (checkResult == null) return false;

    if (!checkResult.needsUpdate) {
      LoadingService.to.showSuccess('资源已是最新版本', title: '已是最新');
      return true;
    }

    return await downloadAssets(name);
  }
}
