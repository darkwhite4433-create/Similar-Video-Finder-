import 'dart:convert';
import 'dart:io';
import 'bin/gemini_service.dart';
import 'bin/search_engine.dart';
import 'bin/storage.dart';

void main() async {
  await AppStorage.instance.init();

  int port = 8080;
  if (Platform.environment.containsKey('PORT')) {
    port = int.tryParse(Platform.environment['PORT']!) ?? 8080;
  }

  HttpServer server;
  try {
    server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  } catch (e) {
    // If port 8080 is in use, fallback to 8085 or loopback
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8085);
    port = 8085;
  }

  print('========================================================');
  print('🚀 VideoFind AI Server is running!');
  print('🔗 Local URL: http://localhost:${server.port}');
  print('🤖 Gemini Model: ${AppStorage.instance.geminiModel}');
  print('🔑 Gemini API Key: ${AppStorage.instance.geminiApiKey.isNotEmpty ? "Configured (Live)" : "Not configured (Local Simulation Engine Active)"}');
  print('========================================================');

  await for (HttpRequest request in server) {
    try {
      await handleRequest(request);
    } catch (e, stack) {
      print('Unhandled server error: $e\n$stack');
      try {
        request.response
          ..statusCode = HttpStatus.internalServerError
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'error': 'Internal server error: $e'}));
        await request.response.close();
      } catch (_) {}
    }
  }
}

Future<void> handleRequest(HttpRequest request) async {
  // Add CORS headers for smooth local development
  request.response.headers.add('Access-Control-Allow-Origin', '*');
  request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  request.response.headers.add('Access-Control-Allow-Headers', 'Origin, Content-Type, Authorization, Accept');

  if (request.method == 'OPTIONS') {
    request.response.statusCode = HttpStatus.ok;
    await request.response.close();
    return;
  }

  final path = request.uri.path;

  // API Endpoints
  if (path.startsWith('/api/')) {
    await handleApiRequest(request);
    return;
  }

  // Static File Serving
  await handleStaticFile(request);
}

Future<void> handleApiRequest(HttpRequest request) async {
  final path = request.uri.path;
  final method = request.method;

  if (path == '/api/presets' && method == 'GET') {
    final presets = SearchEngine.instance.getPresets().map((p) => p.toJson()).toList();
    await sendJson(request, {'presets': presets});
    return;
  }

  if (path == '/api/analyze-video' && method == 'POST') {
    final body = await parseJsonBody(request);
    final presetId = body['presetId'] as String?;
    final customTitle = body['customTitle'] as String?;
    final customDescription = body['customDescription'] as String?;
    final userKeywords = (body['userKeywords'] as List<dynamic>?)?.map((e) => e.toString()).toList();

    final result = SearchEngine.instance.analyzeVideo(
      presetId: presetId,
      customTitle: customTitle,
      customDescription: customDescription,
      userKeywords: userKeywords,
    );
    await sendJson(request, result);
    return;
  }

  if (path == '/api/search' && method == 'POST') {
    final body = await parseJsonBody(request);
    final ref = body['referenceContext'] as Map<String, dynamic>? ?? {};
    final keywords = (body['keywords'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    final platforms = (body['platforms'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    final query = body['query'] as String?;
    final sortBy = body['sortBy'] as String?;

    final searchResult = SearchEngine.instance.search(
      referenceContext: ref,
      keywords: keywords,
      platforms: platforms,
      query: query,
      sortBy: sortBy,
    );

    // Save to search history
    final historyItem = {
      'id': 'hist-${DateTime.now().millisecondsSinceEpoch}',
      'timestamp': DateTime.now().toIso8601String(),
      'referenceTitle': ref['title'] ?? 'Custom Reference',
      'category': ref['category'] ?? 'General',
      'keywords': keywords,
      'platforms': platforms,
      'resultCount': searchResult['total'],
      'topScore': (searchResult['results'] as List).isNotEmpty ? searchResult['results'][0]['matchScore'] : 0,
      'query': query ?? '',
    };
    AppStorage.instance.addSearchHistory(historyItem);

    await sendJson(request, searchResult);
    return;
  }

  // Saved Videos
  if (path == '/api/saved' && method == 'GET') {
    await sendJson(request, {'savedVideos': AppStorage.instance.savedVideos});
    return;
  }

  if (path == '/api/saved' && method == 'POST') {
    final body = await parseJsonBody(request);
    final video = body['video'] as Map<String, dynamic>?;
    if (video == null) {
      await sendError(request, 'Missing video payload', HttpStatus.badRequest);
      return;
    }
    video['savedAt'] = DateTime.now().toIso8601String();
    AppStorage.instance.addSavedVideo(video);
    await sendJson(request, {'success': true, 'savedVideos': AppStorage.instance.savedVideos});
    return;
  }

  if (path.startsWith('/api/saved/') && method == 'DELETE') {
    final id = Uri.decodeComponent(path.substring('/api/saved/'.length));
    final removed = AppStorage.instance.removeSavedVideo(id);
    await sendJson(request, {'success': removed, 'savedVideos': AppStorage.instance.savedVideos});
    return;
  }

  // Search History
  if (path == '/api/history' && method == 'GET') {
    await sendJson(request, {'history': AppStorage.instance.searchHistory});
    return;
  }

  if (path == '/api/history' && method == 'DELETE') {
    AppStorage.instance.clearHistory();
    await sendJson(request, {'success': true, 'history': []});
    return;
  }

  // Settings
  if (path == '/api/settings' && method == 'GET') {
    await sendJson(request, {
      'geminiModel': AppStorage.instance.geminiModel,
      'hasApiKey': AppStorage.instance.geminiApiKey.isNotEmpty,
      'maskedApiKey': AppStorage.instance.geminiApiKey.isNotEmpty
          ? '••••••••••••••••' + (AppStorage.instance.geminiApiKey.length > 4 ? AppStorage.instance.geminiApiKey.substring(AppStorage.instance.geminiApiKey.length - 4) : '')
          : '',
      'availableModels': [
        {'id': 'gemini-2.0-flash', 'name': 'Gemini 2.0 Flash (Recommended - Fastest & Multi-modal)'},
        {'id': 'gemini-1.5-flash', 'name': 'Gemini 1.5 Flash (Lightweight & Rapid)'},
        {'id': 'gemini-1.5-pro', 'name': 'Gemini 1.5 Pro (Deep Reasoning & Long Context)'},
      ],
    });
    return;
  }

  if (path == '/api/settings' && method == 'POST') {
    final body = await parseJsonBody(request);
    final apiKey = body['geminiApiKey'] as String?;
    final model = body['geminiModel'] as String?;
    AppStorage.instance.updateSettings(apiKey: apiKey, model: model);
    await sendJson(request, {
      'success': true,
      'geminiModel': AppStorage.instance.geminiModel,
      'hasApiKey': AppStorage.instance.geminiApiKey.isNotEmpty,
    });
    return;
  }

  // -----------------------------------------------------------------
  // GEMINI ASSISTANT SERVICE ENDPOINTS
  // -----------------------------------------------------------------
  if (path == '/api/gemini/chat' && method == 'POST') {
    final body = await parseJsonBody(request);
    final message = body['message']?.toString() ?? '';
    final sessionId = body['sessionId']?.toString() ?? 'default-session';
    final context = body['context'] as Map<String, dynamic>?;

    if (message.trim().isEmpty) {
      await sendError(request, 'Message cannot be empty', HttpStatus.badRequest);
      return;
    }

    try {
      final response = await GeminiAssistantService.instance.chat(
        message: message,
        sessionId: sessionId,
        context: context,
      );
      await sendJson(request, response);
    } catch (e) {
      await sendJson(request, {
        'text': 'Gemini Assistant is temporarily unavailable. Please verify your internet connection or API key in Settings.',
        'error': e.toString(),
        'isError': true,
      });
    }
    return;
  }

  if (path == '/api/gemini/keywords' && method == 'POST') {
    final body = await parseJsonBody(request);
    final sessionId = body['sessionId']?.toString() ?? 'default-session';
    final context = body['context'] as Map<String, dynamic>?;
    final customFocus = body['customFocus'] as String?;

    try {
      final response = await GeminiAssistantService.instance.generateKeywords(
        sessionId: sessionId,
        context: context,
        customFocus: customFocus,
      );
      await sendJson(request, response);
    } catch (e) {
      await sendJson(request, {
        'text': 'Gemini Assistant is temporarily unavailable.',
        'keywords': [],
        'error': e.toString(),
      });
    }
    return;
  }

  if (path == '/api/gemini/queries' && method == 'POST') {
    final body = await parseJsonBody(request);
    final sessionId = body['sessionId']?.toString() ?? 'default-session';
    final context = body['context'] as Map<String, dynamic>?;

    try {
      final response = await GeminiAssistantService.instance.generateSearchQueries(
        sessionId: sessionId,
        context: context,
      );
      await sendJson(request, response);
    } catch (e) {
      await sendJson(request, {
        'text': 'Gemini Assistant is temporarily unavailable.',
        'queries': [],
        'error': e.toString(),
      });
    }
    return;
  }

  if (path == '/api/gemini/explain' && method == 'POST') {
    final body = await parseJsonBody(request);
    final sessionId = body['sessionId']?.toString() ?? 'default-session';
    final videoResult = body['videoResult'] as Map<String, dynamic>? ?? {};
    final context = body['context'] as Map<String, dynamic>?;

    try {
      final response = await GeminiAssistantService.instance.explainResult(
        sessionId: sessionId,
        videoResult: videoResult,
        context: context,
      );
      await sendJson(request, response);
    } catch (e) {
      await sendJson(request, {
        'text': 'Gemini Assistant is temporarily unavailable.',
        'error': e.toString(),
      });
    }
    return;
  }

  if (path == '/api/gemini/research' && method == 'POST') {
    final body = await parseJsonBody(request);
    final sessionId = body['sessionId']?.toString() ?? 'default-session';
    final context = body['context'] as Map<String, dynamic>?;

    try {
      final response = await GeminiAssistantService.instance.researchThis(
        sessionId: sessionId,
        context: context,
      );
      await sendJson(request, response);
    } catch (e) {
      await sendJson(request, {
        'text': 'Gemini Assistant is temporarily unavailable.',
        'error': e.toString(),
      });
    }
    return;
  }

  if (path == '/api/gemini/summarize' && method == 'POST') {
    final body = await parseJsonBody(request);
    final sessionId = body['sessionId']?.toString() ?? 'default-session';
    final context = body['context'] as Map<String, dynamic>?;

    try {
      final response = await GeminiAssistantService.instance.summarizeResults(
        sessionId: sessionId,
        context: context,
      );
      await sendJson(request, response);
    } catch (e) {
      await sendJson(request, {
        'text': 'Gemini Assistant is temporarily unavailable.',
        'error': e.toString(),
      });
    }
    return;
  }

  if (path == '/api/gemini/ideas' && method == 'POST') {
    final body = await parseJsonBody(request);
    final sessionId = body['sessionId']?.toString() ?? 'default-session';
    final context = body['context'] as Map<String, dynamic>?;

    try {
      final response = await GeminiAssistantService.instance.suggestContentIdeas(
        sessionId: sessionId,
        context: context,
      );
      await sendJson(request, response);
    } catch (e) {
      await sendJson(request, {
        'text': 'Gemini Assistant is temporarily unavailable.',
        'error': e.toString(),
      });
    }
    return;
  }

  if (path == '/api/gemini/reset' && method == 'POST') {
    final body = await parseJsonBody(request);
    final sessionId = body['sessionId']?.toString() ?? 'default-session';
    GeminiAssistantService.instance.clearSession(sessionId);
    await sendJson(request, {'success': true, 'message': 'Session history cleared'});
    return;
  }

  await sendError(request, 'Endpoint not found', HttpStatus.notFound);
}

Future<void> handleStaticFile(HttpRequest request) async {
  var path = request.uri.path;
  if (path == '/' || path.isEmpty) {
    path = '/index.html';
  }

  // Prevent directory traversal
  final safePath = path.replaceAll('..', '');
  final filePath = 'web' + (safePath.startsWith('/') ? safePath : '/$safePath');
  final file = File(filePath);

  if (!await file.exists()) {
    // If not found, serve index.html for SPA client-side routing
    final indexFile = File('web/index.html');
    if (await indexFile.exists()) {
      request.response.headers.contentType = ContentType.html;
      await indexFile.openRead().pipe(request.response);
      return;
    }
    request.response.statusCode = HttpStatus.notFound;
    request.response.write('404 Not Found');
    await request.response.close();
    return;
  }

  // MIME Types
  final ext = file.path.split('.').last.toLowerCase();
  switch (ext) {
    case 'html':
      request.response.headers.contentType = ContentType.html;
      break;
    case 'css':
      request.response.headers.set('Content-Type', 'text/css; charset=utf-8');
      break;
    case 'js':
      request.response.headers.set('Content-Type', 'application/javascript; charset=utf-8');
      break;
    case 'json':
      request.response.headers.contentType = ContentType.json;
      break;
    case 'png':
      request.response.headers.set('Content-Type', 'image/png');
      break;
    case 'jpg':
    case 'jpeg':
      request.response.headers.set('Content-Type', 'image/jpeg');
      break;
    case 'svg':
      request.response.headers.set('Content-Type', 'image/svg+xml');
      break;
    case 'mp4':
      request.response.headers.set('Content-Type', 'video/mp4');
      break;
    default:
      request.response.headers.contentType = ContentType.binary;
  }

  await file.openRead().pipe(request.response);
}

Future<Map<String, dynamic>> parseJsonBody(HttpRequest request) async {
  try {
    final content = await utf8.decoder.bind(request).join();
    if (content.trim().isEmpty) return {};
    return jsonDecode(content) as Map<String, dynamic>;
  } catch (e) {
    return {};
  }
}

Future<void> sendJson(HttpRequest request, Map<String, dynamic> data) async {
  request.response.statusCode = HttpStatus.ok;
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode(data));
  await request.response.close();
}

Future<void> sendError(HttpRequest request, String message, int statusCode) async {
  request.response.statusCode = statusCode;
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode({'error': message}));
  await request.response.close();
}
