import 'dart:typed_data';

import '../../../models/assistant.dart';

/// Interface for assistant-related API operations.
abstract class AssistantApiClient {
  /// Fetches all assistants from the server.
  Future<List<Assistant>> fetchAssistants();

  /// Fetches the currently selected assistant.
  Future<Assistant?> fetchCurrentAssistant();

  /// Switches to a different assistant by name.
  Future<Assistant> switchAssistant(String name);

  /// Adds a new assistant.
  Future<Assistant> addAssistant({
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

  /// Deletes an assistant by name.
  Future<void> deleteAssistant(String name);
}

/// Interface for assets-related API operations.
abstract class AssetsApiClient {
  /// Checks if assets need to be updated.
  Future<AssetsUpdateResult> checkAssetsUpdate(
    String name,
    double lastModified,
  );

  /// Downloads assets for an assistant.
  Future<Uint8List> downloadAssets(String name);

  /// Uploads assets for an assistant.
  Future<void> uploadAssets(String name, Uint8List zipData);
}
