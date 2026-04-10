import 'package:flutter/material.dart';

import '../../common/form_widgets.dart';

/// GSV 语音设置区块 — 合成语言、参考文字语言、GPT 模型路径、
/// SoVITS 模型路径、参考音频路径、参考音频文字、seed、topK、batchSize
///
/// 接收 TextEditingController，不管理状态。
class GsvSettingsSection extends StatelessWidget {
  final TextEditingController textLangCtrl;
  final TextEditingController promptLangCtrl;
  final TextEditingController gptModelCtrl;
  final TextEditingController sovitsModelCtrl;
  final TextEditingController refAudioCtrl;
  final TextEditingController promptTextCtrl;
  final TextEditingController seedCtrl;
  final TextEditingController topKCtrl;
  final TextEditingController batchSizeCtrl;

  const GsvSettingsSection({
    super.key,
    required this.textLangCtrl,
    required this.promptLangCtrl,
    required this.gptModelCtrl,
    required this.sovitsModelCtrl,
    required this.refAudioCtrl,
    required this.promptTextCtrl,
    required this.seedCtrl,
    required this.topKCtrl,
    required this.batchSizeCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        const ModalSectionDivider(
          title: '语音设置 (GSV)',
          icon: Icons.record_voice_over_outlined,
        ),
        const SizedBox(height: 12),
        FormRow(
          children: [
            _field(label: '合成语言', placeholder: 'zh', controller: textLangCtrl),
            _field(
              label: '参考文字语言',
              placeholder: 'zh',
              controller: promptLangCtrl,
            ),
          ],
        ),
        _field(
          label: 'GPT 模型路径',
          placeholder: 'models/gpt.ckpt',
          controller: gptModelCtrl,
        ),
        _field(
          label: 'SoVITS 模型路径',
          placeholder: 'models/sovits.pth',
          controller: sovitsModelCtrl,
        ),
        _field(
          label: '参考音频路径',
          placeholder: 'audio/ref.wav',
          controller: refAudioCtrl,
        ),
        _field(
          label: '参考音频文字',
          placeholder: '参考音频对应的文字内容',
          controller: promptTextCtrl,
        ),
        FormRow(
          columns: 3,
          children: [
            _field(label: 'Seed', placeholder: '-1', controller: seedCtrl),
            _field(label: 'TopK', placeholder: '30', controller: topKCtrl),
            _field(
              label: 'BatchSize',
              placeholder: '20',
              controller: batchSizeCtrl,
              isLast: true,
            ),
          ],
        ),
      ],
    );
  }

  /// 构建单个表单字段
  Widget _field({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: ModalTextField(
        label: label,
        placeholder: placeholder,
        controller: controller,
      ),
    );
  }
}
