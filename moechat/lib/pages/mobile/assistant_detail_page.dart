import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../models/assistant.dart';
import '../../repositories/assistant_repository.dart';
import '../../services/avatar_cache_service.dart';
import '../../services/loading_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/modals/edit_assistant/basic_info_section.dart';
import '../../widgets/modals/edit_assistant/feature_settings_section.dart';
import '../../widgets/modals/edit_assistant/gsv_settings_section.dart';

/// 助手详情页面 - 移动端
///
/// 用于创建新助手或编辑现有助手
/// 复用PC端 EditAssistantModal 的表单组件
class AssistantDetailPage extends StatefulWidget {
  final Assistant? assistant; // null = 创建模式

  const AssistantDetailPage({super.key, this.assistant});

  bool get isEditing => assistant != null;

  @override
  State<AssistantDetailPage> createState() => _AssistantDetailPageState();
}

class _AssistantDetailPageState extends State<AssistantDetailPage> {
  final _scrollController = ScrollController();

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
  bool _isSaving = false;

  // 头像状态
  String? _avatarBase64;
  bool _isLoadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initSettings();
  }

  void _initControllers() {
    final a = widget.assistant;
    _nameCtrl = TextEditingController(text: a?.name ?? '');

    // 如果是编辑模式，加载现有头像
    if (widget.isEditing) {
      _loadExistingAvatar();
    }
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

  /// 加载现有头像
  Future<void> _loadExistingAvatar() async {
    if (_isLoadingAvatar) return;
    _isLoadingAvatar = true;

    try {
      final repository = Get.find<AssistantRepository>();
      final base64Image = await repository.fetchAvatar(widget.assistant!.name);
      if (mounted) {
        setState(() {
          _avatarBase64 = base64Image;
        });
      }
    } catch (e) {
      // 头像加载失败不阻止用户编辑，静默处理
      debugPrint('加载头像失败: $e');
    } finally {
      _isLoadingAvatar = false;
    }
  }

  /// 处理头像选择
  void _handleAvatarSelected(String base64Data) {
    setState(() {
      _avatarBase64 = base64Data;
    });
  }

  /// 上传头像到服务器
  Future<bool> _uploadAvatar(String assistantName) async {
    if (_avatarBase64 == null || _avatarBase64!.isEmpty) return true;

    try {
      final repository = Get.find<AssistantRepository>();
      await repository.uploadAvatar(assistantName, _avatarBase64!);

      // 更新本地缓存，触发 UI 刷新
      AvatarCacheService.to.updateAvatar(assistantName, _avatarBase64!);

      return true;
    } catch (e) {
      debugPrint('上传头像失败: $e');
      return false;
    }
  }

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

    if (_isSaving) return;
    setState(() => _isSaving = true);

    final controller = Get.find<HomeController>();
    final success = widget.isEditing
        ? await _updateAssistant(controller)
        : await _addAssistant(controller);

    setState(() => _isSaving = false);

    if (success && mounted) {
      final msg = widget.isEditing ? '助手信息已更新' : '助手创建成功';
      Get.back();
      // 延迟显示提示，确保页面关闭后再弹 toast
      Future.delayed(const Duration(milliseconds: 200), () {
        LoadingService.to.showSuccess(msg);
      });
    }
  }

  Future<bool> _addAssistant(HomeController controller) async {
    final name = _nameCtrl.text.trim();
    final success = await controller.addAssistant(
      name: name,
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

    // 如果助手创建成功且选择了头像，上传头像
    if (success && _avatarBase64 != null && _avatarBase64!.isNotEmpty) {
      await _uploadAvatar(name);
    }

    return success;
  }

  Future<bool> _updateAssistant(HomeController controller) async {
    final name = widget.assistant!.name;
    final success = await controller.editAssistant(
      name: name,
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

    // 如果助手更新成功且选择了新头像，上传头像
    if (success && _avatarBase64 != null && _avatarBase64!.isNotEmpty) {
      await _uploadAvatar(name);
    }

    return success;
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 56,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.isEditing ? '编辑助手' : '添加助手'),
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
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
        ],
      ),
      body: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 基本信息
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
                avatarBase64: _avatarBase64,
                onAvatarSelected: _handleAvatarSelected,
              ),

              // 功能设置
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

              // 语音设置
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

              // 底部留白
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
