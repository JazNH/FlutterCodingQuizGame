import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/high_score.dart';

class StorageService {
  static const _settingsKey = 'app_settings';
  static const _highScoresKey = 'high_scores';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      return AppSettings.defaults;
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return AppSettings.fromJson(decoded);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, encoded);
  }

  Future<List<HighScore>> loadHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_highScoresKey) ?? <String>[];

    final results = rawList
        .map((entry) {
          final decoded = jsonDecode(entry) as Map<String, dynamic>;
          return HighScore.fromJson(decoded);
        })
        .toList();

    results.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) {
        return scoreComparison;
      }
      return b.timestamp.compareTo(a.timestamp);
    });

    return results;
  }

  Future<void> addHighScore(HighScore score) async {
    final prefs = await SharedPreferences.getInstance();
    final scores = await loadHighScores();
    scores.add(score);
    scores.sort((a, b) {
      final scoreComparison = b.score.compareTo(a.score);
      if (scoreComparison != 0) {
        return scoreComparison;
      }
      return b.timestamp.compareTo(a.timestamp);
    });

    final encoded = scores.map((entry) => jsonEncode(entry.toJson())).toList();
    await prefs.setStringList(_highScoresKey, encoded);
  }
}
