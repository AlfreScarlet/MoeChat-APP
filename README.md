# MoeChat - AI 角色扮演聊天客户端

<p align="center">
  <strong>跨平台 AI 角色扮演聊天应用</strong>
</p>

<p align="center">
  <a href="#功能特性">功能特性</a> •
  <a href="#技术栈">技术栈</a> •
  <a href="#快速开始">快速开始</a> •
  <a href="#使用指南">使用指南</a> •
  <a href="#项目结构">项目结构</a>
</p>

---

## 功能特性

### 核心功能
- **多助手管理** - 添加、编辑、删除 AI 助手角色，每个助手拥有独立的性格设定
- **实时聊天** - 支持文本消息收发，流式消息显示（打字机效果）
- **语音通话** - 实时语音输入/输出，支持 ASR 语音识别和 TTS 语音合成
- **资源管理** - 检查助手资源更新，支持下载/上传资源包
- **跨平台支持** - 支持 Windows、Linux、macOS、Android、iOS 和 Web

### 助手角色设定
- 自定义头像、名称、描述
- 生日、身高、体重等角色属性
- 性格标签和详细描述
- GSV (GPT-SoVITS) 语音合成配置
- 功能开关（日记、核心记忆、世界书、情绪系统）

### 界面特性
- 现代化的暗色主题 UI 设计
- 三栏式布局：侧边栏、聊天区、详情面板
- 流式消息显示，支持 Markdown 格式
- 丰富的动画效果

---

## 技术栈

| 技术 | 用途 |
|------|------|
| [Flutter](https://flutter.dev/) | 跨平台 UI 框架 |
| [GetX](https://pub.dev/packages/get) | 状态管理与依赖注入 |
| [GetStorage](https://pub.dev/packages/get_storage) | 本地数据持久化 |
| [Dio](https://pub.dev/packages/dio) | HTTP 客户端 |
| [flutter_soloud](https://pub.dev/packages/flutter_soloud) | 音频播放（支持流式） |
| [record](https://pub.dev/packages/record) | 音频录制（支持流式 PCM） |
| [path_provider](https://pub.dev/packages/path_provider) | 系统目录访问 |
| [file_picker](https://pub.dev/packages/file_picker) | 文件选择 |
| [archive](https://pub.dev/packages/archive) | ZIP 解压 |

---

## 快速开始

### 环境要求

- Flutter SDK ^3.11.4
- Dart SDK ^3.0.0
- Windows/Linux/macOS 开发环境

### 安装步骤

1. **克隆仓库**
   ```bash
   git clone https://github.com/yourusername/MoeChat-APP.git
   cd MoeChat-APP/moechat
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行应用**
   
   **桌面端 (Windows/Linux/macOS):**
   ```bash
   flutter run -d windows
   # 或
   flutter run -d linux
   # 或
   flutter run -d macos
   ```

   **移动端 (Android/iOS):**
   ```bash
   flutter run
   ```

4. **构建发布版本**
   
   **Windows:**
   ```bash
   flutter build windows --release
   ```

   **Linux:**
   ```bash
   flutter build linux --release
   ```

   **macOS:**
   ```bash
   flutter build macos --release
   ```

---

## 使用指南

### 首次配置

1. 点击侧边栏底部的 **设置** 按钮
2. 配置 HTTP API 地址（例如：`http://your-server:9091/api`）
3. 配置 Socket 地址（例如：`socket://your-server:9092`）
4. 点击保存，连接成功后自动加载助手列表

### 助手管理

| 操作 | 方法 |
|------|------|
| 添加助手 | 点击侧边栏"+ 添加助手"按钮 |
| 编辑助手 | 在详情面板点击"编辑助手"按钮 |
| 删除助手 | 在详情面板点击"删除助手"按钮（有确认对话框） |
| 切换助手 | 在侧边栏点击助手卡片 |

### 聊天功能

- **发送消息** - 在输入框输入文字，按 Enter 发送
- **语音通话** - 点击输入栏的电话图标开启/关闭语音模式
  - 开启后会自动采集麦克风音频并发送
  - 服务器 ASR 识别后会显示在消息列表
  - 支持实时语音打断

### 资源管理

| 操作 | 方法 |
|------|------|
| 检查更新 | 点击详情面板资源区的刷新按钮 |
| 下载资源 | 点击下载按钮，自动下载并解压资源包 |
| 上传资源 | 点击上传按钮，选择 ZIP 格式的资源文件 |

---

## 项目结构

```
moechat/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── pages/                    # 页面
│   │   └── home_page.dart        # 主页面
│   ├── controllers/              # 业务逻辑控制器
│   │   ├── home_controller.dart  # 主控制器
│   │   └── settings_controller.dart
│   ├── services/                 # 服务层
│   │   ├── api_service.dart      # HTTP API
│   │   ├── socket_service.dart   # TCP Socket
│   │   ├── audio_service.dart    # 音频播放
│   │   ├── recording_service.dart # 录音服务
│   │   └── loading_service.dart  # 加载状态
│   ├── models/                   # 数据模型
│   │   └── assistant.dart        # 助手/消息模型
│   ├── widgets/                  # UI 组件
│   │   ├── sidebar/              # 侧边栏
│   │   ├── chat/                 # 聊天区组件
│   │   ├── detail/               # 详情面板组件
│   │   └── modals/               # 弹窗组件
│   ├── theme/                    # 主题配置
│   │   └── app_theme.dart
│   └── data/                     # 模拟数据
├── assets/                       # 静态资源
│   ├── fonts/                    # 字体文件
│   └── images/                   # 图片资源
├── test/                         # 测试文件
├── android/                      # Android 配置
├── ios/                          # iOS 配置
├── linux/                        # Linux 配置
├── macos/                        # macOS 配置
├── windows/                      # Windows 配置
└── web/                          # Web 配置
```

---

## 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                           UI Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   Sidebar    │  │   ChatArea   │  │  DetailPanel     │  │
│  │  (+ Add)     │  │  (Voice Btn) │  │(Edit/Del/Assets) │  │
│  └──────┬───────┘  └──────┬───────┘  └────────┬─────────┘  │
└─────────┼─────────────────┼───────────────────┼───────────┘
          │                 │                   │
          ▼                 ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│                      Controller Layer                        │
│                      HomeController                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │loadAssistants│  │ add/edit/del │  │ assets mgmt      │  │
│  │selectAssistant│ │   assistant  │  │ voice mode       │  │
│  └──────┬───────┘  └──────┬───────┘  └────────┬─────────┘  │
└─────────┼─────────────────┼───────────────────┼───────────┘
          │                 │                   │
          ▼                 ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│                       Service Layer                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                    ApiService                         │  │
│  │  GET/assistants  │  POST/add  │  POST/update          │  │
│  │  POST/switch     │  POST/delete                        │  │
│  │  POST/assets/check │ POST/download │ POST/upload      │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                   SocketService                       │  │
│  │  TCP Connection  │  Text Frames  │  Audio Stream      │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## API 接口

### HTTP API

| 方法 | 端点 | 描述 |
|------|------|------|
| GET | `/assistants` | 获取所有助手列表 |
| GET | `/assistant` | 获取当前助手 |
| POST | `/assistant` | 添加新助手 |
| POST | `/assistant/switch` | 切换助手 |
| POST | `/assistant/update` | 更新助手 |
| POST | `/assistant/delete` | 删除助手 |
| POST | `/assistant/assets/check` | 检查资源更新 |
| POST | `/assistant/assets/download` | 下载资源包 |
| POST | `/assistant/assets/upload` | 上传资源包 |

### Socket 协议

- **协议**: TCP 长连接
- **帧格式**: 自定义帧协议
- **消息类型**:
  - 文本消息 (type: 0)
  - ASR 识别结果 (type: 2)
  - 音频数据 (type: 3)

---

## 测试

运行测试套件：

```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/api_service_test.dart
flutter test test/socket_service_test.dart
flutter test test/home_controller_test.dart
```

---

## 开发计划

- [x] 基础 UI 框架搭建
- [x] HTTP API 集成
- [x] Socket 实时通信
- [x] 音频播放与录制
- [x] 助手 CRUD 功能
- [x] 资源管理功能
- [x] 语音通话模式
- [ ] 头像上传功能
- [ ] 多语言支持
- [ ] 更多主题选项

---

## 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

---

## 许可证

本项目采用 [GNU General Public License v3.0](LICENSE) 开源许可。

---

## 致谢

- [Flutter](https://flutter.dev/) - 优秀的跨平台开发框架
- [GetX](https://github.com/jonataslaw/getx) - 强大的状态管理方案
- [flutter_soloud](https://github.com/alnitak/flutter_soloud) - 高性能音频播放库
