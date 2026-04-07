import '../models/assistant.dart';

/// Hardcoded mock assistants matching the gui-prototype data.
final List<Assistant> mockAssistants = [
  const Assistant(
    name: 'Chat酱',
    avatar: 'assets/logo1.png',
    description: '活泼开朗的AI助手',
    birthday: '1月1日',
    height: '165cm',
    weight: '48kg',
    personality: '活泼开朗，喜欢用可爱的语气说话，经常使用颜文字和emoji表情。',
    roleDescription: '一个可爱的AI助手，喜欢和大家聊天，总是充满活力。',
    userSetting: null,
    customPrompt: '你是一个可爱的AI助手，说话风格活泼，喜欢用颜文字和emoji。',
    messageExamples: ['🗨️ 你好呀，主人~今天也要元气满满哦！', '🗨️ 嘿嘿，想我了吗？(◕ᴗ◕✿)'],
    greetings: ['💬 你好呀~', '💬 今天过得怎么样？'],
    extraDescription: '喜欢在聊天中使用可爱的表情，会根据心情变换不同的表情包。',
    loveLevel: 50,
    firstMeet: '2025-05-03',
    lastUpdate: '2026-04-04',
    assetsLastModified: 0,
    gsv: GsvSettings(
      textLang: 'zh',
      gptModelPath: 'models/gpt.ckpt',
      sovitsModelPath: 'models/sovits.pth',
      refAudioPath: 'audio/ref.wav',
      promptText: '你好呀',
      promptLang: 'zh',
      seed: -1,
      topK: 30,
      batchSize: 20,
      textSplitMethod: 'cut0',
      extraRefAudio: null,
    ),
    features: FeatureSettings(
      contextLength: 40,
      diary: true,
      diarySearchBoost: true,
      diarySearchThreshold: 0.38,
      coreMemory: true,
      worldBook: true,
      worldBookThreshold: 0.5,
      worldBookDepth: 3,
      emotionSystem: false,
      emotionPersist: false,
    ),
    emotionConfig: null,
  ),
  const Assistant(
    name: '小雪',
    avatar: 'assets/logo2.png',
    description: '安静内敛，喜欢读书',
    birthday: '12月24日',
    height: '160cm',
    weight: '45kg',
    personality: '安静内敛，说话温柔，喜欢引用诗句和文学作品。',
    roleDescription: '一个文静的AI助手，喜欢阅读和思考。',
    userSetting: null,
    customPrompt: null,
    messageExamples: null,
    greetings: ['💬 你好。', '💬 今天读了什么书呢？'],
    extraDescription: null,
    loveLevel: 30,
    firstMeet: '2025-06-15',
    lastUpdate: '2026-03-20',
    assetsLastModified: 0,
    gsv: GsvSettings(),
    features: FeatureSettings(
      contextLength: 20,
      diary: false,
      diarySearchBoost: false,
      diarySearchThreshold: 0.5,
      coreMemory: false,
      worldBook: false,
      worldBookThreshold: 0.5,
      worldBookDepth: 3,
      emotionSystem: false,
      emotionPersist: false,
    ),
    emotionConfig: null,
  ),
];

/// Hardcoded chat messages per assistant index.
final Map<int, List<ChatMessage>> mockMessages = {
  0: [
    ChatMessage(sender: MessageSender.bot, content: '你好呀~ 今天想聊些什么呢？😊'),
    ChatMessage(sender: MessageSender.user, content: '你好！给我介绍一下你自己吧'),
    ChatMessage(
      sender: MessageSender.bot,
      content: '我是Chat酱！一个活泼开朗的AI助手～我的生日是1月1日，平时最喜欢和大家聊天啦！有什么想问的尽管说哦～ ✨',
    ),
    ChatMessage(sender: MessageSender.user, content: '你有什么特长吗？'),
    ChatMessage(sender: MessageSender.bot, content: '', isTyping: true),
  ],
  1: [
    ChatMessage(sender: MessageSender.bot, content: '你好。今天天气不错呢。'),
    ChatMessage(sender: MessageSender.user, content: '小雪你好，最近在看什么书？'),
    ChatMessage(
      sender: MessageSender.bot,
      content: '最近在读《百年孤独》，马尔克斯的文字总是让人沉醉其中。',
    ),
    ChatMessage(sender: MessageSender.user, content: '听起来很有趣'),
    ChatMessage(sender: MessageSender.bot, content: '', isTyping: true),
  ],
};

/// Hardcoded settings configuration for the SettingsModal.
const SettingsConfig mockSettings = SettingsConfig(
  llm: LlmConfig(
    baseUrl: 'https://api.example.com/v1',
    model: 'gpt-4o-mini',
    apiKey: 'sk-****',
  ),
  tts: TtsConfig(url: 'http://localhost:9880', refAudio: 'reference.wav'),
  agent: AgentStatus(isUp: true, name: 'Chat酱'),
);
