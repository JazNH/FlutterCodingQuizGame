class HighScore {
  const HighScore({
    required this.playerName,
    required this.score,
    required this.timestamp,
  });

  final String playerName;
  final int score;
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'score': score,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HighScore.fromJson(Map<String, dynamic> json) {
    return HighScore(
      playerName: json['playerName'] as String? ?? 'Player',
      score: json['score'] as int? ?? 0,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
