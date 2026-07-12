import 'package:flutter/material.dart';

import '../game/quiz_controller.dart';
import '../models/high_score.dart';
import '../services/storage_service.dart';
import '../widgets/study_background.dart';

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
  bool _isShowingCorrectPopup = false;

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
    if (!mounted || controller == null) {
      return;
    }

    if (!controller.isGameOver) {
      setState(() {});
      return;
    }

    if (_handledGameOver) {
      return;
    }

    _handledGameOver = true;
    setState(() {});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _saveScoreAndShowDialog(controller);
    });
  }

  Future<void> _handleSubmit(QuizController controller) async {
    if (_isShowingCorrectPopup || controller.awaitingNextQuestion) {
      return;
    }

    final result = controller.submitAnswer();
    if (result != AnswerResult.correct) {
      return;
    }

    setState(() => _isShowingCorrectPopup = true);

    await showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Correct',
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.12),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) {
        return const Center(
          child: _CorrectPopup(),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
    );

    if (!mounted) {
      return;
    }

    setState(() => _isShowingCorrectPopup = false);
    controller.moveToNextQuestion();
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

    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final screenSize = MediaQuery.sizeOf(dialogContext);
        final wrongMascotHeight =
            (screenSize.height * 0.24).clamp(120.0, 220.0);
        final reason = controller.gameOverReason;
        final title = reason == GameOverReason.completed ? 'You Cleared 100!' : null;
        final details = switch (reason) {
          GameOverReason.timeout => 'Time is up.',
          GameOverReason.completed => 'Perfect endurance run.',
          _ => 'Wrong answer ended this round.',
        };
        final showWrongMascot = reason == GameOverReason.wrongAnswer;
        final correctAnswerText = showWrongMascot
            ? _buildCorrectAnswerText(controller.currentQuestion)
            : null;

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: title == null ? null : Text(title, textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showWrongMascot) ...[
                    Image.asset(
                      'assets/MascotNope.png',
                      height: wrongMascotHeight,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    '$details\nScore: ${controller.score}\nGreat run, ${widget.playerName}!',
                    style: const TextStyle(fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                  if (correctAnswerText != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Correct answer:\n$correctAnswerText',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop('play_again');
                      },
                      child: const Text('Play Again'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop('menu');
                      },
                      child: const Text('Back To Menu'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (action == 'play_again') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GameScreen(playerName: widget.playerName),
        ),
      );
      return;
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _buildCorrectAnswerText(question) {
    final indexes = question.correctOptionIndexes.toList()..sort();
    return indexes.map((index) => question.options[index]).join('\n');
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
    final screenSize = MediaQuery.sizeOf(context);
    final isCompactHeight = screenSize.height < 760;
    final topImageHeight = isCompactHeight ? 90.0 : 120.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Player: ${widget.playerName}'),
      ),
      body: StudyBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isCompactHeight ? 12 : 18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/Python.png',
                        height: topImageHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: isCompactHeight ? 10 : 14),
                    _TopStats(
                      score: controller.score,
                      questionNumber: controller.questionNumber,
                      answeredCount: controller.answeredCount,
                      difficulty: controller.difficultyLabel,
                      seconds: seconds,
                      progress: progress,
                    ),
                    SizedBox(height: isCompactHeight ? 10 : 14),
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
                                    onPressed: selected.isEmpty || controller.awaitingNextQuestion
                                        ? null
                                        : () => _handleSubmit(controller),
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
    required this.answeredCount,
    required this.difficulty,
    required this.seconds,
    required this.progress,
  });

  final int score;
  final int questionNumber;
  final int answeredCount;
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
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Answered: $answeredCount',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
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

class _CorrectPopup extends StatefulWidget {
  const _CorrectPopup();

  @override
  State<_CorrectPopup> createState() => _CorrectPopupState();
}

class _CorrectPopupState extends State<_CorrectPopup> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF22C55E), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2A000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: const Text(
          'Correct!',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Color(0xFF166534),
          ),
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
                    const Color(0xFF38BDF8).withValues(alpha: selected ? 0.28 : 0.1),
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
