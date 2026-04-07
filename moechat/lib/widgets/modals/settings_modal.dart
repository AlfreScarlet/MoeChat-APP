import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/settings_controller.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';

/// 服务配置设置弹窗
class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  late final TextEditingController _httpApiCtrl;
  late final TextEditingController _socketCtrl;
  late final SettingsController _settings;

  bool _isSaving = false; // 防止重复点击

  @override
  void initState() {
    super.initState();
    _settings = Get.find<SettingsController>();
    _httpApiCtrl = TextEditingController(text: _settings.httpApiUrl.value);
    _socketCtrl = TextEditingController(text: _settings.socketUrl.value);

    _animController = AnimationController(
      vsync: this,
      duration: AppTheme.standardDuration,
    );
    _scaleAnimation = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: AppTheme.standardCurve),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: AppTheme.standardCurve,
          ),
        );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: AppTheme.standardCurve),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    _httpApiCtrl.dispose();
    _socketCtrl.dispose();
    super.dispose();
  }

  void _close() {
    if (_isSaving) return;
    Get.back();
  }

  Future<void> _save() async {
    // 防止重复点击
    if (_isSaving) return;
    _isSaving = true;

    try {
      // 保存并连接（带加载动画和取消按钮）
      final success = await _settings.saveAndConnect(
        _httpApiCtrl.text,
        _socketCtrl.text,
      );

      // 连接成功才关闭对话框
      if (success) {
        Get.back();
      }
      // 失败时不关闭，让用户可以修改地址重试
    } finally {
      _isSaving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _close,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Transform.translate(
                offset: _slideAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(opacity: _fadeAnimation.value, child: child),
                ),
              );
            },
            child: GestureDetector(
              onTap: () {},
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 520,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.panelBg,
                    borderRadius: AppTheme.borderRadiusLarge,
                    boxShadow: const [AppTheme.largeShadow],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      Flexible(child: _buildBody()),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('服务配置', style: AppTheme.cjkStyle(fontSize: 16, fontWeight: 600)),
          InkWell(
            onTap: _close,
            borderRadius: AppTheme.borderRadiusSmall,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: const Icon(Icons.close, size: 16, color: AppTheme.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 客户端连接配置 ──
            _buildSectionHeader(
              Icons.settings_ethernet,
              '连接配置',
              badgeText: '客户端',
              badgeColor: AppTheme.primary,
              badgeBg: AppTheme.primaryLight,
            ),
            const SizedBox(height: 12),
            _buildConnectionCard(),
            const SizedBox(height: 24),

            // ── 服务端配置（只读） ──
            _buildSectionHeader(
              Icons.cloud_outlined,
              '服务端配置',
              badgeText: '只读',
              badgeColor: AppTheme.textSecondary,
              badgeBg: AppTheme.background,
            ),
            const SizedBox(height: 12),
            _buildServerCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    IconData icon,
    String title, {
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppTheme.cjkStyle(
            fontSize: 14,
            fontWeight: 600,
            color: AppTheme.text,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            badgeText,
            style: AppTheme.cjkStyle(
              fontSize: 10,
              fontWeight: 600,
              color: badgeColor,
            ),
          ),
        ),
      ],
    );
  }

  /// 连接配置卡片 — HTTP API + Socket 两个标准输入框
  Widget _buildConnectionCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabeledInput(
          label: 'HTTP API 地址',
          controller: _httpApiCtrl,
          placeholder: 'https://example.com/api',
        ),
        const SizedBox(height: 14),
        _buildLabeledInput(
          label: 'Socket 地址',
          controller: _socketCtrl,
          placeholder: 'ws://example.com/ws',
        ),
      ],
    );
  }

  /// 标准标签+输入框（复用添加助手页面的输入框样式）
  Widget _buildLabeledInput({
    required String label,
    required TextEditingController controller,
    required String placeholder,
  }) {
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

  /// 服务端配置卡片 — LLM / TTS / Agent 三组只读信息
  Widget _buildServerCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: AppTheme.borderRadiusSmall,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LLM
          _buildGroupHeader(Icons.psychology_outlined, 'LLM 配置'),
          const SizedBox(height: 8),
          _buildKvRow('base_url', mockSettings.llm.baseUrl),
          _buildKvRow('model', mockSettings.llm.model),
          _buildKvRow('api_key', mockSettings.llm.apiKey),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppTheme.border),
          ),

          // TTS
          _buildGroupHeader(Icons.record_voice_over_outlined, 'TTS 配置'),
          const SizedBox(height: 8),
          _buildKvRow('url', mockSettings.tts.url),
          _buildKvRow('ref_audio', mockSettings.tts.refAudio),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppTheme.border),
          ),

          // Agent
          _buildGroupHeader(Icons.smart_toy_outlined, 'Agent 状态'),
          const SizedBox(height: 8),
          _buildKvRowWithStatus(
            'status',
            mockSettings.agent.isUp ? '运行中' : '已停止',
            mockSettings.agent.isUp ? AppTheme.success : AppTheme.danger,
          ),
          _buildKvRow('name', mockSettings.agent.name),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.primary.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppTheme.cjkStyle(
            fontSize: 12,
            fontWeight: 600,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildKvRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTheme.cjkStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: AppTheme.cjkStyle(fontSize: 13, color: AppTheme.text),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKvRowWithStatus(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTheme.cjkStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: AppTheme.cjkStyle(
              fontSize: 13,
              fontWeight: 600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _close,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.borderRadiusSmall,
              ),
            ),
            child: Text(
              '取消',
              style: AppTheme.cjkStyle(fontSize: 13, fontWeight: 500),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.borderRadiusSmall,
              ),
              elevation: 0,
            ),
            child: Text(
              '保存',
              style: AppTheme.cjkStyle(fontSize: 13, fontWeight: 500),
            ),
          ),
        ],
      ),
    );
  }
}
