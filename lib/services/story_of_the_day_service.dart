import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
      final timestampStartOfWeek = Timestamp.fromDate(startOfWeek);

      // Get all active Raphcons from this week
      QuerySnapshot raphconsSnapshot;
      debugPrint('Fetching raphcons since $timestampStartOfWeek');
      // Build the query future first so we can attach an error handler
      final queryFuture = _firestore
          .collection('raphcons')
          .where('createdAt', isGreaterThanOrEqualTo: timestampStartOfWeek)
          .where('isActive', isEqualTo: true)
          .get();
      debugPrint('Query built, awaiting results...');
      // If the query times out, the underlying future may still complete
      // later with an error. Attach a catchError to ensure those later
      // errors are observed and won't bubble as unhandled exceptions.
      unawaited(queryFuture.catchError((e, st) {
        debugPrint('Query future completed with error: $e');
        debugPrint(
            'Suppressed later error from raphcons query after timeout: $e\n$st');
        return null;
      }));
      debugPrint('Awaiting query future...');
      try {
        // Use a short timeout to avoid hangs (especially on web). If a
        // timeout happens we throw and handle it explicitly below.
        debugPrint('Starting timeout wait for raphcons query...');
        raphconsSnapshot = await queryFuture.timeout(const Duration(seconds: 5),
            onTimeout: () {
          throw TimeoutException(
              'Timeout waiting for raphcons query (5s) — original future will be suppressed');
        });
        debugPrint('Fetched ${raphconsSnapshot.docs.length} raphcons');
      } on FirebaseException catch (e, st) {
        debugPrint(
            'FirebaseException beim Fetch: ${e.code} / ${e.message}\n$st');
        return _getDefaultStories();
      } on TimeoutException catch (e, st) {
        debugPrint('Timeout beim Firestore-get(): $e\n$st');
        return _getDefaultStories();
      } catch (e, st) {
        debugPrint(
            'Allg. Exception (${e.runtimeType}) beim Firestore-get(): $e\n$st');
        return _getDefaultStories();
      }
      debugPrint(
          'Fetched ${raphconsSnapshot.docs.length} raphcons since start of week');
      if (raphconsSnapshot.docs.isEmpty) {
        return _getDefaultStories();
      }
      debugPrint('Processing raphcon statistics...');
      // Count Raphcons by user and type
      final Map<String, Map<RaphconType, int>> userStats = {};
      final Map<String, int> totalByUser = {};

      for (var doc in raphconsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
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
          for (var typeEntry in userStats[userId]!.entries) {}
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
          final story =
              await _generateTopUserStory(user.initials, topUser.value);
          if (story != null) {
            storiesSet.add(story);
          }
        } else {}
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

      // If we couldn't derive any interesting stories but there are
      // raphcons, produce at least simple top-user stories (even for
      // single occurrences) so the UI doesn't fall back to generic
      // default texts when there is actual data.
      if (storiesSet.isEmpty && totalByUser.isNotEmpty) {
        // Sort users by number of raphcons
        final sortedTotals = totalByUser.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        const maxStories = 5;
        for (var i = 0;
            i < sortedTotals.length && storiesSet.length < maxStories;
            i++) {
          final userId = sortedTotals[i].key;
          final count = sortedTotals[i].value;
          final user = users.firstWhere((u) => u.id == userId,
              orElse: () => users.first);
          // Debug: indicate fallback generation
          debugPrint(
              'Fallback generating minimal story for ${user.initials} count=$count');
          final story =
              await _generateTopUserStory(user.initials, count, variation: i);
          if (story != null) {
            storiesSet.add(story);
          }
        }
      }

      // Convert Set to List and limit to max 5 stories
      final stories = storiesSet.toList();
      const maxStories = 5;
      final finalStories = stories.length > maxStories
          ? stories.sublist(0, maxStories)
          : stories;

      if (finalStories.isEmpty) {
        final defaultStories = _getDefaultStories().take(maxStories).toList();
        return defaultStories;
      }

      // Return limited stories for rotation
      for (int i = 0; i < finalStories.length; i++) {}

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
      try {
        // Protect against hanging AI calls on web with a short timeout
        final aiStory = await _geminiService
            .generateTopUserStory(
              userName: userName,
              count: count,
              variation: variation,
            )
            .timeout(const Duration(seconds: 3));

        if (aiStory != null && aiStory.isNotEmpty) {
          return aiStory;
        }
      } catch (e) {
        // Timeout or error: fall through to template fallback
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
      try {
        final aiStory = await _geminiService
            .generateStory(
              userName: userName,
              problemType: problemType,
              count: count,
              variation: variation,
            )
            .timeout(const Duration(seconds: 3));

        if (aiStory != null && aiStory.isNotEmpty) {
          return aiStory;
        }
      } catch (e) {
        // Timeout or error: fall back to templates
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
      case RaphconType.webcam:
        final webcamTemplates = [
          '📹 $userName und die Webcam: ${count}x Totalausfall diese Woche!',
          '🎥 $userName\'s Webcam streikt: ${count}x schwarzes Bild!',
          '📸 Kamera-Chaos bei $userName: ${count}x diese Woche!',
          '🎬 $userName unsichtbar: ${count}x Webcam-Fail!'
        ];
        return webcamTemplates[random.nextInt(webcamTemplates.length)];
      case RaphconType.otherPeripherals:
        final peripheralTemplates = [
          '🖱️ $userName kämpft mit Peripheriegeräten: ${count}x diese Woche!',
          '⌨️ Tech-Probleme bei $userName: ${count}x Geräte-Drama!',
          '🔌 $userName vs. Hardware: $count:0 für die Geräte!',
          '💻 Peripherie-Chaos bei $userName: ${count}x diese Woche!'
        ];
        return peripheralTemplates[random.nextInt(peripheralTemplates.length)];
      case RaphconType.mouseHighlighter:
        final highlighterTemplates = [
          '🖱️✨ $userName hat ${count}x den Mouse Highlighter vermisst!',
          '🔦 Wo ist der Cursor? $userName sucht ${count}x diese Woche!',
          '🎯 Mouse Highlighter AWOL bei $userName: ${count}x!',
          '💫 $userName\'s unsichtbarer Cursor: ${count}x verloren!'
        ];
        return highlighterTemplates[
            random.nextInt(highlighterTemplates.length)];
      case RaphconType.lateMeeting:
        final lateTemplates = [
          '⏰ $userName zu spät: ${count}x diese Woche verpasst!',
          '🕐 Zeit ist relativ für $userName: ${count}x zu spät!',
          '⌚ $userName und die Zeit: ${count}x Meeting verpasst!',
          '🏃 $userName rennt hinterher: ${count}x zu spät!'
        ];
        return lateTemplates[random.nextInt(lateTemplates.length)];
    }
  }

  String _getGermanTypeName(RaphconType type) {
    switch (type) {
      case RaphconType.headset:
        return 'Headset';
      case RaphconType.webcam:
        return 'Webcam';
      case RaphconType.otherPeripherals:
        return 'Andere Peripheriegeräte';
      case RaphconType.mouseHighlighter:
        return 'Mouse Highlighter';
      case RaphconType.lateMeeting:
        return 'Zu spät zum Meeting';
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
