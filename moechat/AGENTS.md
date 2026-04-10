# MoeChat Agent Documentation

## Project Overview

MoeChat is a Flutter-based AI assistant chat application with real-time voice interaction capabilities. It supports multi-platform deployment (Windows, macOS, Linux, Android, iOS, Web) with Windows as the primary target platform. The application is designed for Chinese users and features a modern, rounded UI aesthetic.

### Key Features

- **AI Assistant Management**: Create, edit, delete, and switch between multiple AI character assistants with rich profile settings
- **Real-time Voice Chat**: Stream audio to the server and receive TTS (Text-to-Speech) responses with low-latency PCM streaming
- **Text Chat**: Traditional text-based conversation with streaming responses
- **Resource Management**: Upload and download assistant resource packages (ZIP format)
- **Rich Character Settings**: Configure personality, voice synthesis (GSV/GPT-SoVITS), memory features, and emotion systems

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Framework | Flutter 3.11.4+ | Cross-platform UI |
| State Management | GetX | Reactive state, dependency injection, routing |
| Local Storage | get_storage | Persistent settings and chat history |
| HTTP Client | Dio | REST API communication |
| Audio Playback | flutter_soloud | Real-time PCM streaming playback |
| Audio Recording | record | Microphone capture with PCM streaming |
| Data Serialization | freezed + json_serializable | Type-safe JSON handling |
| File Operations | file_picker, archive, path_provider | File selection and ZIP handling |

### Key Dependencies

```yaml
# Core
dart_sdk: ^3.11.4
get: ^4.7.2
get_storage: ^2.1.1
dio: ^5.4.0

# Audio
flutter_soloud: ^4.0.0
record: ^6.2.0

# Serialization
freezed_annotation: ^2.4.1
json_annotation: ^4.8.1

# File/Archive
file_picker: ^8.1.0
archive: ^3.6.1
path_provider: ^2.1.0

# Dev Dependencies
build_runner: ^2.4.8
freezed: ^2.4.7
json_serializable: ^6.7.1
flutter_lints: ^6.0.0
mockito: ^5.4.4
wheatley: ^0.1.1
```

## Project Structure

```
lib/
├── main.dart                      # Entry point, dependency injection setup
├── core/                          # Core utilities and constants
│   ├── constants/                 # Centralized constants
│   │   ├── audio_constants.dart   # Audio parameters (sample rate, etc.)
│   │   ├── buffer_constants.dart  # Socket buffer limits
│   │   ├── default_value_constants.dart  # Default settings values
│   │   ├── delimiter_constants.dart      # Socket frame delimiters
│   │   └── timeout_constants.dart        # Network timeouts
│   ├── errors/                    # Exception hierarchy
│   │   ├── app_exception.dart     # Base exception classes
│   │   └── error_handler.dart     # Error handling utilities
│   └── utils/                     # Utility classes
│       └── ring_buffer.dart       # Optimized ring buffer for socket data
├── dtos/                          # Data Transfer Objects (code-generated)
│   ├── assistant_dto.dart         # Freezed DTOs for API requests
│   ├── assistant_dto.freezed.dart # Generated (do not edit)
│   ├── assistant_dto.g.dart       # Generated JSON serialization
│   └── socket/
│       └── socket_frame.dart      # Type-safe socket frame types
├── models/                        # Domain models
│   └── assistant.dart             # Assistant, ChatMessage, settings classes
├── repositories/                  # Repository pattern implementation
│   └── assistant_repository.dart  # Abstract and implementation
├── services/                      # Business logic services
│   ├── api/                       # HTTP API layer
│   │   ├── api_client_interface.dart  # API client contracts
│   │   ├── assistant_parser.dart      # JSON parsing utilities
│   │   └── dio_api_client.dart        # Dio implementation
│   ├── api_service.dart           # Legacy API service (main implementation)
│   ├── audio_service.dart         # Audio playback (flutter_soloud)
│   ├── chat_storage_service.dart  # Chat history persistence
│   ├── loading_service.dart       # Loading indicators and toasts
│   ├── recording_service.dart     # Audio recording (record package)
│   └── socket_service.dart        # TCP socket communication
├── controllers/                   # GetX controllers
│   ├── home_controller.dart       # Main app state and business logic
│   ├── settings_controller.dart   # Settings and connection management
│   └── mixins/                    # Controller mixins for modularity
│       ├── asset_management_mixin.dart
│       ├── assistant_crud_mixin.dart
│       └── socket_frame_handler_mixin.dart
├── pages/                         # UI pages
│   └── home_page.dart             # Main application page
├── widgets/                       # UI components
│   ├── chat/                      # Chat area components
│   ├── common/                    # Shared widgets
│   ├── detail/                    # Assistant detail panel widgets
│   ├── modals/                    # Dialogs and modals
│   └── sidebar/                   # Sidebar components
└── theme/                         # App theming
    └── app_theme.dart             # Colors, typography, theme data

test/                              # Unit and widget tests
├── api_service_test.dart
├── assistant_parser_pbt_test.dart
├── home_controller_test.dart
└── socket_service_test.dart

assets/                            # Static assets
├── fonts/                         # WenYuan Rounded SC VF font
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

# Run with coverage
flutter test --coverage
```

## Code Generation

This project uses code generation for JSON serialization. After modifying DTO files (`lib/dtos/*.dart`), run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Generated files (do not edit manually):
- `*.freezed.dart` - Immutable data classes with copy methods
- `*.g.dart` - JSON serialization/deserialization

Configuration is in `build.yaml`:
- `explicit_to_json: true` - Ensures nested objects serialize properly
- `generic_argument_factories: true` - Supports generic type serialization

## Architecture Patterns

### 1. Repository Pattern

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

Services contain business logic and are registered with GetX for dependency injection:

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

Tags (defined in `delimiter_constants.dart`):
- `<|start|>` - User started speaking (interrupt signal)
- `<|me|>` - ASR result (user speech recognition)
- `<|text|>` - AI text response (streaming)
- `<|audio|>` - AI audio response (PCM data)
- `<|complete|>` - Response complete signal

## Coding Conventions

### Naming

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `camelCase` (within classes), `SCREAMING_SNAKE_CASE` (top-level)
- **Private members**: `_leadingUnderscore`

### Code Style

- Use `const` constructors where possible
- Prefer single quotes for strings
- Use trailing commas for multi-line parameter lists
- Maximum line length: 80 characters
- Use `dart format` for formatting

### Documentation

- All public APIs must have dartdoc comments
- Use `///` for documentation comments
- Include code examples where helpful

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

## Testing Strategy

### Unit Tests

Focus areas:
- `test/api_service_test.dart` - API parsing and serialization
- `test/home_controller_test.dart` - Business logic
- `test/socket_service_test.dart` - Socket frame parsing
- `test/assistant_parser_pbt_test.dart` - Property-based testing

### Running Tests

```bash
# Run all tests
flutter test

# Run with verbose output
flutter test -v

# Run specific test
flutter test --name "fetchAssistants should return list"
```

### Test Configuration

Tests assume a local server running at `http://127.0.0.1:8001/api`. Modify the URL in test files to match your environment.

Test tags in `dart_test.yaml`:
- `project-modular-refactor` - Tests related to modular architecture
- `pbt-round-trip` - Property-based round-trip tests
- `pbt-default-values` - Default value property tests

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

### Other Platforms

- **macOS/Linux**: Should work but may require platform-specific setup
- **Android/iOS**: Supported but not primary focus
- **Web**: Limited support due to socket and audio constraints

## Troubleshooting

### Build Issues

1. **Code generation out of date**: Run `flutter pub run build_runner build`
2. **Flutter version mismatch**: Ensure Flutter SDK >= 3.11.4
3. **Audio plugin issues**: Clean build and restart

### Runtime Issues

1. **Socket connection failed**: Check firewall settings and server address
2. **No audio output**: Verify audio format matches server (32kHz, 16bit, mono PCM)
3. **Recording not working**: Grant microphone permissions

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
| `/assistant/assets/check` | POST | Check if resources need update |
| `/assistant/assets/download` | POST | Download resource ZIP |
| `/assistant/assets/upload` | POST | Upload resource ZIP |

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [freezed Documentation](https://pub.dev/packages/freezed)
- [flutter_soloud Documentation](https://pub.dev/packages/flutter_soloud)
