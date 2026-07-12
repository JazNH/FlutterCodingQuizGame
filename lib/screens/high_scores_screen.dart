import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/high_score.dart';
import '../services/storage_service.dart';
import '../widgets/study_background.dart';

class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({super.key});

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen> {
  final _storage = StorageService();
  final _dateFormat = DateFormat('MMM d, y • h:mm a');

  List<HighScore>? _scores;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await _storage.loadHighScores();
    if (!mounted) {
      return;
    }
    setState(() => _scores = loaded);
  }

  @override
  Widget build(BuildContext context) {
    final scores = _scores;

    return Scaffold(
      appBar: AppBar(title: const Text('High Scores')),
      body: StudyBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: scores == null
                ? const Center(child: CircularProgressIndicator())
                : scores.isEmpty
                    ? const Center(child: Text('No scores yet. Play a game!'))
                    : ListView.separated(
                        itemCount: scores.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final score = scores[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF7DD3FC),
                                child: Text('#${index + 1}'),
                              ),
                              title: Text(
                                score.playerName,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text(_dateFormat.format(score.timestamp)),
                              trailing: Text(
                                '${score.score}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}
