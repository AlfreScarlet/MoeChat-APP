import 'package:flutter/material.dart';

import '../../common/form_widgets.dart';

/// 基本信息区块 — 头像、名称、生日、身高、体重、用户昵称、
/// 额外描述、角色设定、性格、用户设定、对话案例、自定义提示词、开场白
///
/// 接收 TextEditingController 和 isEditing 标志，不管理状态。
class BasicInfoSection extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController userCtrl;
  final TextEditingController birthdayCtrl;
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController extraDescCtrl;
  final TextEditingController roleDescCtrl;
  final TextEditingController personalityCtrl;
  final TextEditingController userSettingCtrl;
  final TextEditingController messageExamplesCtrl;
  final TextEditingController customPromptCtrl;
  final TextEditingController startWithCtrl;
  final bool isEditing;

  /// 当前头像的 base64 数据
  final String? avatarBase64;

  /// 头像选择回调
  final ValueChanged<String>? onAvatarSelected;

  const BasicInfoSection({
    super.key,
    required this.nameCtrl,
    required this.userCtrl,
    required this.birthdayCtrl,
    required this.heightCtrl,
    required this.weightCtrl,
    required this.extraDescCtrl,
    required this.roleDescCtrl,
    required this.personalityCtrl,
    required this.userSettingCtrl,
    required this.messageExamplesCtrl,
    required this.customPromptCtrl,
    required this.startWithCtrl,
    required this.isEditing,
    this.avatarBase64,
    this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 头像（左侧跨两行）+ 右侧两行表单
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AvatarPickerButton(
                avatarBase64: avatarBase64,
                onAvatarSelected: onAvatarSelected,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FormRow(
                      children: [
                        _field(
                          label: '名称',
                          placeholder: '助手名称',
                          controller: nameCtrl,
                          required: true,
                          isLast: true,
                          enabled: !isEditing,
                        ),
                        _field(
                          label: '对用户的称呼',
                          placeholder: '阁下',
                          controller: userCtrl,
                          isLast: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FormRow(
                      columns: 3,
                      children: [
                        _field(
                          label: '生日',
                          placeholder: '2000-01-01',
                          controller: birthdayCtrl,
                          required: true,
                          isLast: true,
                        ),
                        _field(
                          label: '身高',
                          placeholder: '165',
                          controller: heightCtrl,
                          required: true,
                          isLast: true,
                        ),
                        _field(
                          label: '体重',
                          placeholder: '48',
                          controller: weightCtrl,
                          required: true,
                          isLast: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _field(
          label: '额外描述',
          placeholder: '可选的额外描述信息',
          controller: extraDescCtrl,
          multiline: true,
        ),
        _field(
          label: '角色设定',
          placeholder: '角色的描述信息，注入 system prompt',
          controller: roleDescCtrl,
          required: true,
          multiline: true,
        ),
        _field(
          label: '性格',
          placeholder: '性格描述，注入 system prompt',
          controller: personalityCtrl,
          required: true,
          multiline: true,
        ),
        _field(
          label: '用户设定',
          placeholder: '用户的设定，注入 system prompt',
          controller: userSettingCtrl,
          multiline: true,
        ),
        _field(
          label: '对话案例',
          placeholder: '每行一条，用于强化文风',
          controller: messageExamplesCtrl,
          multiline: true,
          labelSuffix: '（每行一条）',
        ),
        _field(
          label: '自定义提示词',
          placeholder: '直接追加到 prompt 末尾',
          controller: customPromptCtrl,
          multiline: true,
        ),
        _field(
          label: '开场白',
          placeholder: '每行一条，按 user/assistant 交替插入',
          controller: startWithCtrl,
          multiline: true,
          labelSuffix: '（每行一条）',
        ),
      ],
    );
  }

  /// 构建单个表单字段（文本输入或多行文本框）
  Widget _field({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    bool required = false,
    bool multiline = false,
    bool isLast = false,
    String? labelSuffix,
    bool enabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: ModalTextField(
        label: label,
        required: required,
        labelSuffix: labelSuffix,
        multiline: multiline,
        placeholder: placeholder,
        controller: controller,
        enabled: enabled,
      ),
    );
  }
}
