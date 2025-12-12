import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/enums/raphcon_type.dart';
import '../features/user/domain/entities/user.dart';

/// Service to generate funny "Story of the Day" based on weekly Raphcon statistics
class StoryOfTheDayService {
  final FirebaseFirestore _firestore;
  
  StoryOfTheDayService(this._firestore);

  /// Get the story of the day based on this week's Raphcon data
  Future<String> getWeeklyStory(List<User> users) async {
    try {
      // Get the start of the current week (Monday)
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1, hours: now.hour, minutes: now.minute, seconds: now.second));
      
      // Get all Raphcons from this week
      final raphconsSnapshot = await _firestore
          .collection('raphcons')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .where('isActive', isEqualTo: true)
          .get();

      if (raphconsSnapshot.docs.isEmpty) {
        return _getDefaultStory();
      }

      // Count Raphcons by user and type
      final Map<String, Map<RaphconType, int>> userStats = {};
      final Map<String, int> totalByUser = {};

      for (var doc in raphconsSnapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String;
        final typeString = data['type'] as String? ?? 'other';
        final type = RaphconType.fromString(typeString);

        userStats.putIfAbsent(userId, () => {});
        userStats[userId]![type] = (userStats[userId]![type] ?? 0) + 1;
        totalByUser[userId] = (totalByUser[userId] ?? 0) + 1;
      }

      // Find interesting stats
      final stories = <String>[];

      // Find user with most raphcons this week
      if (totalByUser.isNotEmpty) {
        final topUser = totalByUser.entries.reduce((a, b) => a.value > b.value ? a : b);
        final user = users.firstWhere((u) => u.id == topUser.key, orElse: () => users.first);
        if (topUser.value >= 3) {
          stories.add(_generateTopUserStory(user.initials, topUser.value));
        }
      }

      // Find user with most specific type issues
      for (var entry in userStats.entries) {
        final userId = entry.key;
        final user = users.firstWhere((u) => u.id == userId, orElse: () => users.first);
        
        for (var typeEntry in entry.value.entries) {
          if (typeEntry.value >= 2) {
            stories.add(_generateTypeStory(user.initials, typeEntry.key, typeEntry.value));
          }
        }
      }

      if (stories.isEmpty) {
        return _getDefaultStory();
      }

      // Return a random story from the available ones
      final random = Random(now.day + now.weekday); // Same story for the same day
      return stories[random.nextInt(stories.length)];
    } catch (e) {
      return _getDefaultStory();
    }
  }

  String _generateTopUserStory(String userName, int count) {
    final stories = [
      '🎯 $userName führt diese Woche mit $count Raphcons! Technik ist nicht für jeden...',
      '🏆 Rekordhalter der Woche: $userName mit $count Raphcons. Glückwunsch? 🤔',
      '📊 $userName hat $count Raphcons gesammelt diese Woche. Zeit für ein IT-Training?',
      '⚡ $userName dominiert mit $count Raphcons! Die Technik-Nemesis schlägt wieder zu.',
    ];
    return stories[Random().nextInt(stories.length)];
  }

  String _generateTypeStory(String userName, RaphconType type, int count) {
    switch (type) {
      case RaphconType.headset:
        return '🎧 $userName hat den Krieg ${count}x gegen sein Headset verloren diese Woche!';
      case RaphconType.microphone:
        return '🎤 $userName und das Mikrofon: Eine Geschichte von $count Missverständnissen diese Woche.';
      case RaphconType.keyboard:
        return '⌨️ $userName hat seine Tastatur nicht im Griff - ${count}x diese Woche!';
      case RaphconType.mouse:
        return '🖱️ Die Maus von $userName streikt schon wieder... ${count}x diese Woche!';
      case RaphconType.webcam:
        return '📹 $userName kämpft mit der Webcam: $count Runden verloren diese Woche.';
      case RaphconType.network:
        return '🌐 $userName\'s Internet macht wieder Probleme - ${count}x diese Woche!';
      case RaphconType.software:
        return '💻 $userName hat seine Software nicht im Griff, diese Woche sogar ${count}x!';
      case RaphconType.hardware:
        return '🔧 Hardware vs. $userName: $count zu 0 für die Hardware diese Woche.';
      case RaphconType.speakers:
        return '🔊 $userName\'s Lautsprecher streiken ${count}x diese Woche. Stille Nacht?';
      default:
        return '❓ $userName hatte ${count}x mysteriöse Tech-Probleme diese Woche...';
    }
  }

  String _getDefaultStory() {
    final now = DateTime.now();
    final stories = [
      '🎉 Neue Woche, neue Raphcons! Wer wird diese Woche die meisten sammeln?',
      '🚀 Die Raphcon-Jagd ist eröffnet! Welche Technik-Pannen erwarten uns?',
      '📱 Noch keine Tech-Probleme diese Woche? Das kann sich noch ändern!',
      '⚙️ Die Technik ist launisch heute... Viel Glück, alle zusammen!',
      '🎲 Raphcon-Roulette: Wer trifft es diese Woche als Erstes?',
    ];
    return stories[now.day % stories.length];
  }
}
