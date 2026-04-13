import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/settings_controller.dart';
import '../../data/mock_data.dart';
import '../../services/loading_service.dart';
import '../../widgets/common/form_widgets.dart';

/// 设置页面 - 移动端
///
/// 复刻PC端SettingsModal的布局，以全屏页面形式展示
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _httpApiCtrl;
  late final TextEditingController _socketCtrl;
  late final SettingsController _settings;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _settings = Get.find<SettingsController>();
    _httpApiCtrl = TextEditingController(text: _settings.httpApiUrl.value);
    _socketCtrl = TextEditingController(text: _settings.socketUrl.value);
  }

  @override
  void dispose() {
    _httpApiCtrl.dispose();
    _socketCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // 保存并连接（带加载动画和取消按钮）
      final success = await _settings.saveAndConnect(
        _httpApiCtrl.text,
        _socketCtrl.text,
      );

      // 连接成功才显示提示
      if (success && mounted) {
        // 延迟显示，确保loading完全处理完毕
        await Future.delayed(const Duration(milliseconds: 200));
        if (mounted) {
          LoadingService.to.showSuccess('保存成功');
        }
      }
      // 失败时不显示额外提示（saveAndConnect内部已处理）
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        title: const Text('设置'),
        actions: [
          _isSaving
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: TextButton(
                    onPressed: _save,
                    child: Text(
                      '保存',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 连接配置区
            _buildSectionHeader(
              Icons.settings_ethernet,
              '连接配置',
              badgeText: '客户端',
              badgeColor: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 12),
            _buildConnectionCard(),
            const SizedBox(height: 24),

            // 服务端配置区（只读）
            _buildSectionHeader(
              Icons.cloud_outlined,
              '服务端配置',
              badgeText: '只读',
              badgeColor: Colors.grey,
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
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
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
        ModalLabeledInput(
          label: 'HTTP API 地址',
          controller: _httpApiCtrl,
          placeholder: 'http://example.com/api',
        ),
        const SizedBox(height: 14),
        ModalLabeledInput(
          label: 'Socket 地址',
          controller: _socketCtrl,
          placeholder: 'socket://example.com:9092',
        ),
      ],
    );
  }

  /// 服务端配置卡片 — LLM / TTS / Agent 三组只读信息
  Widget _buildServerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
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
            child: Divider(height: 1),
          ),

          // TTS
          _buildGroupHeader(Icons.record_voice_over_outlined, 'TTS 配置'),
          const SizedBox(height: 8),
          _buildKvRow('url', mockSettings.tts.url),
          _buildKvRow('ref_audio', mockSettings.tts.refAudio),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // Agent
          _buildGroupHeader(Icons.smart_toy_outlined, 'Agent 状态'),
          const SizedBox(height: 8),
          _buildKvRowWithStatus(
            'status',
            mockSettings.agent.isUp ? '运行中' : '已停止',
            mockSettings.agent.isUp ? Colors.green : Colors.red,
          ),
          _buildKvRow('name', mockSettings.agent.name),
        ],
      ),
    );
  }

  Widget _buildGroupHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
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
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
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
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
