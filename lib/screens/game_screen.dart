import 'package:flutter/material.dart';

import '../game/quiz_controller.dart';
import '../models/high_score.dart';
import '../services/storage_service.dart';
import '../widgets/bubbly_background.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.playerName});

  final String playerName;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _storage = StorageService();
  QuizController? _controller;
  bool _handledGameOver = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    final settings = await _storage.loadSettings();
    if (!mounted) {
      return;
    }

    final controller = QuizController(
      playerName: widget.playerName,
      settings: settings,
    );

    controller.addListener(_onStateUpdated);
    controller.start();

    setState(() {
      _controller = controller;
    });
  }

  void _onStateUpdated() {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    if (!controller.isGameOver || _handledGameOver) {
      setState(() {});
      return;
    }

    _handledGameOver = true;
    _saveScoreAndShowDialog(controller);
  }

  Future<void> _saveScoreAndShowDialog(QuizController controller) async {
    await _storage.addHighScore(
      HighScore(
        playerName: widget.playerName,
        score: controller.score,
        timestamp: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final reason = controller.gameOverReason;
        final title = reason == GameOverReason.completed
            ? 'You Cleared 100!'
            : 'Game Over';
        final details = switch (reason) {
          GameOverReason.timeout => 'Time is up.',
          GameOverReason.completed => 'Perfect endurance run.',
          _ => 'Wrong answer ended this round.',
        };

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title),
          content: Text(
            '$details\nScore: ${controller.score}\nGreat run, ${widget.playerName}!',
            style: const TextStyle(fontSize: 17),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Back To Menu'),
            ),
          ],
        );
      },
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onStateUpdated);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = controller.currentQuestion;
    final selected = controller.selectedOptions;
    final seconds = controller.remainingSeconds;
    final totalSeconds = controller.settings.secondsPerQuestion;
    final progress = (seconds / totalSeconds).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Player: ${widget.playerName}'),
      ),
      body: BubblyBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    _TopStats(
                      score: controller.score,
                      questionNumber: controller.questionNumber,
                      difficulty: controller.difficultyLabel,
                      seconds: seconds,
                      progress: progress,
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 240),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeIn,
                            child: Column(
                              key: ValueKey<int>(controller.questionNumber),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  question.displayPrompt,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(height: 1.25),
                                ),
                                const SizedBox(height: 26),
                                ...List.generate(question.options.length,
                                    (index) {
                                  final option = question.options[index];
                                  final isSelected = selected.contains(index);
                                  return _OptionTile(
                                    label: option,
                                    selected: isSelected,
                                    onTap: () => controller.toggleOption(index),
                                  );
                                }),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: selected.isEmpty
                                        ? null
                                        : () {
                                            controller.submitAnswer();
                                          },
                                    child: const Text('Submit Answer'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopStats extends StatelessWidget {
  const _TopStats({
    required this.score,
    required this.questionNumber,
    required this.difficulty,
    required this.seconds,
    required this.progress,
  });

  final int score;
  final int questionNumber;
  final String difficulty;
  final int seconds;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Q $questionNumber  •  $difficulty',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  'Score: $score',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.timer_rounded),
                const SizedBox(width: 8),
                Text('$seconds s'),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: const Color(0xFF0EA5E9),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected ? const Color(0xFF0EA5E9) : Colors.white,
            border: Border.all(
              color:
                  selected ? const Color(0xFF0369A1) : const Color(0xFFBFDBFE),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color(0xFF38BDF8).withOpacity(selected ? 0.28 : 0.1),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? Colors.white : const Color(0xFF0EA5E9),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
