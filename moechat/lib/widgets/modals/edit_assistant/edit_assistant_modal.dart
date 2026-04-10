import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/home_controller.dart';
import '../../../models/assistant.dart';
import '../../../services/loading_service.dart';
import '../../../theme/app_theme.dart';
import '../../common/form_widgets.dart';
import 'basic_info_section.dart';
import 'feature_settings_section.dart';
import 'gsv_settings_section.dart';

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

  void _handleToggleChanged(String key, bool value) {
    setState(() {
      switch (key) {
        case 'longMemory':
          _enableLongMemory = value;
        case 'longMemorySearchEnhance':
          _enableLongMemorySearchEnhance = value;
        case 'coreMemory':
          _enableCoreMemory = value;
        case 'loreBooks':
          _enableLoreBooks = value;
        case 'emotionSystem':
          _enableEmotionSystem = value;
        case 'emotionPersist':
          _enableEmotionPersist = value;
      }
    });
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
          ModalCloseButton(onTap: _close),
        ],
      ),
    );
  }

  /// 可滚动表单区域 — 组合三个子区块
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
            BasicInfoSection(
              nameCtrl: _nameCtrl,
              userCtrl: _userCtrl,
              birthdayCtrl: _birthdayCtrl,
              heightCtrl: _heightCtrl,
              weightCtrl: _weightCtrl,
              extraDescCtrl: _extraDescCtrl,
              roleDescCtrl: _roleDescCtrl,
              personalityCtrl: _personalityCtrl,
              userSettingCtrl: _userSettingCtrl,
              messageExamplesCtrl: _messageExamplesCtrl,
              customPromptCtrl: _customPromptCtrl,
              startWithCtrl: _startWithCtrl,
              isEditing: widget.isEditing,
            ),

            // ── 功能设置 ──
            FeatureSettingsSection(
              contextLengthCtrl: _contextLengthCtrl,
              diaryThresholdCtrl: _diaryThresholdCtrl,
              worldBookThresholdCtrl: _worldBookThresholdCtrl,
              worldBookDepthCtrl: _worldBookDepthCtrl,
              enableLongMemory: _enableLongMemory,
              enableLongMemorySearchEnhance: _enableLongMemorySearchEnhance,
              enableCoreMemory: _enableCoreMemory,
              enableLoreBooks: _enableLoreBooks,
              enableEmotionSystem: _enableEmotionSystem,
              enableEmotionPersist: _enableEmotionPersist,
              onToggleChanged: _handleToggleChanged,
            ),

            // ── 语音设置 ──
            GsvSettingsSection(
              textLangCtrl: _gsvTextLangCtrl,
              promptLangCtrl: _gsvPromptLangCtrl,
              gptModelCtrl: _gsvGptModelCtrl,
              sovitsModelCtrl: _gsvSovitsModelCtrl,
              refAudioCtrl: _gsvRefAudioCtrl,
              promptTextCtrl: _gsvPromptTextCtrl,
              seedCtrl: _gsvSeedCtrl,
              topKCtrl: _gsvTopKCtrl,
              batchSizeCtrl: _gsvBatchSizeCtrl,
            ),
          ],
        ),
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
}
