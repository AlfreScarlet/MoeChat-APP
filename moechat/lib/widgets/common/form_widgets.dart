import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 带标签的文本输入框（支持必填标记、多行、展开/收起）
///
/// 从 `_FieldWithLabel` 提取。
class ModalTextField extends StatefulWidget {
  final String label;
  final bool required;
  final String? labelSuffix;
  final bool multiline;
  final String placeholder;
  final TextEditingController controller;
  final bool enabled;

  const ModalTextField({
    super.key,
    required this.label,
    this.required = false,
    this.multiline = false,
    required this.placeholder,
    required this.controller,
    this.labelSuffix,
    this.enabled = true,
  });

  @override
  State<ModalTextField> createState() => _ModalTextFieldState();
}

class _ModalTextFieldState extends State<ModalTextField> {
  bool _expanded = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row with expand toggle on the right for multiline
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              RichText(
                text: TextSpan(
                  style: AppTheme.cjkStyle(
                    fontSize: 12,
                    fontWeight: 600,
                    color: AppTheme.textSecondary,
                  ),
                  children: [
                    TextSpan(text: widget.label),
                    if (widget.required)
                      TextSpan(
                        text: ' *',
                        style: const TextStyle(color: AppTheme.danger),
                      ),
                    if (widget.labelSuffix != null)
                      TextSpan(text: widget.labelSuffix),
                  ],
                ),
              ),
              if (widget.multiline) ...[const Spacer(), _buildExpandToggle()],
            ],
          ),
        ),
        // Input
        _buildInput(),
      ],
    );
  }

  Widget _buildExpandToggle() {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _expanded ? '收起' : '展开',
              style: AppTheme.cjkStyle(fontSize: 11, color: AppTheme.primary),
            ),
            Icon(
              _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 14,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    final border = OutlineInputBorder(
      borderRadius: AppTheme.borderRadiusSmall,
      borderSide: BorderSide(
        color: _focused ? AppTheme.primary : AppTheme.border,
      ),
    );

    return Focus(
      onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
      child: TextField(
        controller: widget.controller,
        enabled: widget.enabled,
        maxLines: widget.multiline ? (_expanded ? null : 3) : 1,
        minLines: widget.multiline ? (_expanded ? 6 : 2) : 1,
        style: AppTheme.cjkStyle(
          fontSize: 13,
          color: widget.enabled ? AppTheme.text : AppTheme.textSecondary,
        ),
        decoration: InputDecoration(
          hintText: widget.placeholder,
          hintStyle: AppTheme.cjkStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
          contentPadding: const EdgeInsets.all(10),
          border: border,
          enabledBorder: border,
          disabledBorder: border,
          focusedBorder: OutlineInputBorder(
            borderRadius: AppTheme.borderRadiusSmall,
            borderSide: const BorderSide(color: AppTheme.primary),
          ),
          isDense: true,
          filled: !widget.enabled,
          fillColor: widget.enabled ? null : AppTheme.background,
        ),
      ),
    );
  }
}

/// 区块分割标题（图标 + 标题）
///
/// 从 `_buildSectionDivider` 提取。
class ModalSectionDivider extends StatelessWidget {
  final String title;
  final IconData icon;

  const ModalSectionDivider({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: AppTheme.border),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(icon, size: 15, color: AppTheme.primary),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTheme.cjkStyle(
                fontSize: 13,
                fontWeight: 600,
                color: AppTheme.text,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 卡片式开关行（主项）
///
/// 从 `_buildCardToggle` 提取。
class ModalCardToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ModalCardToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.cjkStyle(fontSize: 13, color: AppTheme.text),
          ),
          ToggleBadge(value: value, onTap: () => onChanged(!value)),
        ],
      ),
    );
  }
}

/// 卡片式开关行（缩进子项）
///
/// 从 `_buildCardSubToggle` 提取。
class ModalCardSubToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ModalCardSubToggle({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.only(left: 28, right: 12, top: 7, bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.cjkStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          ToggleBadge(value: value, onTap: () => onChanged(!value)),
        ],
      ),
    );
  }
}

/// 卡片式数值输入行（缩进子项）
///
/// 从 `_buildCardSubInput` 提取。
class ModalCardSubInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;

  const ModalCardSubInput({
    super.key,
    required this.label,
    required this.controller,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.only(left: 28, right: 12, top: 7, bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.cjkStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(
            width: 60,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.end,
              style: AppTheme.cjkStyle(
                fontSize: 12,
                fontWeight: 600,
                color: AppTheme.textSecondary,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: AppTheme.cjkStyle(
                  fontSize: 12,
                  fontWeight: 600,
                  color: AppTheme.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// KV 输入行（上下文长度等）— 卡片样式
///
/// 从 `_buildKvInputRow` 提取。
class ModalKvInputRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;

  const ModalKvInputRow({
    super.key,
    required this.label,
    required this.controller,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: AppTheme.borderRadiusSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.cjkStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.end,
              style: AppTheme.cjkStyle(
                fontSize: 13,
                fontWeight: 600,
                color: AppTheme.text,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: AppTheme.cjkStyle(
                  fontSize: 13,
                  fontWeight: 600,
                  color: AppTheme.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 标签 + 输入框（settings_modal 样式）
///
/// 从 `_buildLabeledInput` (settings_modal) 提取。
class ModalLabeledInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;

  const ModalLabeledInput({
    super.key,
    required this.label,
    required this.controller,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            label,
            style: AppTheme.cjkStyle(
              fontSize: 12,
              fontWeight: 600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        TextField(
          controller: controller,
          style: AppTheme.cjkStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTheme.cjkStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
            contentPadding: const EdgeInsets.all(10),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: AppTheme.borderRadiusSmall,
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppTheme.borderRadiusSmall,
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppTheme.borderRadiusSmall,
              borderSide: const BorderSide(color: AppTheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}

/// 开启/关闭 徽章按钮
///
/// 从 `_ToggleBadge` 提取。
class ToggleBadge extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;

  const ToggleBadge({super.key, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          decoration: BoxDecoration(
            color: value ? AppTheme.toggleOnBg : AppTheme.toggleOffBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value ? '开启' : '关闭',
            style: AppTheme.cjkStyle(
              fontSize: 11,
              fontWeight: 600,
              color: value ? AppTheme.toggleOnText : AppTheme.toggleOffText,
            ),
          ),
        ),
      ),
    );
  }
}

/// 关闭按钮 (X icon)
///
/// 从 `_CloseButton` 提取。
class ModalCloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const ModalCloseButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.borderRadiusSmall,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: const Icon(Icons.close, size: 16, color: AppTheme.text),
      ),
    );
  }
}

/// 表单行容器 — 支持 2 列或 3 列并排布局
///
/// 从 `_FormRow` 提取。
class FormRow extends StatelessWidget {
  final List<Widget> children;
  final int columns;

  const FormRow({super.key, required this.children, this.columns = 2});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

/// 头像选择按钮 — 正方形设计，带优雅悬停效果
///
/// 特性：
/// - 固定 96x96 尺寸，圆角 12px
/// - 默认显示灰色背景 + 相机图标占位
/// - 悬停时显示紫色渐变遮罩和上传提示
/// - 支持 base64 图片预览
class AvatarPickerButton extends StatefulWidget {
  /// 当前头像的 base64 数据（如果有）
  final String? avatarBase64;

  /// 选择头像后的回调，返回 base64 编码的图片数据
  final ValueChanged<String>? onAvatarSelected;

  const AvatarPickerButton({
    super.key,
    this.avatarBase64,
    this.onAvatarSelected,
  });

  @override
  State<AvatarPickerButton> createState() => _AvatarPickerButtonState();
}

class _AvatarPickerButtonState extends State<AvatarPickerButton> {
  bool _hovered = false;
  Uint8List? _cachedBytes;

  @override
  void initState() {
    super.initState();
    _processAvatar();
  }

  @override
  void didUpdateWidget(AvatarPickerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarBase64 != widget.avatarBase64) {
      _processAvatar();
    }
  }

  void _processAvatar() {
    if (widget.avatarBase64 != null && widget.avatarBase64!.isNotEmpty) {
      try {
        _cachedBytes = base64Decode(widget.avatarBase64!);
      } catch (_) {
        _cachedBytes = null;
      }
    } else {
      _cachedBytes = null;
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      Uint8List? bytes = file.bytes;

      // 如果 bytes 为空，尝试从路径读取文件
      if (bytes == null && file.path != null) {
        final fileObj = File(file.path!);
        bytes = await fileObj.readAsBytes();
      }

      if (bytes == null || bytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无法读取图片文件')),
          );
        }
        return;
      }

      // 转换为 base64
      final base64String = base64Encode(bytes);

      // 调用回调
      widget.onAvatarSelected?.call(base64String);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
      }
    }
  }

  bool get _hasImage {
    return widget.avatarBase64 != null && widget.avatarBase64!.isNotEmpty;
  }

  Widget _buildImage() {
    if (_cachedBytes != null) {
      return Image.memory(
        _cachedBytes!,
        fit: BoxFit.cover,
        width: 96,
        height: 96,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 96,
      height: 96,
      color: const Color(0xFFF5F5F7),
      child: const Icon(
        Icons.camera_alt_outlined,
        size: 32,
        color: Color(0xFFB0B0C0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _pickImage,
        child: SizedBox(
          width: 96,
          height: 96,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 底层图片
                _buildImage(),

                // 边框
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hovered
                          ? AppTheme.primary.withValues(alpha: 0.6)
                          : const Color(0xFFE0E0E8),
                      width: _hovered ? 2 : 1,
                    ),
                  ),
                ),

                // 悬停遮罩
                AnimatedOpacity(
                  opacity: _hovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.7),
                          AppTheme.primary.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 28,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _hasImage ? '更换头像' : '上传头像',
                          style: AppTheme.cjkStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: 500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
