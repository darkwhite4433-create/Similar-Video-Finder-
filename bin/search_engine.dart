import 'dart:math';

class ReferenceVideoPreset {
  final String id;
  final String title;
  final String category;
  final String duration;
  final String thumbnailUrl;
  final String videoUrl;
  final String description;
  final List<String> defaultKeywords;
  final List<String> topics;
  final List<String> objects;
  final List<String> visualStyle;
  final String pacing;
  final String mood;

  ReferenceVideoPreset({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.description,
    required this.defaultKeywords,
    required this.topics,
    required this.objects,
    required this.visualStyle,
    required this.pacing,
    required this.mood,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'duration': duration,
    'thumbnailUrl': thumbnailUrl,
    'videoUrl': videoUrl,
    'description': description,
    'defaultKeywords': defaultKeywords,
    'topics': topics,
    'objects': objects,
    'visualStyle': visualStyle,
    'pacing': pacing,
    'mood': mood,
  };
}

class SearchEngine {
  static final SearchEngine instance = SearchEngine._internal();
  SearchEngine._internal();

  final List<ReferenceVideoPreset> presets = [
    ReferenceVideoPreset(
      id: 'ref-luxury-lipstick',
      title: 'Velvet Matte Luxury Lipstick Commercial',
      category: 'Beauty & Cosmetics',
      duration: '0:34',
      thumbnailUrl: 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?auto=format&fit=crop&w=800&q=80',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      description: 'Cinematic high-end lipstick showcase with macro close-ups, satin textures, and dynamic lighting transitions.',
      defaultKeywords: ['luxury lipstick', 'matte red lips', 'cosmetics commercial', 'beauty macro', 'velvet texture'],
      topics: ['beauty', 'luxury cosmetics', 'lipstick application', 'commercial cinematography'],
      objects: ['gold lipstick bullet', 'velvet applicator', 'minimalist mirrored podium', 'cosmetic packaging'],
      visualStyle: ['macro slow-motion', 'high-key studio lighting', 'rich burgundy & gold palette', 'depth-of-field blur'],
      pacing: 'Slow & sensual (commercial rhythm)',
      mood: 'Elegant, premium, sophisticated',
    ),
    ReferenceVideoPreset(
      id: 'ref-tech-unboxing',
      title: 'Minimalist Cyberpunk Smartphone Unboxing',
      category: 'Tech & Gadgets',
      duration: '1:15',
      thumbnailUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=800&q=80',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
      description: 'Overhead desk unboxing with satisfying ASMR peel, titanium chassis inspection, and camera sensor test shots.',
      defaultKeywords: ['flagship unboxing', 'minimalist desk setup', 'titanium smartphone', 'tech ASMR', 'gadget review'],
      topics: ['technology', 'smartphones', 'unboxing experience', 'industrial design'],
      objects: ['matte black packaging', 'matte titanium frame', 'oled screen reflection', 'camera module'],
      visualStyle: ['top-down 90-degree angle', 'diffused overhead softbox', 'clean desk aesthetic', 'punchy sound design'],
      pacing: 'Snappy & rhythmic with tactile cuts',
      mood: 'Futuristic, clean, enthusiast',
    ),
    ReferenceVideoPreset(
      id: 'ref-hiit-fitness',
      title: 'Explosive Athletic Conditioning HIIT Reel',
      category: 'Fitness & Health',
      duration: '0:45',
      thumbnailUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=800&q=80',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      description: 'High-octane gym workout sequence with kettlebell snatches, plyometric box jumps, and energetic beat drops.',
      defaultKeywords: ['hiit workout', 'athletic training', 'kettlebell complex', 'gym reel', 'explosive power'],
      topics: ['functional fitness', 'cross-training', 'athletic conditioning', 'workout motivation'],
      objects: ['cast-iron kettlebells', 'chalk dust cloud', 'plyo wooden box', 'speed rope'],
      visualStyle: ['handheld dynamic camera', 'high frame-rate speed ramps', 'dark industrial gym background', 'high contrast'],
      pacing: 'Rapid-fire, beat-synced action',
      mood: 'Intense, gritty, motivational',
    ),
    ReferenceVideoPreset(
      id: 'ref-artisan-coffee',
      title: 'Specialty Pour-Over & Latte Art Workflow',
      category: 'Food & Culinary',
      duration: '0:58',
      thumbnailUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      description: 'Morning barista routine showing hand grinding, bloom agitation, goose-neck kettle pour, and rosette latte art.',
      defaultKeywords: ['specialty coffee', 'pour over v60', 'latte art rosette', 'barista routine', 'morning brew ASMR'],
      topics: ['coffee culture', 'specialty brewing', 'latte art', 'culinary craftsmanship'],
      objects: ['ceramic dripper', 'copper gooseneck kettle', 'steamed oat milk pitcher', 'freshly roasted beans'],
      visualStyle: ['warm morning sunlight', 'shallow focal plane', 'smooth gimbal pans', 'earthy tone grading'],
      pacing: 'Calm, meditative, artisanal',
      mood: 'Cozy, organic, therapeutic',
    ),
    ReferenceVideoPreset(
      id: 'ref-iceland-drone',
      title: 'Cinematic Glacial Valley & Black Sand Drone Reel',
      category: 'Travel & Nature',
      duration: '1:20',
      thumbnailUrl: 'https://images.unsplash.com/photo-1504893524553-b855bce32c67?auto=format&fit=crop&w=800&q=80',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
      description: 'Sweeping aerial views across volcanic black sand beaches, turquoise glacier rivers, and mossy canyon cliffs.',
      defaultKeywords: ['iceland 4k aerial', 'black sand beach', 'cinematic drone', 'glacier river', 'nordic landscape'],
      topics: ['travel cinematography', 'drone photography', 'nordic landscapes', 'wilderness nature'],
      objects: ['fpv drone viewpoint', 'volcanic basalt cliffs', 'braided river deltas', 'coastal sea stack'],
      visualStyle: ['wide-angle 4K aerials', 'cool moody desaturated blues', 'subtle fog layers', 'epic slow orbits'],
      pacing: 'Majestic, soaring, expansive',
      mood: 'Awe-inspiring, cinematic, wild',
    ),
  ];

  // Comprehensive multi-platform catalog
  final List<Map<String, dynamic>> _catalog = [
    // Beauty / Cosmetics
    {
      'id': 'yt-b01',
      'platform': 'YouTube',
      'title': 'Dior Rouge Satin vs Matte: The Ultimate 4K Macro Lipstick Test',
      'creator': 'Aurielle Glow Lab',
      'creatorAvatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'duration': '8:24',
      'views': '482K',
      'published': '3 days ago',
      'category': 'Beauty & Cosmetics',
      'topics': ['beauty', 'luxury cosmetics', 'lipstick application', 'commercial cinematography', 'formula comparison'],
      'keywords': ['luxury lipstick', 'matte red lips', 'cosmetics commercial', 'dior rouge', 'macro swatch', 'velvet texture'],
      'visualStyle': ['macro slow-motion', 'high-key studio lighting', 'rich burgundy & gold palette'],
      'whyMatches': 'Exact visual styling with macro lens close-ups, velvet lipstick textures, and premium luxury color grading.',
      'baseScore': 97,
    },
    {
      'id': 'tk-b02',
      'platform': 'TikTok',
      'title': 'The French girl red lip that stays on for 16 hours straight 💄✨',
      'creator': '@camille.beaute',
      'creatorAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'duration': '0:28',
      'views': '2.1M',
      'published': '1 week ago',
      'category': 'Beauty & Cosmetics',
      'topics': ['beauty', 'lipstick application', 'short form beauty', 'french aesthetic'],
      'keywords': ['luxury lipstick', 'french girl makeup', 'longwear lipstick', 'red lip tutorial', 'aesthetic lips'],
      'visualStyle': ['natural golden hour light', 'direct face-to-camera', 'quick cuts'],
      'whyMatches': 'High keyword and topic overlap with emphasis on luxury red lipstick wearability and viral short-form retention.',
      'baseScore': 91,
    },
    {
      'id': 'ig-b03',
      'platform': 'Instagram',
      'title': 'Behind the Scenes: Directing a High-End Chanel Cosmetic Campaign',
      'creator': 'Studio Noir Cinematics',
      'creatorAvatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'duration': '0:42',
      'views': '830K',
      'published': '2 weeks ago',
      'category': 'Beauty & Cosmetics',
      'topics': ['commercial cinematography', 'luxury cosmetics', 'behind the scenes', 'lighting design'],
      'keywords': ['cosmetics commercial', 'lighting setup', 'beauty macro', 'cinematic lighting', 'luxury packaging'],
      'visualStyle': ['behind-the-scenes cinema rig', 'macro probes', 'dark moody luxury studio'],
      'whyMatches': 'Matches the commercial production techniques and lighting architecture shown in the reference video.',
      'baseScore': 89,
    },
    {
      'id': 'vm-b04',
      'platform': 'Vimeo',
      'title': 'Elegance Redefined: Yves Saint Laurent Velvet Collection Spec Ad',
      'creator': 'Laurent & Moreau Filmworks',
      'creatorAvatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'duration': '1:05',
      'views': '94K',
      'published': '1 month ago',
      'category': 'Beauty & Cosmetics',
      'topics': ['luxury cosmetics', 'commercial cinematography', 'spec commercial', 'color science'],
      'keywords': ['luxury lipstick', 'velvet texture', 'cosmetics commercial', 'spec ad', 'color grading'],
      'visualStyle': ['anamorphic flares', 'macro probe lens', 'ultra high-speed phantom camera'],
      'whyMatches': 'Identical cinematic tone, slow sensory pacing, and ultra high-speed macro product shots.',
      'baseScore': 94,
    },
    {
      'id': 'x-b05',
      'platform': 'X / Twitter',
      'title': 'Texture study: 1000fps capture of ruby pigment suspension in cosmetic wax',
      'creator': '@MaterialCinematics',
      'creatorAvatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=150&q=80',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'duration': '0:18',
      'views': '350K',
      'published': '5 days ago',
      'category': 'Beauty & Cosmetics',
      'topics': ['macro slow-motion', 'material physics', 'luxury cosmetics', 'visual texture'],
      'keywords': ['beauty macro', 'velvet texture', 'pigment study', 'cosmetic chemistry', 'slow motion'],
      'visualStyle': ['extreme macro', 'fluid motion', 'crimson saturated lighting'],
      'whyMatches': 'Shares the extreme macro lens focus and high-end textural detail of luxury cosmetic formulations.',
      'baseScore': 86,
    },

    // Tech / Gadgets
    {
      'id': 'yt-t01',
      'platform': 'YouTube',
      'title': 'Nothing Phone (3) Dark Edition: The Most Satisfying Unboxing Yet',
      'creator': 'Minimal Tech Studio',
      'creatorAvatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
      'duration': '12:10',
      'views': '1.4M',
      'published': '2 days ago',
      'category': 'Tech & Gadgets',
      'topics': ['technology', 'smartphones', 'unboxing experience', 'industrial design'],
      'keywords': ['flagship unboxing', 'minimalist desk setup', 'titanium smartphone', 'tech ASMR', 'gadget review'],
      'visualStyle': ['top-down 90-degree angle', 'diffused overhead softbox', 'clean desk aesthetic'],
      'whyMatches': 'Nearly 1:1 camera framing match with crisp top-down desk perspective, tactile audio, and clean industrial lighting.',
      'baseScore': 98,
    },
    {
      'id': 'tk-t02',
      'platform': 'TikTok',
      'title': 'Peeling the factory screen seal in 4K 🎧 ASMR only',
      'creator': '@puretech_asmr',
      'creatorAvatar': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=150&q=80',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
      'duration': '0:22',
      'views': '4.8M',
      'published': '4 days ago',
      'category': 'Tech & Gadgets',
      'topics': ['unboxing experience', 'tech ASMR', 'smartphones', 'short form tech'],
      'keywords': ['tech ASMR', 'flagship unboxing', 'screen peel', 'gadget review', 'satisfying sounds'],
      'visualStyle': ['close-up handheld', 'crisp binaural audio', 'sleek black studio background'],
      'whyMatches': 'Mirrors the tactile tactile sensory experience and screen peel moment from the reference video.',
      'baseScore': 92,
    },
    {
      'id': 'vm-t03',
      'platform': 'Vimeo',
      'title': 'Form & Function: Industrial Design Showcase of Modern Flagships',
      'creator': 'Aesthetic Foundry',
      'creatorAvatar': 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?auto=format&fit=crop&w=150&q=80',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
      'duration': '2:40',
      'views': '120K',
      'published': '3 weeks ago',
      'category': 'Tech & Gadgets',
      'topics': ['industrial design', 'smartphones', 'technology', 'product design'],
      'keywords': ['titanium smartphone', 'minimalist desk setup', 'hardware architecture', 'matte finish'],
      'visualStyle': ['turntable rotation', 'grazing rim light', 'high fidelity reflections'],
      'whyMatches': 'Aligns with the precision engineering, matte titanium reflections, and minimalist hardware presentation.',
      'baseScore': 90,
    },

    // Fitness / Health
    {
      'id': 'yt-f01',
      'platform': 'YouTube',
      'title': 'The 20-Min Savage Kettlebell & Plyo Conditioning Protocol',
      'creator': 'Iron Velocity Athlete',
      'creatorAvatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=150&q=80',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'duration': '22:15',
      'views': '780K',
      'published': '1 week ago',
      'category': 'Fitness & Health',
      'topics': ['functional fitness', 'cross-training', 'athletic conditioning', 'workout motivation'],
      'keywords': ['hiit workout', 'athletic training', 'kettlebell complex', 'gym reel', 'explosive power'],
      'visualStyle': ['handheld dynamic camera', 'high frame-rate speed ramps', 'dark industrial gym background'],
      'whyMatches': 'Identical movement vocabulary: heavy kettlebell swings, chalk cloud dynamics, and gritty gym lighting.',
      'baseScore': 96,
    },
    {
      'id': 'ig-f02',
      'platform': 'Instagram',
      'title': 'Speed & Agility: Plyometric Power Drills that increase vertical jump',
      'creator': '@apex_performance_pro',
      'creatorAvatar': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=150&q=80',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'duration': '0:35',
      'views': '1.1M',
      'published': '3 days ago',
      'category': 'Fitness & Health',
      'topics': ['athletic conditioning', 'functional fitness', 'plyometrics', 'vertical jump'],
      'keywords': ['explosive power', 'athletic training', 'plyo box', 'hiit workout', 'gym reel'],
      'visualStyle': ['fast whip pans', 'speed ramp cuts on landing', 'strobe backlighting'],
      'whyMatches': 'Shares the rapid-fire beat synced pacing, plyometric jump mechanics, and high-energy workout style.',
      'baseScore': 93,
    },

    // Food / Coffee
    {
      'id': 'yt-c01',
      'platform': 'YouTube',
      'title': 'Mastering the 4:6 Method: V60 Brew Guide for Geisha Coffee',
      'creator': 'James & The Beans',
      'creatorAvatar': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=150&q=80',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      'duration': '14:02',
      'views': '620K',
      'published': '5 days ago',
      'category': 'Food & Culinary',
      'topics': ['coffee culture', 'specialty brewing', 'latte art', 'culinary craftsmanship'],
      'keywords': ['specialty coffee', 'pour over v60', 'barista routine', 'morning brew ASMR', 'geisha coffee'],
      'visualStyle': ['warm morning sunlight', 'shallow focal plane', 'earthy tone grading'],
      'whyMatches': 'Exact pour-over technique match, gooseneck kettle water control, and calm natural morning lighting.',
      'baseScore': 95,
    },
    {
      'id': 'tk-c02',
      'platform': 'TikTok',
      'title': 'Slow morning in Tokyo: Pouring a 12-wing swan latte art ☕️🤍',
      'creator': '@tokyocoffeevibes',
      'creatorAvatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
      'duration': '0:45',
      'views': '3.2M',
      'published': '6 days ago',
      'category': 'Food & Culinary',
      'topics': ['latte art', 'coffee culture', 'tokyo cafe', 'morning routine'],
      'keywords': ['latte art rosette', 'specialty coffee', 'morning brew ASMR', 'barista routine', 'swan latte art'],
      'visualStyle': ['top-down latte pour', 'gentle acoustic soundtrack', 'warm pastel grading'],
      'whyMatches': 'Matches the silky milk texture and delicate pour technique showcased in the artisan reference.',
      'baseScore': 92,
    },

    // Travel / Cinematic Drone
    {
      'id': 'yt-d01',
      'platform': 'YouTube',
      'title': 'ICELAND 8K HDR: FPV Drone Flight Over Glacial Rivers & Volcanoes',
      'creator': 'Nordic Aero Cinematic',
      'creatorAvatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1504893524553-b855bce32c67?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
      'duration': '5:48',
      'views': '1.8M',
      'published': '1 week ago',
      'category': 'Travel & Nature',
      'topics': ['travel cinematography', 'drone photography', 'nordic landscapes', 'wilderness nature'],
      'keywords': ['iceland 4k aerial', 'black sand beach', 'cinematic drone', 'glacier river', 'nordic landscape'],
      'visualStyle': ['wide-angle 4K aerials', 'cool moody desaturated blues', 'subtle fog layers'],
      'whyMatches': 'Flawless landscape visual match: braided turquoise glacial streams, moody volcanic basalt, and expansive drone sweeps.',
      'baseScore': 98,
    },
    {
      'id': 'vm-d02',
      'platform': 'Vimeo',
      'title': 'Whispers of Fire and Ice: High Latitude Aerial Exploration',
      'creator': 'Arctic Expeditions Collective',
      'creatorAvatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
      'duration': '3:15',
      'views': '185K',
      'published': '2 weeks ago',
      'category': 'Travel & Nature',
      'topics': ['travel cinematography', 'drone photography', 'nordic landscapes'],
      'keywords': ['cinematic drone', 'nordic landscape', 'glacier river', 'black sand beach', 'iceland 4k aerial'],
      'visualStyle': ['anamorphic drone lens', 'cool cyan grading', 'ambient soundscape'],
      'whyMatches': 'Captures identical moody Scandinavian color palettes and soaring geological vistas.',
      'baseScore': 94,
    },
    {
      'id': 'ig-d03',
      'platform': 'Instagram',
      'title': 'Flying a sub-250g drone through the Reynisfjara Sea Stacks at sunrise',
      'creator': '@iceland.unreal',
      'creatorAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
      'duration': '0:38',
      'views': '920K',
      'published': '4 days ago',
      'category': 'Travel & Nature',
      'topics': ['travel cinematography', 'drone photography', 'short form travel'],
      'keywords': ['black sand beach', 'cinematic drone', 'iceland 4k aerial', 'nordic landscape'],
      'visualStyle': ['vertical 9:16 drone orbit', 'sunrise golden contrast on black sand', 'slow drift'],
      'whyMatches': 'Shares exact black volcanic coastline geography and atmospheric morning fog layer.',
      'baseScore': 91,
    },
  ];

  List<ReferenceVideoPreset> getPresets() => presets;

  ReferenceVideoPreset? getPresetById(String id) {
    try {
      return presets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // Analyzes a reference video (either preset or custom uploaded)
  Map<String, dynamic> analyzeVideo({
    String? presetId,
    String? customTitle,
    String? customDescription,
    List<String>? userKeywords,
  }) {
    ReferenceVideoPreset? preset;
    if (presetId != null) {
      preset = getPresetById(presetId);
    }

    if (preset != null) {
      final generatedQueries = [
        '${preset.topics.first} ${preset.defaultKeywords.first}',
        'best ${preset.defaultKeywords.sublist(0, min(2, preset.defaultKeywords.length)).join(' ')}',
        'cinematic ${preset.category.toLowerCase()} reel',
        'viral ${preset.topics.sublist(0, min(2, preset.topics.length)).join(' ')} 4K',
        'trending ${preset.defaultKeywords.last} short form',
      ];

      return {
        'id': preset.id,
        'title': preset.title,
        'category': preset.category,
        'duration': preset.duration,
        'thumbnailUrl': preset.thumbnailUrl,
        'videoUrl': preset.videoUrl,
        'description': preset.description,
        'topics': preset.topics,
        'objects': preset.objects,
        'visualStyle': preset.visualStyle,
        'pacing': preset.pacing,
        'mood': preset.mood,
        'extractedKeywords': preset.defaultKeywords,
        'generatedQueries': generatedQueries,
      };
    }

    // Dynamic analysis for custom uploaded videos or custom input
    final title = customTitle?.isNotEmpty == true ? customTitle! : 'Custom Reference Video';
    final desc = customDescription ?? '';
    final rawKeywords = userKeywords ?? [];

    // Derive topics from title/keywords
    final derivedTopics = <String>[];
    if (title.toLowerCase().contains('beauty') || rawKeywords.any((k) => k.contains('makeup') || k.contains('lipstick'))) {
      derivedTopics.addAll(['cosmetics', 'beauty showcase', 'macro demonstration', 'commercial aesthetics']);
    } else if (title.toLowerCase().contains('tech') || rawKeywords.any((k) => k.contains('phone') || k.contains('unboxing'))) {
      derivedTopics.addAll(['technology', 'unboxing experience', 'gadget review', 'industrial design']);
    } else if (title.toLowerCase().contains('fitness') || rawKeywords.any((k) => k.contains('workout') || k.contains('gym'))) {
      derivedTopics.addAll(['fitness & conditioning', 'athletic training', 'workout motivation', 'cross-training']);
    } else if (title.toLowerCase().contains('coffee') || rawKeywords.any((k) => k.contains('food') || k.contains('latte'))) {
      derivedTopics.addAll(['culinary craftsmanship', 'specialty coffee', 'latte art', 'sensory routine']);
    } else {
      derivedTopics.addAll(['digital media', 'cinematic production', 'creative storytelling', 'audience engagement']);
    }

    final extractedObjects = [
      'focal subject element',
      'ambient background environment',
      'directional studio lighting accents',
      'textured surface details',
    ];

    final extractedVisualStyle = [
      'balanced Rule-of-Thirds framing',
      'controlled color palette saturation',
      'dynamic subject motion',
      'crisp audio-visual synchronization',
    ];

    final generatedQueries = [
      if (rawKeywords.isNotEmpty) '${rawKeywords.first} viral trending',
      if (rawKeywords.length > 1) '${rawKeywords.take(2).join(' ')} showcase 4K',
      'best ${title.toLowerCase().replaceAll('custom reference video', 'cinematic')} format',
      'high engagement ${derivedTopics.first} short video',
      'top rated ${rawKeywords.isNotEmpty ? rawKeywords.last : 'creative'} content ideas',
    ];

    return {
      'id': 'custom-video-${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'category': derivedTopics.first,
      'duration': '0:45',
      'thumbnailUrl': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80',
      'videoUrl': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'description': desc.isNotEmpty ? desc : 'AI-analyzed custom uploaded reference video.',
      'topics': derivedTopics,
      'objects': extractedObjects,
      'visualStyle': extractedVisualStyle,
      'pacing': 'Dynamic modern rhythm (1.8s avg shot length)',
      'mood': 'High energy, crisp, engaging',
      'extractedKeywords': rawKeywords.isNotEmpty ? rawKeywords : ['creative video', 'cinematic', 'viral trend'],
      'generatedQueries': generatedQueries,
    };
  }

  // Searches and ranks videos across selected platforms
  Map<String, dynamic> search({
    required Map<String, dynamic> referenceContext,
    required List<String> keywords,
    required List<String> platforms,
    String? query,
    String? sortBy, // 'relevance', 'score', 'views', 'newest'
  }) {
    final effectivePlatforms = platforms.isEmpty
        ? ['YouTube', 'TikTok', 'Instagram', 'X / Twitter', 'Vimeo']
        : platforms;

    final targetTopics = (referenceContext['topics'] as List<dynamic>? ?? []).map((e) => e.toString().toLowerCase()).toSet();
    final targetKeywords = (keywords.isNotEmpty ? keywords : (referenceContext['extractedKeywords'] as List<dynamic>? ?? []))
        .map((e) => e.toString().toLowerCase())
        .toSet();

    final results = <Map<String, dynamic>>[];

    for (final item in _catalog) {
      final itemPlatform = item['platform'] as String;
      // Check platform filter
      final matchesPlatform = effectivePlatforms.any((p) {
        final pNorm = p.toLowerCase().replaceAll('/', '').replaceAll(' ', '');
        final iNorm = itemPlatform.toLowerCase().replaceAll('/', '').replaceAll(' ', '');
        return pNorm.contains(iNorm) || iNorm.contains(pNorm);
      });

      if (!matchesPlatform) continue;

      final itemTopics = (item['topics'] as List<dynamic>? ?? []).map((e) => e.toString().toLowerCase()).toSet();
      final itemKeywords = (item['keywords'] as List<dynamic>? ?? []).map((e) => e.toString().toLowerCase()).toSet();

      // Compute topic overlap
      final topicMatches = targetTopics.intersection(itemTopics);
      final topicScore = targetTopics.isEmpty ? 0.7 : (topicMatches.length / max(1, targetTopics.length));

      // Compute keyword overlap
      final keywordMatches = targetKeywords.intersection(itemKeywords);
      final keywordScore = targetKeywords.isEmpty ? 0.6 : (keywordMatches.length / max(1, targetKeywords.length));

      // Query bonus if query provided
      double queryBonus = 0.0;
      if (query != null && query.trim().isNotEmpty) {
        final qTerms = query.toLowerCase().split(' ');
        final title = (item['title'] as String).toLowerCase();
        for (final term in qTerms) {
          if (title.contains(term)) queryBonus += 0.05;
        }
      }

      // Base category match
      final refCat = (referenceContext['category']?.toString() ?? '').toLowerCase();
      final itemCat = (item['category']?.toString() ?? '').toLowerCase();
      final categoryBonus = (refCat.isNotEmpty && refCat == itemCat) ? 0.15 : 0.0;

      // Calculate composite AI match score (0 - 100)
      final base = (item['baseScore'] as num?)?.toDouble() ?? 80.0;
      double calculatedScore = (base * 0.4) + (topicScore * 30.0) + (keywordScore * 20.0) + (categoryBonus * 100.0) + (queryBonus * 100.0);
      calculatedScore = calculatedScore.clamp(62.0, 99.0);

      final matchedKwList = keywordMatches.toList();
      if (matchedKwList.isEmpty && itemKeywords.isNotEmpty) {
        matchedKwList.addAll(itemKeywords.take(2));
      }

      final resultItem = Map<String, dynamic>.from(item);
      resultItem['matchScore'] = calculatedScore.round();
      resultItem['matchedKeywords'] = matchedKwList;
      resultItem['topicMatchCount'] = topicMatches.length;

      results.add(resultItem);
    }

    // Sort results
    if (sortBy == 'views') {
      results.sort((a, b) => (b['views'] as String).compareTo(a['views'] as String));
    } else if (sortBy == 'newest') {
      results.sort((a, b) => (a['published'] as String).compareTo(b['published'] as String));
    } else {
      // Default: relevance / matchScore
      results.sort((a, b) => (b['matchScore'] as int).compareTo(a['matchScore'] as int));
    }

    return {
      'query': query ?? '',
      'total': results.length,
      'platforms': effectivePlatforms,
      'results': results,
    };
  }
}
