import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums/raphcon_type.dart';
import '../features/user/domain/entities/user.dart';
import 'gemini_ai_service.dart';

/// Service to generate funny "Story of the Day" based on weekly Raphcon statistics
/// Uses Gemini AI when available, falls back to templates
class StoryOfTheDayService {
  final FirebaseFirestore _firestore;
  final GeminiAIService _geminiService;

  StoryOfTheDayService(this._firestore, {String? geminiApiKey})
      : _geminiService = GeminiAIService(geminiApiKey);

  /// Get multiple stories of the week based on this week's Raphcon data
  Future<List<String>> getWeeklyStories(List<User> users) async {
    try {
      // Get the start of the current week (Monday at midnight)
      final now = DateTime.now();
      final daysFromMonday = now.weekday - 1; // Monday = 0, Sunday = 6
      final startOfWeek = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: daysFromMonday));

      // Get all active Raphcons from this week
      final raphconsSnapshot = await _firestore
          .collection('raphcons')
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .where('isActive', isEqualTo: true)
          .get();


      if (raphconsSnapshot.docs.isEmpty) {
        return _getDefaultStories();
      }

      // Count Raphcons by user and type
      final Map<String, Map<RaphconType, int>> userStats = {};
      final Map<String, int> totalByUser = {};

      for (var doc in raphconsSnapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String;
        final typeString = data['type'] as String? ?? 'other';
        final type = RaphconType.fromString(typeString);
        (data['createdAt'] as Timestamp).toDate();


        userStats.putIfAbsent(userId, () => {});
        userStats[userId]![type] = (userStats[userId]![type] ?? 0) + 1;
        totalByUser[userId] = (totalByUser[userId] ?? 0) + 1;
      }

      for (var entry in totalByUser.entries) {
        final userId = entry.key;

        if (userStats[userId] != null) {
          // ignore: unused_local_variable
          for (var typeEntry in userStats[userId]!.entries) {
          }
        }
      }

      // Find interesting stats
      final storiesSet = <String>{}; // Use Set to avoid duplicates

      // Find user with most raphcons this week
      if (totalByUser.isNotEmpty) {
        final topUser =
            totalByUser.entries.reduce((a, b) => a.value > b.value ? a : b);
        final user = users.firstWhere((u) => u.id == topUser.key,
            orElse: () => users.first);

        if (topUser.value >= 3) {
          final story = await _generateTopUserStory(
              user.initials, topUser.value,
              variation: 0);
          if (story != null) {
            storiesSet.add(story);
          }
        } else {
        }
      }

      // Find users with specific type issues (limit to most interesting ones)
      var typeStoriesAdded = 0;
      var variationCounter = 0;

      // Sort users by total raphcons for better variety
      final sortedEntries = userStats.entries.toList()
        ..sort((a, b) => totalByUser[b.key]!.compareTo(totalByUser[a.key]!));

      for (var entry in sortedEntries) {
        if (typeStoriesAdded >= 4) break; // Max 4 type stories

        final userId = entry.key;
        final user =
            users.firstWhere((u) => u.id == userId, orElse: () => users.first);

        // Find the most problematic type for this user
        final topTypeEntry = entry.value.entries
            .where((typeEntry) => typeEntry.value >= 2)
            .fold<MapEntry<RaphconType, int>?>(
                null,
                (prev, curr) =>
                    prev == null || curr.value > prev.value ? curr : prev);

        if (topTypeEntry != null && typeStoriesAdded < 4) {
          final story = await _generateTypeStory(
              user.initials, topTypeEntry.key, topTypeEntry.value,
              variation: variationCounter);
          if (story != null && !storiesSet.contains(story)) {
            storiesSet.add(story);
            typeStoriesAdded++;
            variationCounter++;
          }
        }
      }

      // Convert Set to List and limit to max 5 stories
      final stories = storiesSet.toList();
      final maxStories = 5;
      final finalStories = stories.length > maxStories
          ? stories.sublist(0, maxStories)
          : stories;


      if (finalStories.isEmpty) {
        final defaultStories = _getDefaultStories().take(maxStories).toList();
        return defaultStories;
      }

      // Return limited stories for rotation
      for (int i = 0; i < finalStories.length; i++) {
      }

      return finalStories;
    } catch (e) {
      final defaultStories = _getDefaultStories().take(5).toList();
      return defaultStories;
    }
  }

  Future<String?> _generateTopUserStory(String userName, int count,
      {int variation = 0}) async {
    // Try Gemini AI first
    if (_geminiService.isAvailable) {
      final aiStory = await _geminiService.generateTopUserStory(
        userName: userName,
        count: count,
        variation: variation,
      );
      if (aiStory != null && aiStory.isNotEmpty) {
        return aiStory;
      }
    }

    // More diverse fallback templates
    final now = DateTime.now();
    final random =
        Random(now.millisecond + variation + userName.hashCode + count);

    final allTemplates = [
      '🎯 $userName führt diese Woche mit $count Raphcons! Technik ist nicht für jeden...',
      '🏆 Raphcon-Champion: $userName mit $count Sammelstücken diese Woche!',
      '📊 $userName sammelt Raphcons wie andere Briefmarken: $count diese Woche!',
      '⚡ Tech-Magnet $userName zieht Probleme an: $count Raphcons!',
      '🎪 $userName in der Raphcon-Arena: $count Treffer diese Woche!',
      '💥 Raphcon-Rekord! $userName schafft $count Stück in einer Woche!',
      '🚀 $userName auf Raphcon-Mission: $count erfolgreich gesammelt!',
      '🎭 Drama, Baby! $userName mit $count Raphcons diese Woche.',
      '⭐ $userName brilliert mit $count Raphcons. Welch ein Talent!',
      '🔥 Hot Streak! $userName knackt $count Raphcons diese Woche!'
    ];

    return allTemplates[random.nextInt(allTemplates.length)];
  }

  Future<String?> _generateTypeStory(
      String userName, RaphconType type, int count,
      {int variation = 0}) async {
    // Try Gemini AI first with variation
    if (_geminiService.isAvailable) {
      final problemType = _getGermanTypeName(type);
      final aiStory = await _geminiService.generateStory(
        userName: userName,
        problemType: problemType,
        count: count,
        variation: variation,
      );
      if (aiStory != null && aiStory.isNotEmpty) {
        return aiStory;
      }
    }

    // Fallback to varied templates
    final now = DateTime.now();
    final random = Random(now.millisecond + variation + userName.hashCode);

    switch (type) {
      case RaphconType.headset:
        final headsetTemplates = [
          '🎧 $userName hat den Krieg ${count}x gegen sein Headset verloren diese Woche!',
          '🎵 $userName vs. Headset: $count:0 für das Headset diese Woche!',
          '🔊 $userName\'s Kopfhörer haben ${count}x rebelliert diese Woche!',
          '🎧 Headset-Drama bei $userName: ${count}x Totalausfall diese Woche!'
        ];
        return headsetTemplates[random.nextInt(headsetTemplates.length)];
      case RaphconType.microphone:
        final micTemplates = [
          '🎤 $userName und das Mikrofon: Eine Geschichte von $count Missverständnissen diese Woche.',
          '🎙️ $userName\'s Mikrofon ist ${count}x stumm geblieben diese Woche!',
          '🔇 Mikrofon-Chaos bei $userName: ${count}x diese Woche!',
          '🎤 $userName redet gegen eine Wand: ${count}x Mikrofon-Fail!'
        ];
        return micTemplates[random.nextInt(micTemplates.length)];
      case RaphconType.software:
        final softwareTemplates = [
          '💻 $userName hat seine Software nicht im Griff, diese Woche sogar ${count}x!',
          '🐛 Software-Bugs jagen $userName: ${count}x diese Woche erwischt!',
          '💾 $userName vs. Programme: $count:0 für die Software!',
          '⚡ $userName\'s Software crasht ${count}x diese Woche. Neustart?'
        ];
        return softwareTemplates[random.nextInt(softwareTemplates.length)];
      default:
        final genericTemplates = [
          '❓ $userName hatte ${count}x mysteriöse Tech-Probleme diese Woche...',
          '🔧 Tech-Gremlins verfolgen $userName: ${count}x diese Woche!',
          '⚙️ $userName kämpft gegen die Maschinen: ${count}x verloren!',
          '🤖 Die Technik hasst $userName: ${count}x Beweis diese Woche!'
        ];
        return genericTemplates[random.nextInt(genericTemplates.length)];
    }
  }

  String _getGermanTypeName(RaphconType type) {
    switch (type) {
      case RaphconType.headset:
        return 'Headset';
      case RaphconType.microphone:
        return 'Mikrofon';
      case RaphconType.keyboard:
        return 'Tastatur';
      case RaphconType.mouse:
        return 'Maus';
      case RaphconType.webcam:
        return 'Webcam';
      case RaphconType.network:
        return 'Netzwerk/Internet';
      case RaphconType.software:
        return 'Software';
      case RaphconType.hardware:
        return 'Hardware';
      case RaphconType.speakers:
        return 'Lautsprecher';
      default:
        return 'Technik';
    }
  }

  List<String> _getDefaultStories() {
    return [
      '🎉 Neue Woche, neue Raphcons! Wer wird diese Woche die meisten sammeln?',
      '🚀 Die Raphcon-Jagd ist eröffnet! Welche Technik-Pannen erwarten uns?',
      '📱 Noch keine Tech-Probleme diese Woche? Das kann sich noch ändern!',
      '⚙️ Die Technik ist launisch heute... Viel Glück, alle zusammen!',
      '🎲 Raphcon-Roulette: Wer trifft es diese Woche als Erstes?',
      '💻 Die Server laufen, die Tastaturen klappern, die Raphcons warten...',
      '🎯 Wer wird heute der glückliche Raphcon-Gewinner? Die Wetten laufen!',
      '⚡ Technik-Chaos vorprogrammiert! Die Woche fängt gut an.',
    ];
  }
}
