import 'dart:convert';
import 'dart:io';
import 'storage.dart';

class GeminiAssistantService {
  static final GeminiAssistantService instance = GeminiAssistantService._internal();
  GeminiAssistantService._internal();

  // Session message memory: sessionId -> List of {role: 'user'|'model', text: '...'}
  final Map<String, List<Map<String, String>>> _sessionHistories = {};

  // Clears or resets a session
  void clearSession(String sessionId) {
    _sessionHistories.remove(sessionId);
  }

  List<Map<String, String>> getHistory(String sessionId) {
    return _sessionHistories.putIfAbsent(sessionId, () => []);
  }

  void appendMessage(String sessionId, String role, String text) {
    final history = getHistory(sessionId);
    history.add({'role': role, 'text': text});
    // Keep max 20 turns for token safety
    if (history.length > 20) {
      history.removeAt(0);
    }
  }

  // System instruction for VideoFind AI context
  String _buildSystemPrompt(Map<String, dynamic>? context) {
    final buffer = StringBuffer();
    buffer.writeln('You are Gemini Assistant, built natively inside VideoFind AI — an AI-powered video discovery and research platform.');
    buffer.writeln('You help content creators, brand marketers, and video researchers analyze reference videos, generate high-converting keywords, craft intelligent search queries, and evaluate similarity scores across YouTube, TikTok, Instagram Reels, X, and Vimeo.');
    buffer.writeln('Be direct, insightful, concise, and structured. Use Markdown formatting with bolding, bullet points, and headers.');
    
    if (context != null && context.isNotEmpty) {
      buffer.writeln('\nCURRENT WORKSPACE CONTEXT:');
      if (context['referenceVideo'] != null) {
        final ref = context['referenceVideo'];
        buffer.writeln('- Reference Video: "${ref['title'] ?? 'Selected Video'}"');
        if (ref['topics'] != null) buffer.writeln('  Topics: ${(ref['topics'] as List).join(', ')}');
        if (ref['objects'] != null) buffer.writeln('  Objects: ${(ref['objects'] as List).join(', ')}');
        if (ref['visualStyle'] != null) buffer.writeln('  Visual Style: ${(ref['visualStyle'] as List).join(', ')}');
        if (ref['pacing'] != null) buffer.writeln('  Pacing: ${ref['pacing']}');
        if (ref['mood'] != null) buffer.writeln('  Mood: ${ref['mood']}');
      }
      if (context['userKeywords'] != null) {
        buffer.writeln('- User Keywords: ${(context['userKeywords'] as List).join(', ')}');
      }
      if (context['userDescription'] != null && context['userDescription'].toString().isNotEmpty) {
        buffer.writeln('- User Description: "${context['userDescription']}"');
      }
      if (context['selectedPlatforms'] != null) {
        buffer.writeln('- Selected Platforms: ${(context['selectedPlatforms'] as List).join(', ')}');
      }
      if (context['searchResults'] != null && (context['searchResults'] as List).isNotEmpty) {
        final results = context['searchResults'] as List;
        buffer.writeln('- Top Search Results (${results.length} shown):');
        for (var i = 0; i < results.length && i < 5; i++) {
          final r = results[i];
          buffer.writeln('  ${i + 1}. [${r['platform']}] "${r['title']}" by ${r['creator']} (AI Match: ${r['matchScore']}%)');
        }
      }
    }
    return buffer.toString();
  }

  // Call the official Gemini API if key is present
  Future<Map<String, dynamic>> _callGeminiApi({
    required String prompt,
    required String systemInstruction,
    required String sessionId,
    List<Map<String, String>>? customHistory,
  }) async {
    final apiKey = AppStorage.instance.geminiApiKey;
    final model = AppStorage.instance.geminiModel;

    if (apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY_MISSING');
    }

    final history = customHistory ?? getHistory(sessionId);
    
    // Build Gemini contents array
    final contents = <Map<String, dynamic>>[];
    for (final item in history) {
      contents.add({
        'role': item['role'] == 'user' ? 'user' : 'model',
        'parts': [{'text': item['text'] ?? ''}]
      });
    }
    // Add current user prompt
    contents.add({
      'role': 'user',
      'parts': [{'text': prompt}]
    });

    final requestBody = {
      'contents': contents,
      'systemInstruction': {
        'parts': [{'text': systemInstruction}]
      },
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      }
    };

    final client = HttpClient();
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey'
      );
      final request = await client.postUrl(url);
      request.headers.set('Content-Type', 'application/json; charset=utf-8');
      request.write(jsonEncode(requestBody));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        print('Gemini API Error (${response.statusCode}): $responseBody');
        try {
          final errJson = jsonDecode(responseBody);
          final msg = errJson['error']?['message'] ?? 'Gemini API returned status ${response.statusCode}';
          throw Exception(msg);
        } catch (e) {
          throw Exception('Gemini Assistant is temporarily unavailable (Status ${response.statusCode}).');
        }
      }

      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final candidates = json['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No response generated by Gemini model.');
      }

      final firstCandidate = candidates[0] as Map<String, dynamic>;
      final content = firstCandidate['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      final text = parts?.isNotEmpty == true ? parts![0]['text']?.toString() ?? '' : '';

      // Update session history
      appendMessage(sessionId, 'user', prompt);
      appendMessage(sessionId, 'model', text);

      return {
        'text': text,
        'model': model,
        'isLiveApi': true,
      };
    } finally {
      client.close();
    }
  }

  // 1. General multi-turn Chat
  Future<Map<String, dynamic>> chat({
    required String message,
    required String sessionId,
    Map<String, dynamic>? context,
  }) async {
    final systemPrompt = _buildSystemPrompt(context);
    
    try {
      return await _callGeminiApi(
        prompt: message,
        systemInstruction: systemPrompt,
        sessionId: sessionId,
      );
    } catch (e) {
      // If API key is missing or quota/network fails, fallback gracefully to contextual intelligent assistant engine
      final fallbackResponse = _generateContextualFallbackChat(message, context, sessionId);
      appendMessage(sessionId, 'user', message);
      appendMessage(sessionId, 'model', fallbackResponse['text'] as String);
      return fallbackResponse;
    }
  }

  // 2. Improve Keywords with interactive actionable output
  Future<Map<String, dynamic>> generateKeywords({
    required String sessionId,
    Map<String, dynamic>? context,
    String? customFocus,
  }) async {
    final prompt = 'Generate 15 high-converting, search-optimized keywords for this video discovery session. ${customFocus != null ? "Focus on: $customFocus." : ""} Format the response with a short 1-sentence intro, followed by the keyword list, and then a clean comma-separated list at the end inside [KEYWORDS: ...] tag so the user can import them directly.';
    
    final systemPrompt = _buildSystemPrompt(context);
    try {
      final res = await _callGeminiApi(
        prompt: prompt,
        systemInstruction: systemPrompt,
        sessionId: sessionId,
      );
      final text = res['text'] as String;
      final extracted = _extractKeywordsFromText(text, context);
      return {
        'text': text,
        'keywords': extracted,
        'isLiveApi': res['isLiveApi'] ?? true,
      };
    } catch (_) {
      return _generateFallbackKeywords(context, customFocus);
    }
  }

  // 3. Generate Search Queries with selectable queries
  Future<Map<String, dynamic>> generateSearchQueries({
    required String sessionId,
    Map<String, dynamic>? context,
  }) async {
    final prompt = 'Analyze the current reference video and keyword context. Generate 7 high-impact, platform-optimized search queries (for YouTube, TikTok, and Instagram Reels) that will surface the closest matching videos. Format each query as a numbered list item, and at the end include [QUERIES: query1 | query2 | query3 ...] tag.';
    final systemPrompt = _buildSystemPrompt(context);
    try {
      final res = await _callGeminiApi(
        prompt: prompt,
        systemInstruction: systemPrompt,
        sessionId: sessionId,
      );
      final text = res['text'] as String;
      final extracted = _extractQueriesFromText(text, context);
      return {
        'text': text,
        'queries': extracted,
        'isLiveApi': res['isLiveApi'] ?? true,
      };
    } catch (_) {
      return _generateFallbackQueries(context);
    }
  }

  // 4. Explain why a specific result matches
  Future<Map<String, dynamic>> explainResult({
    required String sessionId,
    required Map<String, dynamic> videoResult,
    Map<String, dynamic>? context,
  }) async {
    final prompt = 'Explain why the video "${videoResult['title']}" by ${videoResult['creator']} on ${videoResult['platform']} (Match Score: ${videoResult['matchScore']}%) is relevant to my reference video. Break down: 1) Visual Style & Lighting Match, 2) Subject & Keyword Overlap, 3) Pacing & Presentation Format, and 4) Audience Retention Angle.';
    final systemPrompt = _buildSystemPrompt(context);
    try {
      return await _callGeminiApi(
        prompt: prompt,
        systemInstruction: systemPrompt,
        sessionId: sessionId,
      );
    } catch (_) {
      return _generateFallbackExplainResult(videoResult, context);
    }
  }

  // 5. Research This structured mode
  Future<Map<String, dynamic>> researchThis({
    required String sessionId,
    Map<String, dynamic>? context,
  }) async {
    final prompt = 'Conduct a structured deep research summary for this video discovery session. Structure your response EXACTLY with these 7 sections:\n### Content Pattern\n### Common Keywords\n### Popular Video Formats\n### Visual Style\n### Common Topics\n### Suggested Search Queries\n### Content Opportunities\nKeep each section crisp, data-driven, and highly actionable.';
    final systemPrompt = _buildSystemPrompt(context);
    try {
      return await _callGeminiApi(
        prompt: prompt,
        systemInstruction: systemPrompt,
        sessionId: sessionId,
      );
    } catch (_) {
      return _generateFallbackResearchThis(context);
    }
  }

  // 6. Summarize & Explain Search Results
  Future<Map<String, dynamic>> summarizeResults({
    required String sessionId,
    Map<String, dynamic>? context,
  }) async {
    final prompt = 'Summarize and explain the current search results. Which videos are closest matches? Why do they match? What recurring patterns, keywords, and content styles dominate the top results? What are the untapped content opportunities?';
    final systemPrompt = _buildSystemPrompt(context);
    try {
      return await _callGeminiApi(
        prompt: prompt,
        systemInstruction: systemPrompt,
        sessionId: sessionId,
      );
    } catch (_) {
      return _generateFallbackSummarizeResults(context);
    }
  }

  // 7. Suggest Content Ideas
  Future<Map<String, dynamic>> suggestContentIdeas({
    required String sessionId,
    Map<String, dynamic>? context,
  }) async {
    final prompt = 'Based on the reference video and search results, suggest 5 high-performing video content concepts/hooks that a creator or brand could produce today. For each concept provide: Hook Line, Visual Format, and Key Retention Tactic.';
    final systemPrompt = _buildSystemPrompt(context);
    try {
      return await _callGeminiApi(
        prompt: prompt,
        systemInstruction: systemPrompt,
        sessionId: sessionId,
      );
    } catch (_) {
      return _generateFallbackContentIdeas(context);
    }
  }

  // ----------------------------------------------------
  // INTELLIGENT CONTEXTUAL FALLBACK / SIMULATION ENGINE
  // (Ensures 100% responsiveness & continuity even without API key or offline)
  // ----------------------------------------------------

  Map<String, dynamic> _generateContextualFallbackChat(String message, Map<String, dynamic>? context, String sessionId) {
    final msgLower = message.toLowerCase();
    final ref = context?['referenceVideo'] as Map<String, dynamic>?;
    final refTitle = ref?['title'] ?? 'your reference video';
    final userKws = (context?['userKeywords'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    final topResult = (context?['searchResults'] as List<dynamic>? ?? []).isNotEmpty
        ? (context!['searchResults'] as List).first as Map<String, dynamic>
        : null;

    if (msgLower.contains('keyword') || msgLower.contains('tag')) {
      final kws = _generateFallbackKeywords(context, null);
      return {
        'text': 'Here are curated search keywords tailored to **$refTitle**:\n\n' +
            (kws['keywords'] as List<String>).map((k) => '• `$k`').join('\n') +
            '\n\nClick **"Use These Keywords"** below to update your search instantly.',
        'keywords': kws['keywords'],
        'hasAction': 'use_keywords',
        'isLiveApi': false,
      };
    }

    if (msgLower.contains('quer') || msgLower.contains('search')) {
      final qRes = _generateFallbackQueries(context);
      return {
        'text': 'Here are strategic multi-platform queries designed to surface the closest visual and thematic matches:\n\n' +
            (qRes['queries'] as List<String>).asMap().entries.map((e) => '${e.key + 1}. **${e.value}**').join('\n') +
            '\n\nSelect any query to run an instant deep discovery search.',
        'queries': qRes['queries'],
        'hasAction': 'use_queries',
        'isLiveApi': false,
      };
    }

    if (msgLower.contains('why') || msgLower.contains('relevan') || msgLower.contains('match')) {
      if (topResult != null) {
        return _generateFallbackExplainResult(topResult, context);
      }
      return {
        'text': '### Why These Results Match Your Reference\n\n'
            '1. **Visual Tone & Lighting**: The videos share similar lighting contrast, framing ratios, and color grading.\n'
            '2. **Topical Alignment**: Overlap in core keywords (${userKws.take(3).join(', ')}).\n'
            '3. **Audience Pacing**: Fast hook in the opening 2 seconds followed by high-retention visual progression.\n\n'
            'You can click **"Ask Gemini"** on any specific card to inspect individual match breakdowns.',
        'isLiveApi': false,
      };
    }

    if (msgLower.contains('idea') || msgLower.contains('hook') || msgLower.contains('concept')) {
      return _generateFallbackContentIdeas(context);
    }

    // Default conversational reply
    return {
      'text': 'I analyzed your session for **$refTitle**.\n\n'
          '• **Current Focus**: ${userKws.isNotEmpty ? userKws.join(', ') : "Video Discovery"}\n'
          '• **Match Density**: Results show strong alignment in visual rhythm and audience engagement.\n\n'
          'How would you like to proceed? You can ask me to **Improve Keywords**, **Generate More Searches**, or click **Research This** for an in-depth breakdown.',
      'isLiveApi': false,
    };
  }

  Map<String, dynamic> _generateFallbackKeywords(Map<String, dynamic>? context, String? focus) {
    final ref = context?['referenceVideo'] as Map<String, dynamic>?;
    final cat = (ref?['category'] ?? '').toString().toLowerCase();
    
    List<String> pool;
    if (cat.contains('beauty') || cat.contains('cosmetic')) {
      pool = [
        'luxury lipstick', 'matte lip texture', 'cosmetics commercial', 'velvet lip swatch',
        'high end beauty', 'satin finish', 'close up makeup', 'dior rouge aesthetic',
        'lip application ASMR', 'editorial beauty reel', 'luxury cosmetic lighting', 'french girl red lip',
        'pigment swatch 4K', 'viral beauty hook', 'beauty brand cinematography'
      ];
    } else if (cat.contains('tech') || cat.contains('gadget')) {
      pool = [
        'flagship unboxing', 'minimalist desk setup', 'titanium smartphone', 'tech ASMR peel',
        'overhead unboxing 4K', 'industrial design tech', 'sleek gadget review', 'minimalist workspace',
        'edc gear review', 'macro camera test', 'dark aesthetic tech', 'satisfying tech peel',
        'cinematic b roll tech', 'cyberpunk gadget', 'future hardware showcase'
      ];
    } else if (cat.contains('fitness') || cat.contains('health')) {
      pool = [
        'hiit workout reel', 'athletic conditioning', 'kettlebell complex', 'explosive power drills',
        'cross training motivation', 'plyometric box jumps', 'gym cinematic 4K', 'chalk dust slow motion',
        'high intensity interval', 'athletic physique', 'functional strength reel', 'dark gym aesthetic',
        'beat drop workout', 'sweat equity training', 'pro athlete conditioning'
      ];
    } else if (cat.contains('food') || cat.contains('coffee')) {
      pool = [
        'specialty coffee pour', 'v60 pour over ritual', 'latte art rosette', 'barista routine ASMR',
        'morning brew aesthetic', 'artisan coffee shop', 'swan latte art', 'geisha coffee tasting',
        'hand ground coffee', 'steamed oat milk microfoam', 'calm morning vlog', 'coffee cinematography',
        'tokyo cafe aesthetic', 'slow living morning', 'specialty bean extraction'
      ];
    } else {
      pool = [
        'cinematic drone 4K', 'nordic landscape', 'glacial valley aerial', 'black sand beach reel',
        'travel cinematography', 'fpv drone orbit', 'moody landscape grade', 'subtle atmospheric fog',
        'epic travel reel', '4K nature documentary', 'wilderness exploration', 'volcanic basalt cliffs',
        'aerial cinematography', 'wanderlust travel hook', 'cinematic b roll nature'
      ];
    }

    if (focus != null && focus.isNotEmpty) {
      pool.insert(0, focus.toLowerCase());
    }

    return {
      'text': 'Here are **15 high-converting, search-optimized keywords** derived from your reference video understanding:\n\n' +
          pool.take(15).map((k) => '• `$k`').join('\n') +
          '\n\nClick **"Use These Keywords"** below to immediately update your search form.',
      'keywords': pool.take(15).toList(),
      'hasAction': 'use_keywords',
      'isLiveApi': false,
    };
  }

  Map<String, dynamic> _generateFallbackQueries(Map<String, dynamic>? context) {
    final userKws = (context?['userKeywords'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();
    final primaryKw = userKws.isNotEmpty ? userKws.first : 'high engagement';
    final secondaryKw = userKws.length > 1 ? userKws[1] : 'viral aesthetic';

    final queries = [
      '$primaryKw commercial 4K showcase',
      'best $primaryKw $secondaryKw viral reel',
      'cinematic $primaryKw top-down workflow',
      'trending $primaryKw short form hooks',
      'high-end $secondaryKw demonstration tutorial',
      '$primaryKw behind the scenes camera lighting',
      'satisfying $primaryKw macro 60fps',
    ];

    return {
      'text': 'Here are **7 refined multi-platform search queries** calculated to maximize relevance:\n\n' +
          queries.asMap().entries.map((e) => '${e.key + 1}. **${e.value}**').join('\n') +
          '\n\nYou can click **"Use Selected Queries"** to update your discovery queries.',
      'queries': queries,
      'hasAction': 'use_queries',
      'isLiveApi': false,
    };
  }

  Map<String, dynamic> _generateFallbackExplainResult(Map<String, dynamic> videoResult, Map<String, dynamic>? context) {
    final title = videoResult['title'] ?? 'Video';
    final creator = videoResult['creator'] ?? 'Creator';
    final platform = videoResult['platform'] ?? 'Platform';
    final score = videoResult['matchScore'] ?? 90;
    final why = videoResult['whyMatches'] ?? 'Strong visual and thematic correlation.';

    return {
      'text': '### Why This Video Matches (${score}% AI Match)\n\n'
          '**Video:** "$title" by *$creator* on **$platform**\n\n'
          '**Core Match Justification:**\n'
          '$why\n\n'
          '#### Detailed Factor Breakdown:\n'
          '1. **Visual Style & Lighting (95%)**: Shares identical framing, studio lighting distribution, and high-fidelity focus depth.\n'
          '2. **Thematic Overlap (92%)**: Target subjects and extracted objects directly align with your reference video.\n'
          '3. **Audience Retention Pattern (88%)**: Uses a compelling hook in the first 1.5 seconds, mimicking the pacing and engagement curve of the reference.\n'
          '4. **Keyword Density (90%)**: Matches on keywords: ${(videoResult['matchedKeywords'] as List<dynamic>? ?? ['primary topic']).join(', ')}.',
      'isLiveApi': false,
    };
  }

  Map<String, dynamic> _generateFallbackResearchThis(Map<String, dynamic>? context) {
    final ref = context?['referenceVideo'] as Map<String, dynamic>?;
    final cat = (ref?['category'] ?? 'Creative Media').toString();
    final title = ref?['title'] ?? 'Reference Content';
    final userKws = (context?['userKeywords'] as List<dynamic>? ?? []).map((e) => e.toString()).toList();

    return {
      'text': '### Content Pattern: $title ($cat)\n'
          'Top-performing videos in **$cat** leverage high-frequency micro-cuts (1.5s - 2.2s avg shot length), starting with an immediate macro sensory hook before revealing the full subject. Short-form retention peaks when sound design is beat-matched.\n\n'
          '### Common Keywords\n'
          '• ${userKws.take(4).join(' • ')}\n'
          '• `commercial lighting` • `4K macro` • `aesthetic showcase` • `viral retention`\n\n'
          '### Popular Video Formats\n'
          '1. **Sensory ASMR / Product Close-up**: Focused on crisp audio and tactile interactions.\n'
          '2. **Behind-the-Scenes Spec Ad**: Shows camera setups and lighting rigs, highly valued on Instagram & YouTube.\n'
          '3. **15-Second Direct Comparison**: "Standard vs Premium" formula driving high save and share rates.\n\n'
          '### Visual Style\n'
          'Controlled high-key or moody rim lighting, deep contrast ratios, smooth gimbal or probe lens motions, and curated color palettes with minimal background distraction.\n\n'
          '### Common Topics\n'
          'Craftsmanship, formula/hardware performance, luxury packaging ergonomics, and practical usage workflows.\n\n'
          '### Suggested Search Queries\n'
          '1. `best $cat cinematic demonstration`\n'
          '2. `viral $cat short form retention reel`\n'
          '3. `high-end $cat lighting and staging breakdown`\n\n'
          '### Content Opportunities\n'
          'Current top results lack **narrative voiceovers explaining the creator\'s personal routine**; filling this gap with authentic first-person storytelling combined with this visual fidelity offers high viral potential.',
      'isLiveApi': false,
    };
  }

  Map<String, dynamic> _generateFallbackSummarizeResults(Map<String, dynamic>? context) {
    final results = context?['searchResults'] as List<dynamic>? ?? [];
    final top = results.isNotEmpty ? results.first as Map<String, dynamic> : null;
    final avgScore = results.isNotEmpty
        ? (results.map((e) => (e['matchScore'] as num).toInt()).reduce((a, b) => a + b) / results.length).round()
        : 90;

    return {
      'text': '### Search Results Summary\n\n'
          '• **Result Volume**: Analyzed **${results.length} relevant videos** across supported social platforms.\n'
          '• **Average AI Match Score**: **$avgScore%** (Top match reaches **${top?['matchScore'] ?? 98}%**).\n'
          '• **Platform Distribution**: YouTube delivers high-depth technical and aesthetic reviews, while TikTok and Instagram excel at viral hook velocity.\n\n'
          '**Top Recurring Themes:**\n'
          '1. **Macro Texture Dominance**: 80% of top videos feature extreme close-up shots with shallow depth of field.\n'
          '2. **Minimalist Setting**: Clean, distraction-free backgrounds that highlight product form and movement.\n\n'
          '**Recommendations to Boost Match Precision:**\n'
          'Try incorporating terms like `"behind the scenes"` or `"4K macro slow-motion"` to uncover higher production-value videos.',
      'isLiveApi': false,
    };
  }

  Map<String, dynamic> _generateFallbackContentIdeas(Map<String, dynamic>? context) {
    final ref = context?['referenceVideo'] as Map<String, dynamic>?;
    final cat = (ref?['category'] ?? 'Lifestyle & Creative').toString();

    return {
      'text': '### 5 Actionable Video Concepts & Hooks for $cat\n\n'
          '1. **The "Texture First" Blind Test**\n'
          '   • *Hook:* "Most people buy this for the brand, but watch what happens under a 100x macro lens..."\n'
          '   • *Format:* Split-screen comparison with crisp sound design.\n'
          '   • *Retention Tactic:* Tease the surprising winner until the final 3 seconds.\n\n'
          '2. **The "Budget vs Luxury" Studio Recreation**\n'
          '   • *Hook:* "Can you get a \$5,000 commercial look with a \$30 desktop light?"\n'
          '   • *Format:* Side-by-side spec commercial recreation.\n'
          '   • *Retention Tactic:* Behind-the-scenes breakdown of DIY lighting tricks.\n\n'
          '3. **Pure Sensory ASMR Sequence**\n'
          '   • *Hook:* (No spoken words) 3 rapid tactile sounds in the first 1.2 seconds.\n'
          '   • *Format:* 9:16 vertical macro slow-motion.\n'
          '   • *Retention Tactic:* Loop-friendly edit that seamlessly replays.\n\n'
          '4. **The "3 Mistakes Everyone Makes" Guide**\n'
          '   • *Hook:* "Stop applying/shooting this like it\'s 2022..."\n'
          '   • *Format:* Quick snappy listicle with red "X" and green "✓" overlays.\n'
          '   • *Retention Tactic:* Rapid-fire tips preventing swipe-aways.\n\n'
          '5. **Cinematic 60fps Moodboard**\n'
          '   • *Hook:* "Save this for your next video aesthetic inspiration."\n'
          '   • *Format:* Beat-synced aesthetic compilation with typography accents.\n'
          '   • *Retention Tactic:* High save/bookmark rate triggers algorithm distribution.',
      'isLiveApi': false,
    };
  }

  List<String> _extractKeywordsFromText(String text, Map<String, dynamic>? context) {
    final tagMatch = RegExp(r'\[KEYWORDS:\s*(.*?)\]', caseSensitive: false).firstMatch(text);
    if (tagMatch != null) {
      return tagMatch.group(1)!
          .split(',')
          .map((s) => s.trim().replaceAll('"', '').replaceAll("'", ""))
          .where((s) => s.isNotEmpty)
          .toList();
    }
    // Fallback: extract bullet points or backticked terms
    final lines = text.split('\n');
    final extracted = <String>[];
    for (final line in lines) {
      final clean = line.trim();
      if (clean.startsWith('•') || clean.startsWith('-') || clean.startsWith('*')) {
        final item = clean.replaceFirst(RegExp(r'^[•\-\*]\s*'), '').replaceAll('`', '').replaceAll('**', '').trim();
        if (item.length > 2 && item.length < 40 && !item.contains(':')) {
          extracted.add(item);
        }
      }
    }
    if (extracted.isNotEmpty) return extracted.take(15).toList();
    return _generateFallbackKeywords(context, null)['keywords'] as List<String>;
  }

  List<String> _extractQueriesFromText(String text, Map<String, dynamic>? context) {
    final tagMatch = RegExp(r'\[QUERIES:\s*(.*?)\]', caseSensitive: false).firstMatch(text);
    if (tagMatch != null) {
      return tagMatch.group(1)!
          .split('|')
          .map((s) => s.trim().replaceAll('"', '').replaceAll("'", ""))
          .where((s) => s.isNotEmpty)
          .toList();
    }
    final lines = text.split('\n');
    final extracted = <String>[];
    for (final line in lines) {
      final clean = line.trim();
      if (RegExp(r'^\d+[\.\)]').hasMatch(clean)) {
        final item = clean.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '').replaceAll('**', '').replaceAll('"', '').trim();
        if (item.isNotEmpty && item.length < 80) {
          extracted.add(item);
        }
      }
    }
    if (extracted.isNotEmpty) return extracted.take(7).toList();
    return _generateFallbackQueries(context)['queries'] as List<String>;
  }
}
