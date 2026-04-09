# MoeChat Agent Documentation

## Project Overview

MoeChat is a Flutter-based AI assistant chat application with real-time voice interaction capabilities. It supports multi-platform deployment (Windows, macOS, Linux, Android, iOS, Web) and features a modern UI designed for Chinese users.

### Key Features

- **AI Assistant Management**: Create, edit, delete, and switch between multiple AI character assistants
- **Real-time Voice Chat**: Stream audio to the server and receive TTS (Text-to-Speech) responses
- **Text Chat**: Traditional text-based conversation with streaming responses
- **Resource Management**: Upload and download assistant resource packages (ZIP)
- **Rich Character Settings**: Configure personality, voice synthesis (GSV/GPT-SoVITS), memory features, and emotion systems

## Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Framework | Flutter 3.11+ | Cross-platform UI |
| State Management | GetX | Reactive state, dependency injection, routing |
| HTTP Client | Dio | REST API communication |
| Audio Playback | flutter_soloud | Real-time PCM streaming |
| Audio Recording | record | Microphone capture with PCM streaming |
| Data Serialization | freezed + json_serializable | Type-safe JSON handling |
| Local Storage | get_storage | Persistent settings storage |
| File Operations | file_picker, archive, path_provider | File selection and ZIP handling |

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
│   ├── assistant_dto.freezed.dart # Generated (run build_runner to regenerate)
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
│   │   └── dio_api_client.dart    # Dio implementation
│   ├── api_service.dart           # Legacy API service (main implementation)
│   ├── audio_service.dart         # Audio playback (flutter_soloud)
│   ├── loading_service.dart       # Loading indicators and toasts
│   ├── recording_service.dart     # Audio recording (record package)
│   └── socket_service.dart        # TCP socket communication
├── controllers/                   # GetX controllers
│   ├── home_controller.dart       # Main app state and business logic
│   └── settings_controller.dart   # Settings and connection management
├── pages/                         # UI pages
│   └── home_page.dart             # Main application page
├── widgets/                       # UI components
│   ├── chat/                      # Chat area components
│   ├── detail/                    # Assistant detail panel widgets
│   ├── modals/                    # Dialogs and modals
│   └── sidebar/                   # Sidebar components
└── theme/                         # App theming
    └── app_theme.dart             # Colors, typography, theme data

test/                              # Unit and widget tests
├── api_service_test.dart
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

### 4. Socket Communication Protocol

Custom frame-based protocol over TCP:

```
<|tag|>payload<|end|>
```

Tags:
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

Use the custom exception hierarchy:

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

### Unit Tests

Focus areas:
- `test/api_service_test.dart` - API parsing and serialization
- `test/home_controller_test.dart` - Business logic
- `test/socket_service_test.dart` - Socket frame parsing

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

## Configuration

### Server Connection

Users configure server addresses through the Settings modal (gear icon in sidebar):

- **HTTP API**: `http://<host>:<port>/api`
- **Socket**: `socket://<host>:<port>`

Example: `http://fgs6.bakamoe.com:9091/api` and `socket://fgs6.bakamoe.com:9092`

### Audio Settings

Audio parameters must match the server TTS configuration:

```dart
// lib/core/constants/audio_constants.dart
static const int sampleRate = 32000;  // 32kHz
static const int channels = 1;         // Mono
static const int bitsPerSample = 16;   // 16-bit PCM
```

## Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| get | ^4.7.2 | State management |
| get_storage | ^2.1.1 | Local storage |
| dio | ^5.4.0 | HTTP client |
| flutter_soloud | ^4.0.0 | Audio playback |
| record | ^6.2.0 | Audio recording |
| file_picker | ^8.1.0 | File selection |
| archive | ^3.6.1 | ZIP extraction |
| freezed_annotation | ^2.4.1 | Immutable classes |
| json_annotation | ^4.8.1 | JSON serialization |

### Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| build_runner | ^2.4.8 | Code generation runner |
| freezed | ^2.4.7 | Immutable class generation |
| json_serializable | ^6.7.1 | JSON serialization generation |
| flutter_lints | ^6.0.0 | Lint rules |
| mockito | ^5.4.4 | Testing mocks |

## Security Considerations

1. **Path Traversal**: The asset download feature validates file paths to prevent path traversal attacks:
   ```dart
   if (normalizedName.contains('..') || normalizedName.startsWith('/')) {
     continue; // Skip unsafe paths
   }
   ```

2. **Input Validation**: All user inputs are validated before sending to the API.

3. **Local Storage**: Sensitive data (like API keys) should be stored securely if added in the future.

## Platform-Specific Notes

### Windows (Primary Target)

- Developed and optimized for Windows desktop
- Uses flutter_soloud with Windows-specific audio backends
- All features fully supported

### Other Platforms

- macOS/Linux: Should work but may require platform-specific setup
- Android/iOS: Supported but not primary focus
- Web: Limited support due to socket and audio constraints

## Troubleshooting

### Build Issues

1. **Code generation out of date**: Run `flutter pub run build_runner build`
2. **Flutter version mismatch**: Ensure Flutter SDK >= 3.11.4
3. **Audio plugin issues**: Clean build and restart

### Runtime Issues

1. **Socket connection failed**: Check firewall settings and server address
2. **No audio output**: Verify audio format matches server (32kHz, 16bit, mono PCM)
3. **Recording not working**: Grant microphone permissions

## Additional Resources

- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed architecture documentation
- [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - Implementation status and feature summary
- [Flutter Documentation](https://docs.flutter.dev/)
- [GetX Documentation](https://github.com/jonataslaw/getx)
