# MoeChat Agent Documentation

## Project Overview

MoeChat is a Flutter-based AI assistant chat application designed for Chinese users, featuring real-time voice interaction capabilities. It supports multi-platform deployment (Windows, macOS, Linux, Android, iOS, Web) with Windows as the primary target platform. The application features a modern, rounded UI aesthetic using a custom Chinese variable font.

### Key Features

- **AI Assistant Management**: Create, edit, delete, and switch between multiple AI character assistants with rich profile settings (personality, voice synthesis, memory features, emotion systems)
- **Real-time Voice Chat**: Stream audio to the server and receive TTS (Text-to-Speech) responses with low-latency PCM streaming
- **Text Chat**: Traditional text-based conversation with streaming responses
- **Resource Management**: Upload and download assistant resource packages (ZIP format) containing images, audio files, etc.
- **Rich Character Settings**: Configure personality, voice synthesis (GSV/GPT-SoVITS), memory features (diary, core memory, world book), and emotion systems

## Technology Stack

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| Framework | Flutter | 3.11.4+ | Cross-platform UI |
| State Management | GetX | ^4.7.2 | Reactive state, dependency injection, routing |
| Local Storage | get_storage | ^2.1.1 | Persistent settings and chat history |
| HTTP Client | Dio | ^5.4.0 | REST API communication |
| Audio Playback | flutter_soloud | ^4.0.0 | Real-time PCM streaming playback |
| Audio Recording | record | ^6.2.0 | Microphone capture with PCM streaming |
| Data Serialization | freezed + json_serializable | ^2.4.1 / ^6.7.1 | Type-safe JSON handling |
| File Operations | file_picker, archive, path_provider | Latest | File selection and ZIP handling |

### Configuration Files

- **`pubspec.yaml`** - Project metadata, dependencies, and Flutter-specific configuration
- **`analysis_options.yaml`** - Dart analyzer configuration (uses `package:flutter_lints/flutter.yaml`)
- **`build.yaml`** - Code generation configuration for freezed/json_serializable
- **`dart_test.yaml`** - Test tags configuration for organizing tests

## Project Structure

```
lib/
├── main.dart                      # Entry point, dependency injection setup
├── core/                          # Core utilities and constants
│   ├── constants/                 # Centralized constants
│   │   ├── audio_constants.dart   # Audio parameters (sample rate: 32kHz, etc.)
│   │   ├── buffer_constants.dart  # Socket buffer limits (1MB max)
│   │   ├── default_value_constants.dart  # Default settings values
│   │   ├── delimiter_constants.dart      # Socket frame delimiters
│   │   └── timeout_constants.dart        # Network timeouts
│   ├── errors/                    # Exception hierarchy
│   │   ├── app_exception.dart     # Base exception classes (NetworkException, ApiException, etc.)
│   │   └── error_handler.dart     # Error handling utilities
│   └── utils/                     # Utility classes
│       └── ring_buffer.dart       # Optimized ring buffer for socket data
├── dtos/                          # Data Transfer Objects (code-generated)
│   ├── assistant_dto.dart         # Freezed DTOs for API requests (CreateAssistantDto, UpdateAssistantDto, etc.)
│   ├── assistant_dto.freezed.dart # Generated (do not edit)
│   ├── assistant_dto.g.dart       # Generated JSON serialization
│   └── socket/
│       └── socket_frame.dart      # Type-safe socket frame types
├── models/                        # Domain models (plain Dart classes)
│   └── assistant.dart             # Assistant, ChatMessage, GsvSettings, FeatureSettings, etc.
├── repositories/                  # Repository pattern implementation
│   └── assistant_repository.dart  # Abstract AssistantRepository + AssistantRepositoryImpl
├── services/                      # Business logic services
│   ├── api/                       # HTTP API layer
│   │   ├── api_client_interface.dart  # API client contracts (AssistantApiClient, AssetsApiClient)
│   │   ├── assistant_parser.dart      # JSON parsing/serialization utilities
│   │   └── dio_api_client.dart        # Dio implementations
│   ├── api_service.dart           # Legacy API service (main implementation for most endpoints)
│   ├── audio_service.dart         # Audio playback (flutter_soloud) - 32kHz PCM streaming
│   ├── avatar_cache_service.dart  # Avatar image caching
│   ├── chat_storage_service.dart  # Chat history persistence via get_storage
│   ├── loading_service.dart       # Loading indicators and toast notifications
│   ├── recording_service.dart     # Audio recording (record package) - 16kHz PCM streaming
│   └── socket_service.dart        # TCP socket communication with frame protocol
├── controllers/                   # GetX controllers
│   ├── home_controller.dart       # Main app state and business logic (uses mixins)
│   ├── settings_controller.dart   # Settings and connection management
│   └── mixins/                    # Controller mixins for modularity
│       ├── asset_management_mixin.dart
│       ├── assistant_crud_mixin.dart
│       └── socket_frame_handler_mixin.dart
├── pages/                         # UI pages
│   ├── home_page.dart             # Main desktop application page with three-panel layout
│   └── mobile/                    # Mobile-specific pages
│       ├── mobile_home_page.dart
│       ├── assistants_page.dart
│       ├── assistant_detail_page.dart
│       ├── chat_page.dart
│       └── settings_page.dart
├── widgets/                       # UI components organized by feature
│   ├── chat/                      # Chat area components (chat_area, chat_bubble, chat_input_bar, etc.)
│   ├── common/                    # Shared widgets (form_widgets, loading_dialog, toast_widget, avatar_image)
│   ├── detail/                    # Assistant detail panel widgets (assets_section, gsv_settings, etc.)
│   ├── modals/                    # Dialogs and modals (edit_assistant_modal, settings_modal)
│   └── sidebar/                   # Sidebar components
└── theme/                         # App theming
    └── app_theme.dart             # Colors, typography, theme data (WenYuan Rounded SC VF font)

test/                              # Unit and widget tests
├── api_service_test.dart          # API service tests (requires local server)
├── assistant_parser_pbt_test.dart # Property-based tests for JSON parsing
├── home_controller_test.dart      # Controller business logic tests
└── socket_service_test.dart       # Socket frame parsing tests

assets/                            # Static assets
├── fonts/                         # WenYuan Rounded SC VF variable font
├── logo1.png
└── logo2.png
```

## Build and Run Commands

### Prerequisites

- Flutter SDK 3.11.4 or higher
- Dart SDK (bundled with Flutter)
- Windows: Visual Studio with C++ desktop development
- macOS: Xcode
- Linux: build-essential, libblkid-dev, liblzma-dev

### Setup

```bash
# Install dependencies
flutter pub get

# Generate code (freezed DTOs)
flutter pub run build_runner build

# Or watch for changes during development
flutter pub run build_runner watch
```

### Run

```bash
# Run in debug mode
flutter run

# Run on specific platform
flutter run -d windows
flutter run -d macos
flutter run -d linux
flutter run -d chrome

# Build for production
flutter build windows
flutter build macos
flutter build linux
flutter build apk
flutter build web
```

### Test

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/api_service_test.dart

# Run tests with specific tags
flutter test --tags "project-modular-refactor"
flutter test --tags "pbt-round-trip"

# Run with coverage
flutter test --coverage
```

## Architecture Patterns

### 1. Repository Pattern

The project uses the repository pattern to abstract data access:

```dart
// Abstract repository defines the contract
abstract class AssistantRepository {
  Future<List<Assistant>> getAssistants();
  Future<Assistant> createAssistant({...});
  // ...
}

// Implementation uses API client
class AssistantRepositoryImpl implements AssistantRepository {
  final AssistantApiClient _apiClient;
  AssistantRepositoryImpl(this._apiClient);
  // ...
}
```

### 2. Service Layer

Services contain business logic and are registered with GetX for dependency injection in `main.dart`:

```dart
// In main.dart
Get.put(ApiService());
Get.put(SocketService());
Get.put(AudioService());

// In controllers
final _apiService = Get.find<ApiService>();
```

### 3. Reactive State Management

GetX observables (`Rx`, `.obs`) are used for reactive UI updates:

```dart
// In controller
final assistants = <Assistant>[].obs;
final isLoading = false.obs;

// In widget
Obx(() => isLoading.value ? LoadingSpinner() : AssistantList(assistants));
```

### 4. Mixin-based Controller Organization

The `HomeController` uses mixins to organize functionality:

```dart
class HomeController extends GetxController
    with SocketFrameHandlerMixin, AssetManagementMixin, AssistantCrudMixin {
  // Shared state and composition
}
```

### 5. Socket Communication Protocol

Custom frame-based protocol over TCP:

```
<|tag|>payload<|end|>
```

Tags (defined in `lib/core/constants/delimiter_constants.dart`):
- `<|start|>` - User started speaking (interrupt signal)
- `<|me|>` - ASR result (user speech recognition)
- `<|text|>` - AI text response (streaming)
- `<|audio|>` - AI audio response (PCM data)
- `<|complete|>` - Response complete signal

## Code Generation

This project uses code generation for JSON serialization. After modifying DTO files (`lib/dtos/*.dart`), run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Generated files (do not edit manually):
- `*.freezed.dart` - Immutable data classes with copy methods
- `*.g.dart` - JSON serialization/deserialization

Configuration in `build.yaml`:
- `explicit_to_json: true` - Ensures nested objects serialize properly
- `generic_argument_factories: true` - Supports generic type serialization
- `create_factory: true` / `create_to_json: true` - Generates fromJson/toJson

## Code Style Guidelines

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: 
  - `camelCase` within classes
  - `SCREAMING_SNAKE_CASE` for top-level constants in `*_constants.dart` files
- **Private members**: `_leadingUnderscore`

### Code Style

- Use `const` constructors where possible
- Prefer single quotes for strings
- Use trailing commas for multi-line parameter lists
- Maximum line length: 80 characters (enforced by linter)
- Use `dart format` for formatting

### Documentation

- All public APIs should have dartdoc comments (`///`)
- Include code examples where helpful
- Comments in Chinese are acceptable and common in this codebase

### Error Handling

Use the custom exception hierarchy in `lib/core/errors/app_exception.dart`:

```dart
try {
  await apiService.fetchAssistants();
} on NetworkException catch (e) {
  // Handle network error
} on ApiException catch (e) {
  // Handle API error
} on ValidationException catch (e) {
  // Handle validation error
}
```

## Testing Strategy

### Test Organization

Tests are organized by functionality in the `test/` directory:

| Test File | Purpose | Requirements |
|-----------|---------|--------------|
| `api_service_test.dart` | API parsing and serialization | Local server at `http://127.0.0.1:8001/api` |
| `home_controller_test.dart` | Business logic | Mock dependencies |
| `socket_service_test.dart` | Socket frame parsing | None (unit tests) |
| `assistant_parser_pbt_test.dart` | Property-based testing | None |

### Test Tags

Tags are defined in `dart_test.yaml`:
- `project-modular-refactor` - Tests related to modular architecture
- `pbt-round-trip` - Property-based round-trip tests
- `pbt-default-values` - Default value property tests

### Property-Based Testing

The project uses `wheatley` for property-based testing (see `assistant_parser_pbt_test.dart`):

```dart
await forAll(featureSettingsGen())((settings) {
  final json = AssistantParser.featureSettingsToJson(settings);
  final parsed = AssistantParser.parseFeatureSettings(json);
  expect(parsed.contextLength, equals(settings.contextLength));
  // ...
});
```

## Audio System Architecture

### Audio Playback (flutter_soloud)

- **Format**: 32kHz, 16-bit, mono PCM
- **Buffering**: 50ms low-latency for real-time playback
- **Session Model**: Each conversation creates a new `AudioSource`
- **Interruption**: 200ms fade-out for natural interruption

Key class: `lib/services/audio_service.dart`

### Audio Recording (record package)

- **Format**: 16kHz, 16-bit, mono PCM (optimized for speech)
- **Streaming**: Real-time PCM frame broadcast via `StreamController`
- **Frame Size**: 60ms frames (1920 bytes @ 16kHz)

Key class: `lib/services/recording_service.dart`

## Configuration

### Server Connection

Users configure server addresses through the Settings modal (gear icon in sidebar):

- **HTTP API**: `http://<host>:<port>/api`
- **Socket**: `socket://<host>:<port>` or `tcp://<host>:<port>`

Example: `http://fgs6.bakamoe.com:9091/api` and `socket://fgs6.bakamoe.com:9092`

Settings are persisted via `get_storage` and automatically reconnected on app startup.

### Audio Settings

Audio parameters must match the server TTS configuration:

```dart
// lib/core/constants/audio_constants.dart
static const int sampleRate = 32000;  // 32kHz
static const int channels = 1;         // Mono
static const int bitsPerSample = 16;   // 16-bit PCM
```

## Theme and UI

The app uses a centralized design system in `lib/theme/app_theme.dart`:

- **Font**: WenYuan Rounded SC VF (variable font, weight 100-900)
- **Primary Color**: `#7C5CFC` (purple)
- **Background**: `#F0F2F5` (light gray)
- **Sidebar**: `#1E1E2E` (dark)
- **Animations**: 200ms standard, 300ms panel transitions

Key constants:
- `AppTheme.sidebarWidth` = 260.0
- `AppTheme.detailPanelWidth` = 320.0
- `AppTheme.panelDuration` = 300ms

## API Endpoints

The application communicates with a backend server via these HTTP endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/assistants` | GET | List all assistants |
| `/assistant/current` | GET | Get current assistant |
| `/assistant/switch` | POST | Switch to assistant by name |
| `/assistant/info/add` | POST | Create new assistant |
| `/assistant/info/update` | POST | Update assistant |
| `/assistant/info/delete` | POST | Delete assistant |
| `/assistant/info/avatar` | POST | Get assistant avatar (base64) |
| `/assistant/upload/avatar` | POST | Upload assistant avatar |
| `/assistant/assets/check` | POST | Check if resources need update |
| `/assistant/assets/download` | POST | Download resource ZIP |
| `/assistant/assets/upload` | POST | Upload resource ZIP |

## Security Considerations

1. **Path Traversal**: The asset download feature validates file paths to prevent path traversal attacks:
   ```dart
   if (normalizedName.contains('..') || normalizedName.startsWith('/')) {
     continue; // Skip unsafe paths
   }
   ```

2. **Input Validation**: All user inputs are validated before sending to the API.

3. **Local Storage**: Chat history and settings are stored locally via `get_storage`.

## Platform-Specific Notes

### Windows (Primary Target)

- Developed and optimized for Windows desktop
- Uses flutter_soloud with Windows-specific audio backends
- All features fully supported

### Mobile (Android/iOS)

- Supported via adaptive UI (`MobileHomePage` vs `HomePage`)
- Mobile-specific pages in `lib/pages/mobile/`
- Platform detection in `main.dart`:
  ```dart
  home: (Platform.isAndroid || Platform.isIOS)
      ? const MobileHomePage()
      : const HomePage(),
  ```

### Other Platforms

- **macOS/Linux**: Should work but may require platform-specific setup
- **Web**: Limited support due to socket and audio constraints

## Troubleshooting

### Build Issues

1. **Code generation out of date**: Run `flutter pub run build_runner build --delete-conflicting-outputs`
2. **Flutter version mismatch**: Ensure Flutter SDK >= 3.11.4
3. **Audio plugin issues**: Clean build with `flutter clean` and restart

### Runtime Issues

1. **Socket connection failed**: Check firewall settings and server address
2. **No audio output**: Verify audio format matches server (32kHz, 16bit, mono PCM)
3. **Recording not working**: Grant microphone permissions in system settings
4. **API connection errors**: Verify server is running and URL is correct

## Dependencies of Note

| Package | Purpose |
|---------|---------|
| `flutter_soloud` | High-performance audio playback with PCM streaming support |
| `record` | Cross-platform audio recording with stream support |
| `dio` | Powerful HTTP client with interceptors |
| `get` + `get_storage` | State management and persistent storage |
| `freezed` | Immutable data classes with code generation |
| `file_picker` | Native file selection dialogs |
| `archive` | ZIP compression/decompression |
| `flutter_list_view` | Enhanced ListView with scroll-to-index support |
| `wheatley` | Property-based testing framework |
| `mockito` | Mocking framework for tests |

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [freezed Documentation](https://pub.dev/packages/freezed)
- [flutter_soloud Documentation](https://pub.dev/packages/flutter_soloud)
- [Dio Documentation](https://pub.dev/packages/dio)
