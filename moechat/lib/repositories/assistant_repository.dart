import '../../models/assistant.dart';
import '../services/api/api_client_interface.dart';

/// Repository for assistant-related data operations.
///
/// Acts as an intermediary between the API clients and the controllers,
/// handling data transformation and caching if needed.
abstract class AssistantRepository {
  /// Gets all assistants.
  Future<List<Assistant>> getAssistants();

  /// Gets the currently selected assistant.
  Future<Assistant?> getCurrentAssistant();

  /// Switches to a different assistant.
  Future<Assistant> switchAssistant(String name);

  /// Creates a new assistant.
  Future<Assistant> createAssistant({
    required String name,
    required String avatar,
    required String birthday,
    required String height,
    required String weight,
    required String personality,
    required String description,
    String? user,
    String? mask,
    List<String>? messageExamples,
    String? extraDescription,
    String? customPrompt,
    List<String>? startWith,
    FeatureSettings? settings,
    GsvSettings? gsvSetting,
  });

  /// Updates an existing assistant.
  Future<Assistant> updateAssistant({
    required String name,
    String? avatar,
    String? birthday,
    String? height,
    String? weight,
    String? personality,
    String? description,
    String? user,
    String? mask,
    List<String>? messageExamples,
    String? extraDescription,
    String? customPrompt,
    List<String>? startWith,
    FeatureSettings? settings,
    GsvSettings? gsvSetting,
  });

  /// Deletes an assistant.
  Future<void> deleteAssistant(String name);
}

/// Implementation of [AssistantRepository].
class AssistantRepositoryImpl implements AssistantRepository {
  final AssistantApiClient _apiClient;

  AssistantRepositoryImpl(this._apiClient);

  @override
  Future<List<Assistant>> getAssistants() => _apiClient.fetchAssistants();

  @override
  Future<Assistant?> getCurrentAssistant() => _apiClient.fetchCurrentAssistant();

  @override
  Future<Assistant> switchAssistant(String name) =>
      _apiClient.switchAssistant(name);

  @override
  Future<Assistant> createAssistant({
    required String name,
    required String avatar,
    required String birthday,
    required String height,
    required String weight,
    required String personality,
    required String description,
    String? user,
    String? mask,
    List<String>? messageExamples,
    String? extraDescription,
    String? customPrompt,
    List<String>? startWith,
    FeatureSettings? settings,
    GsvSettings? gsvSetting,
  }) =>
      _apiClient.addAssistant(
        name: name,
        avatar: avatar,
        birthday: birthday,
        height: height,
        weight: weight,
        personality: personality,
        description: description,
        user: user,
        mask: mask,
        messageExamples: messageExamples,
        extraDescription: extraDescription,
        customPrompt: customPrompt,
        startWith: startWith,
        settings: settings,
        gsvSetting: gsvSetting,
      );

  @override
  Future<Assistant> updateAssistant({
    required String name,
    String? avatar,
    String? birthday,
    String? height,
    String? weight,
    String? personality,
    String? description,
    String? user,
    String? mask,
    List<String>? messageExamples,
    String? extraDescription,
    String? customPrompt,
    List<String>? startWith,
    FeatureSettings? settings,
    GsvSettings? gsvSetting,
  }) =>
      _apiClient.updateAssistant(
        name: name,
        avatar: avatar,
        birthday: birthday,
        height: height,
        weight: weight,
        personality: personality,
        description: description,
        user: user,
        mask: mask,
        messageExamples: messageExamples,
        extraDescription: extraDescription,
        customPrompt: customPrompt,
        startWith: startWith,
        settings: settings,
        gsvSetting: gsvSetting,
      );

  @override
  Future<void> deleteAssistant(String name) => _apiClient.deleteAssistant(name);
}
