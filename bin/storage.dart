import 'dart:convert';
import 'dart:io';

class AppStorage {
  static final AppStorage instance = AppStorage._internal();
  AppStorage._internal();

  final String _storagePath = 'data/storage.json';
  
  String geminiApiKey = '';
  String geminiModel = 'gemini-2.0-flash';
  
  final List<Map<String, dynamic>> savedVideos = [];
  final List<Map<String, dynamic>> searchHistory = [];

  Future<void> init() async {
    // Load environment variables if available
    final envFile = File('.env');
    if (await envFile.exists()) {
      final lines = await envFile.readAsLines();
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final parts = trimmed.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final val = parts.sublist(1).join('=').trim().replaceAll('"', '').replaceAll("'", "");
          if (key == 'GEMINI_API_KEY') geminiApiKey = val;
          if (key == 'GEMINI_MODEL') geminiModel = val;
        }
      }
    }

    // Also check OS environment
    if (Platform.environment.containsKey('GEMINI_API_KEY') && geminiApiKey.isEmpty) {
      geminiApiKey = Platform.environment['GEMINI_API_KEY']!;
    }
    if (Platform.environment.containsKey('GEMINI_MODEL') && geminiModel.isEmpty) {
      geminiModel = Platform.environment['GEMINI_MODEL']!;
    }

    // Load persisted state if exists
    final file = File(_storagePath);
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        if (data['geminiModel'] != null) geminiModel = data['geminiModel'] as String;
        if (data['geminiApiKey'] != null && (data['geminiApiKey'] as String).isNotEmpty) {
          geminiApiKey = data['geminiApiKey'] as String;
        }
        if (data['savedVideos'] is List) {
          savedVideos.clear();
          for (final item in data['savedVideos']) {
            savedVideos.add(Map<String, dynamic>.from(item as Map));
          }
        }
        if (data['searchHistory'] is List) {
          searchHistory.clear();
          for (final item in data['searchHistory']) {
            searchHistory.add(Map<String, dynamic>.from(item as Map));
          }
        }
      } catch (e) {
        print('Error loading storage: $e');
      }
    }
  }

  Future<void> persist() async {
    try {
      final dir = Directory('data');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File(_storagePath);
      final data = {
        'geminiModel': geminiModel,
        'geminiApiKey': geminiApiKey,
        'savedVideos': savedVideos,
        'searchHistory': searchHistory,
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print('Error saving storage: $e');
    }
  }

  void addSavedVideo(Map<String, dynamic> video) {
    final id = video['id']?.toString() ?? '';
    final existingIndex = savedVideos.indexWhere((v) => v['id']?.toString() == id);
    if (existingIndex >= 0) {
      savedVideos[existingIndex] = video;
    } else {
      savedVideos.insert(0, video);
    }
    persist();
  }

  bool removeSavedVideo(String id) {
    final before = savedVideos.length;
    savedVideos.removeWhere((v) => v['id']?.toString() == id);
    final changed = savedVideos.length != before;
    if (changed) persist();
    return changed;
  }

  bool isVideoSaved(String id) {
    return savedVideos.any((v) => v['id']?.toString() == id);
  }

  void addSearchHistory(Map<String, dynamic> historyItem) {
    searchHistory.insert(0, historyItem);
    if (searchHistory.length > 50) {
      searchHistory.removeLast();
    }
    persist();
  }

  void clearHistory() {
    searchHistory.clear();
    persist();
  }

  void updateSettings({String? apiKey, String? model}) {
    if (apiKey != null) geminiApiKey = apiKey.trim();
    if (model != null && model.trim().isNotEmpty) geminiModel = model.trim();
    persist();
  }
}
