import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../models/assistant.dart';
import '../../services/loading_service.dart';
import '../../theme/app_theme.dart';

/// 添加/编辑助手弹窗
///
/// 通过 Get.dialog() 显示，480px 宽度，最大高度 80vh。
/// 包含表单字段、必填星号标记、取消/保存按钮。
class EditAssistantModal extends StatefulWidget {
  final Assistant? assistant;

  const EditAssistantModal({super.key, this.assistant});

  bool get isEditing => assistant != null;

  @override
  State<EditAssistantModal> createState() => _EditAssistantModalState();
}

class _EditAssistantModalState extends State<EditAssistantModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  // 表单控制器
  late final TextEditingController _nameCtrl;
  late final TextEditingController _userCtrl;
  late final TextEditingController _birthdayCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _extraDescCtrl;
  late final TextEditingController _roleDescCtrl;
  late final TextEditingController _personalityCtrl;
  late final TextEditingController _userSettingCtrl;
  late final TextEditingController _messageExamplesCtrl;
  late final TextEditingController _customPromptCtrl;
  late final TextEditingController _startWithCtrl;
  late final TextEditingController _contextLengthCtrl;
  late final TextEditingController _diaryThresholdCtrl;
  late final TextEditingController _worldBookThresholdCtrl;
  late final TextEditingController _worldBookDepthCtrl;

  // GSV设置控制器
  late final TextEditingController _gsvTextLangCtrl;
  late final TextEditingController _gsvPromptLangCtrl;
  late final TextEditingController _gsvGptModelCtrl;
  late final TextEditingController _gsvSovitsModelCtrl;
  late final TextEditingController _gsvRefAudioCtrl;
  late final TextEditingController _gsvPromptTextCtrl;
  late final TextEditingController _gsvSeedCtrl;
  late final TextEditingController _gsvTopKCtrl;
  late final TextEditingController _gsvBatchSizeCtrl;

  // 开关状态
  late bool _enableLongMemory;
  late bool _enableLongMemorySearchEnhance;
  late bool _enableCoreMemory;
  late bool _enableLoreBooks;
  late bool _enableEmotionSystem;
  late bool _enableEmotionPersist;

  // 加载状态
  final _isSaving = false.obs;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initSettings();
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

  void _initControllers() {
    final a = widget.assistant;
    _nameCtrl = TextEditingController(text: a?.name ?? '');
    _userCtrl = TextEditingController(text: a?.userNickname ?? '');
    _birthdayCtrl = TextEditingController(text: a?.birthday ?? '');
    _heightCtrl = TextEditingController(text: a?.height ?? '');
    _weightCtrl = TextEditingController(text: a?.weight ?? '');
    _extraDescCtrl = TextEditingController(text: a?.extraDescription ?? '');
    _roleDescCtrl = TextEditingController(text: a?.roleDescription ?? '');
    _personalityCtrl = TextEditingController(text: a?.personality ?? '');
    _userSettingCtrl = TextEditingController(text: a?.userSetting ?? '');
    _messageExamplesCtrl = TextEditingController(
      text: a?.messageExamples?.join('\n') ?? '',
    );
    _customPromptCtrl = TextEditingController(text: a?.customPrompt ?? '');
    _startWithCtrl = TextEditingController(
      text: a?.greetings?.join('\n') ?? '',
    );

    final features = a?.features;
    _contextLengthCtrl = TextEditingController(
      text: features?.contextLength.toString() ?? '40',
    );
    _diaryThresholdCtrl = TextEditingController(
      text: features?.diarySearchThreshold.toString() ?? '0.38',
    );
    _worldBookThresholdCtrl = TextEditingController(
      text: features?.worldBookThreshold.toString() ?? '0.5',
    );
    _worldBookDepthCtrl = TextEditingController(
      text: features?.worldBookDepth.toString() ?? '3',
    );

    final gsv = a?.gsv;
    _gsvTextLangCtrl = TextEditingController(text: gsv?.textLang ?? 'zh');
    _gsvPromptLangCtrl = TextEditingController(text: gsv?.promptLang ?? 'zh');
    _gsvGptModelCtrl = TextEditingController(text: gsv?.gptModelPath ?? '');
    _gsvSovitsModelCtrl = TextEditingController(
      text: gsv?.sovitsModelPath ?? '',
    );
    _gsvRefAudioCtrl = TextEditingController(text: gsv?.refAudioPath ?? '');
    _gsvPromptTextCtrl = TextEditingController(text: gsv?.promptText ?? '');
    _gsvSeedCtrl = TextEditingController(text: gsv?.seed?.toString() ?? '-1');
    _gsvTopKCtrl = TextEditingController(text: gsv?.topK?.toString() ?? '30');
    _gsvBatchSizeCtrl = TextEditingController(
      text: gsv?.batchSize?.toString() ?? '20',
    );
  }

  void _initSettings() {
    final features = widget.assistant?.features;
    _enableLongMemory = features?.diary ?? true;
    _enableLongMemorySearchEnhance = features?.diarySearchBoost ?? true;
    _enableCoreMemory = features?.coreMemory ?? true;
    _enableLoreBooks = features?.worldBook ?? true;
    _enableEmotionSystem = features?.emotionSystem ?? false;
    _enableEmotionPersist = features?.emotionPersist ?? false;
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _nameCtrl.dispose();
    _userCtrl.dispose();
    _birthdayCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _extraDescCtrl.dispose();
    _roleDescCtrl.dispose();
    _personalityCtrl.dispose();
    _userSettingCtrl.dispose();
    _messageExamplesCtrl.dispose();
    _customPromptCtrl.dispose();
    _startWithCtrl.dispose();
    _contextLengthCtrl.dispose();
    _diaryThresholdCtrl.dispose();
    _worldBookThresholdCtrl.dispose();
    _worldBookDepthCtrl.dispose();
    _gsvTextLangCtrl.dispose();
    _gsvPromptLangCtrl.dispose();
    _gsvGptModelCtrl.dispose();
    _gsvSovitsModelCtrl.dispose();
    _gsvRefAudioCtrl.dispose();
    _gsvPromptTextCtrl.dispose();
    _gsvSeedCtrl.dispose();
    _gsvTopKCtrl.dispose();
    _gsvBatchSizeCtrl.dispose();
  }

  void _close() => Get.back();

  Future<void> _save() async {
    // 验证必填字段
    if (_nameCtrl.text.trim().isEmpty) {
      _showValidationError('请填写助手名称');
      return;
    }
    if (_birthdayCtrl.text.trim().isEmpty) {
      _showValidationError('请填写生日');
      return;
    }
    if (_heightCtrl.text.trim().isEmpty) {
      _showValidationError('请填写身高');
      return;
    }
    if (_weightCtrl.text.trim().isEmpty) {
      _showValidationError('请填写体重');
      return;
    }
    if (_personalityCtrl.text.trim().isEmpty) {
      _showValidationError('请填写性格描述');
      return;
    }
    if (_roleDescCtrl.text.trim().isEmpty) {
      _showValidationError('请填写角色设定');
      return;
    }

    _isSaving.value = true;

    final controller = Get.find<HomeController>();
    final success = widget.isEditing
        ? await _updateAssistant(controller)
        : await _addAssistant(controller);

    _isSaving.value = false;

    if (success) {
      final msg = widget.isEditing ? '助手信息已更新' : '助手创建成功';
      _close();
      // 延迟显示提示，确保弹窗关闭后再弹 toast
      Future.delayed(const Duration(milliseconds: 200), () {
        LoadingService.to.showSuccess(msg);
      });
    }
  }

  Future<bool> _addAssistant(HomeController controller) async {
    return await controller.addAssistant(
      name: _nameCtrl.text.trim(),
      avatar: 'assets/logo1.png', // 默认头像
      birthday: _birthdayCtrl.text.trim(),
      height: _heightCtrl.text.trim(),
      weight: _weightCtrl.text.trim(),
      personality: _personalityCtrl.text.trim(),
      description: _roleDescCtrl.text.trim(),
      user: _userCtrl.text.trim().isEmpty ? null : _userCtrl.text.trim(),
      mask: _userSettingCtrl.text.trim().isEmpty
          ? null
          : _userSettingCtrl.text.trim(),
      messageExamples: _parseListField(_messageExamplesCtrl.text),
      extraDescription: _extraDescCtrl.text.trim().isEmpty
          ? null
          : _extraDescCtrl.text.trim(),
      customPrompt: _customPromptCtrl.text.trim().isEmpty
          ? null
          : _customPromptCtrl.text.trim(),
      startWith: _parseListField(_startWithCtrl.text),
      settings: _buildFeatureSettings(),
      gsvSetting: _buildGsvSettings(),
    );
  }

  Future<bool> _updateAssistant(HomeController controller) async {
    return await controller.editAssistant(
      name: widget.assistant!.name,
      avatar: widget.assistant!.avatar,
      birthday: _birthdayCtrl.text.trim(),
      height: _heightCtrl.text.trim(),
      weight: _weightCtrl.text.trim(),
      personality: _personalityCtrl.text.trim(),
      description: _roleDescCtrl.text.trim(),
      // 编辑时始终传递这些字段（空字符串表示清空）
      user: _userCtrl.text.trim(),
      mask: _userSettingCtrl.text.trim(),
      messageExamples: _parseListField(_messageExamplesCtrl.text) ?? [],
      extraDescription: _extraDescCtrl.text.trim(),
      customPrompt: _customPromptCtrl.text.trim(),
      startWith: _parseListField(_startWithCtrl.text) ?? [],
      settings: _buildFeatureSettings(),
      gsvSetting: _buildGsvSettings(),
    );
  }

  List<String>? _parseListField(String text) {
    if (text.trim().isEmpty) return null;
    return text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  FeatureSettings _buildFeatureSettings() {
    return FeatureSettings(
      contextLength: int.tryParse(_contextLengthCtrl.text) ?? 40,
      diary: _enableLongMemory,
      diarySearchBoost: _enableLongMemorySearchEnhance,
      diarySearchThreshold: double.tryParse(_diaryThresholdCtrl.text) ?? 0.38,
      coreMemory: _enableCoreMemory,
      worldBook: _enableLoreBooks,
      worldBookThreshold: double.tryParse(_worldBookThresholdCtrl.text) ?? 0.5,
      worldBookDepth: int.tryParse(_worldBookDepthCtrl.text) ?? 3,
      emotionSystem: _enableEmotionSystem,
      emotionPersist: _enableEmotionPersist,
    );
  }

  GsvSettings _buildGsvSettings() {
    return GsvSettings(
      textLang: _gsvTextLangCtrl.text.trim().isEmpty
          ? 'zh'
          : _gsvTextLangCtrl.text.trim(),
      promptLang: _gsvPromptLangCtrl.text.trim().isEmpty
          ? 'zh'
          : _gsvPromptLangCtrl.text.trim(),
      gptModelPath: _gsvGptModelCtrl.text.trim().isEmpty
          ? null
          : _gsvGptModelCtrl.text.trim(),
      sovitsModelPath: _gsvSovitsModelCtrl.text.trim().isEmpty
          ? null
          : _gsvSovitsModelCtrl.text.trim(),
      refAudioPath: _gsvRefAudioCtrl.text.trim().isEmpty
          ? null
          : _gsvRefAudioCtrl.text.trim(),
      promptText: _gsvPromptTextCtrl.text.trim().isEmpty
          ? null
          : _gsvPromptTextCtrl.text.trim(),
      seed: int.tryParse(_gsvSeedCtrl.text) ?? -1,
      topK: int.tryParse(_gsvTopKCtrl.text) ?? 30,
      batchSize: int.tryParse(_gsvBatchSizeCtrl.text) ?? 20,
    );
  }

  void _showValidationError(String message) {
    LoadingService.to.showError(message, title: '验证错误');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.8;

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
              onTap: () {}, // prevent backdrop tap from closing
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 480,
                  constraints: BoxConstraints(maxHeight: maxHeight),
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

  /// 头部：标题 + 关闭按钮
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.isEditing ? '编辑助手' : '添加助手',
            style: AppTheme.cjkStyle(fontSize: 16, fontWeight: 600),
          ),
          _CloseButton(onTap: _close),
        ],
      ),
    );
  }

  /// 可滚动表单区域
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
            // ── 基本信息 ──
            // 头像（左侧跨两行）+ 右侧两行表单
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AvatarPickerButton(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _FormRow(
                          children: [
                            _buildTextField(
                              label: '名称',
                              placeholder: '助手名称',
                              controller: _nameCtrl,
                              required: true,
                              isLast: true,
                              enabled: !widget.isEditing, // 编辑时禁止修改名称
                            ),
                            _buildTextField(
                              label: '对用户的称呼',
                              placeholder: '阁下',
                              controller: _userCtrl,
                              isLast: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _FormRow(
                          columns: 3,
                          children: [
                            _buildTextField(
                              label: '生日',
                              placeholder: '2000-01-01',
                              controller: _birthdayCtrl,
                              required: true,
                              isLast: true,
                            ),
                            _buildTextField(
                              label: '身高',
                              placeholder: '165',
                              controller: _heightCtrl,
                              required: true,
                              isLast: true,
                            ),
                            _buildTextField(
                              label: '体重',
                              placeholder: '48',
                              controller: _weightCtrl,
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
            _buildTextField(
              label: '额外描述',
              placeholder: '可选的额外描述信息',
              controller: _extraDescCtrl,
              multiline: true,
            ),
            _buildTextField(
              label: '角色设定',
              placeholder: '角色的描述信息，注入 system prompt',
              controller: _roleDescCtrl,
              required: true,
              multiline: true,
            ),
            _buildTextField(
              label: '性格',
              placeholder: '性格描述，注入 system prompt',
              controller: _personalityCtrl,
              required: true,
              multiline: true,
            ),
            _buildTextField(
              label: '用户设定',
              placeholder: '用户的设定，注入 system prompt',
              controller: _userSettingCtrl,
              multiline: true,
            ),
            _buildTextField(
              label: '对话案例',
              placeholder: '每行一条，用于强化文风',
              controller: _messageExamplesCtrl,
              multiline: true,
              labelSuffix: '（每行一条）',
            ),
            _buildTextField(
              label: '自定义提示词',
              placeholder: '直接追加到 prompt 末尾',
              controller: _customPromptCtrl,
              multiline: true,
            ),
            _buildTextField(
              label: '开场白',
              placeholder: '每行一条，按 user/assistant 交替插入',
              controller: _startWithCtrl,
              multiline: true,
              labelSuffix: '（每行一条）',
            ),

            // ── 功能设置 (AssistantSettings) ──
            const SizedBox(height: 6),
            _buildSectionDivider('功能设置', Icons.tune),
            const SizedBox(height: 12),
            // 上下文长度 KV 卡片
            _buildKvInputRow('上下文长度', _contextLengthCtrl, '40'),
            const SizedBox(height: 6),
            // 开关组（卡片式，1px 间隔）
            ClipRRect(
              borderRadius: AppTheme.borderRadiusSmall,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: AppTheme.borderRadiusSmall,
                ),
                child: Column(
                  children: [
                    _buildCardToggle('日记（长期记忆）', _enableLongMemory, (v) {
                      setState(() => _enableLongMemory = v);
                    }),
                    const SizedBox(height: 1),
                    _buildCardToggle('日记检索加强', _enableLongMemorySearchEnhance, (
                      v,
                    ) {
                      setState(() => _enableLongMemorySearchEnhance = v);
                    }),
                    const SizedBox(height: 1),
                    _buildCardSubInput('搜索阈值', _diaryThresholdCtrl, '0.38'),
                    const SizedBox(height: 1),
                    _buildCardToggle('核心记忆', _enableCoreMemory, (v) {
                      setState(() => _enableCoreMemory = v);
                    }),
                    const SizedBox(height: 1),
                    _buildCardToggle('知识库（世界书）', _enableLoreBooks, (v) {
                      setState(() => _enableLoreBooks = v);
                    }),
                    const SizedBox(height: 1),
                    _buildCardSubInput('搜索阈值', _worldBookThresholdCtrl, '0.5'),
                    const SizedBox(height: 1),
                    _buildCardSubInput('搜索深度', _worldBookDepthCtrl, '3'),
                    const SizedBox(height: 1),
                    _buildCardToggle('情绪系统', _enableEmotionSystem, (v) {
                      setState(() => _enableEmotionSystem = v);
                    }),
                    const SizedBox(height: 1),
                    _buildCardSubToggle('情绪持续存储', _enableEmotionPersist, (v) {
                      setState(() => _enableEmotionPersist = v);
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── 语音设置 (GSVSetting) ──
            const SizedBox(height: 6),
            _buildSectionDivider(
              '语音设置 (GSV)',
              Icons.record_voice_over_outlined,
            ),
            const SizedBox(height: 12),
            _FormRow(
              children: [
                _buildTextField(
                  label: '合成语言',
                  placeholder: 'zh',
                  controller: _gsvTextLangCtrl,
                ),
                _buildTextField(
                  label: '参考文字语言',
                  placeholder: 'zh',
                  controller: _gsvPromptLangCtrl,
                ),
              ],
            ),
            _buildTextField(
              label: 'GPT 模型路径',
              placeholder: 'models/gpt.ckpt',
              controller: _gsvGptModelCtrl,
            ),
            _buildTextField(
              label: 'SoVITS 模型路径',
              placeholder: 'models/sovits.pth',
              controller: _gsvSovitsModelCtrl,
            ),
            _buildTextField(
              label: '参考音频路径',
              placeholder: 'audio/ref.wav',
              controller: _gsvRefAudioCtrl,
            ),
            _buildTextField(
              label: '参考音频文字',
              placeholder: '参考音频对应的文字内容',
              controller: _gsvPromptTextCtrl,
            ),
            _FormRow(
              columns: 3,
              children: [
                _buildTextField(
                  label: 'Seed',
                  placeholder: '-1',
                  controller: _gsvSeedCtrl,
                ),
                _buildTextField(
                  label: 'TopK',
                  placeholder: '30',
                  controller: _gsvTopKCtrl,
                ),
                _buildTextField(
                  label: 'BatchSize',
                  placeholder: '20',
                  controller: _gsvBatchSizeCtrl,
                  isLast: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 区块分割标题
  Widget _buildSectionDivider(String title, IconData icon) {
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

  /// KV 输入行（上下文长度等）— 卡片样式
  Widget _buildKvInputRow(
    String label,
    TextEditingController controller,
    String placeholder,
  ) {
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

  /// 卡片式开关行（主项）
  Widget _buildCardToggle(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
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
          _ToggleBadge(value: value, onTap: () => onChanged(!value)),
        ],
      ),
    );
  }

  /// 卡片式开关行（缩进子项）
  Widget _buildCardSubToggle(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
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
          _ToggleBadge(value: value, onTap: () => onChanged(!value)),
        ],
      ),
    );
  }

  /// 卡片式数值输入行（缩进子项）
  Widget _buildCardSubInput(
    String label,
    TextEditingController controller,
    String placeholder,
  ) {
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

  Widget _buildFooter() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 取消按钮
            TextButton(
              onPressed: _isSaving.value ? null : _close,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                disabledForegroundColor: AppTheme.textSecondary.withValues(
                  alpha: 0.3,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
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
            // 保存按钮
            ElevatedButton(
              onPressed: _isSaving.value ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.primary.withValues(
                  alpha: 0.3,
                ),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.borderRadiusSmall,
                ),
                elevation: 0,
              ),
              child: _isSaving.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      '保存',
                      style: AppTheme.cjkStyle(fontSize: 13, fontWeight: 500),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建单个表单字段（文本输入或多行文本框）
  Widget _buildTextField({
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
      child: _FieldWithLabel(
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

/// 表单行容器 — 支持 2 列或 3 列并排布局
class _FormRow extends StatelessWidget {
  final List<Widget> children;
  final int columns;

  const _FormRow({required this.children, this.columns = 2});

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

/// 头像选择按钮 — 跨两行显示，带悬停遮罩效果
class _AvatarPickerButton extends StatefulWidget {
  @override
  State<_AvatarPickerButton> createState() => _AvatarPickerButtonState();
}

class _AvatarPickerButtonState extends State<_AvatarPickerButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // TODO: 实现头像上传
        },
        child: Stack(
          children: [
            AnimatedContainer(
              duration: AppTheme.standardDuration,
              width: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _hovered
                      ? AppTheme.primary.withValues(alpha: 0.5)
                      : AppTheme.primary.withValues(alpha: 0.2),
                  width: _hovered ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset('assets/logo1.png', fit: BoxFit.cover),
              ),
            ),
            // 悬停遮罩
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _hovered ? 1.0 : 0.0,
                duration: AppTheme.standardDuration,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppTheme.primary.withValues(alpha: 0.55),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 24,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '上传头像',
                        style: AppTheme.cjkStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 表单字段：标签行（含展开按钮）+ 输入框
class _FieldWithLabel extends StatefulWidget {
  final String label;
  final bool required;
  final String? labelSuffix;
  final bool multiline;
  final String placeholder;
  final TextEditingController controller;
  final bool enabled;

  const _FieldWithLabel({
    required this.label,
    required this.required,
    required this.multiline,
    required this.placeholder,
    required this.controller,
    this.labelSuffix,
    this.enabled = true,
  });

  @override
  State<_FieldWithLabel> createState() => _FieldWithLabelState();
}

class _FieldWithLabelState extends State<_FieldWithLabel> {
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

/// 开启/关闭 徽章按钮
class _ToggleBadge extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;

  const _ToggleBadge({required this.value, required this.onTap});

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
class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

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
