import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'game_screen.dart';
import 'high_scores_screen.dart';
import 'settings_screen.dart';
import '../widgets/study_background.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool _isStartingGame = false;

  Future<void> _startGame() async {
    if (_isStartingGame) {
      return;
    }

    setState(() => _isStartingGame = true);

    final controller = TextEditingController();
    String? validationError;

    try {
      final playerName = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                title: const Text('Player Name'),
                content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    border: const OutlineInputBorder(),
                    errorText: validationError,
                  ),
                  onSubmitted: (_) {
                    final trimmed = controller.text.trim();
                    if (trimmed.isEmpty) {
                      setDialogState(() => validationError = 'Please enter a name.');
                      return;
                    }
                    if (trimmed.length < 2) {
                      setDialogState(() => validationError = 'Use at least 2 characters.');
                      return;
                    }
                    Navigator.of(dialogContext).pop(trimmed);
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final trimmed = controller.text.trim();
                      if (trimmed.isEmpty) {
                        setDialogState(() => validationError = 'Please enter a name.');
                        return;
                      }
                      if (trimmed.length < 2) {
                        setDialogState(() => validationError = 'Use at least 2 characters.');
                        return;
                      }
                      Navigator.of(dialogContext).pop(trimmed);
                    },
                    child: const Text('Start'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (!mounted || playerName == null) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GameScreen(playerName: playerName),
        ),
      );
    } finally {
      controller.dispose();
      if (mounted) {
        setState(() => _isStartingGame = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.breeSerif(
      fontSize: 42,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF1F2937),
      height: 1.0,
    );
    final subtitleStyle = GoogleFonts.nunito(
      fontSize: 19,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF334155),
      height: 1.25,
    );

    return Scaffold(
      body: StudyBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompactHeight = constraints.maxHeight < 760;
              final mascotHeight =
                  (constraints.maxHeight * 0.38).clamp(220.0, 420.0);

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/Mascot.png',
                            height: mascotHeight,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          Text('Python Quiz Pop', style: titleStyle),
                          SizedBox(height: isCompactHeight ? 10 : 14),
                          Text(
                            'Sharpen your Python 3 skills and climb the leaderboard!',
                            textAlign: TextAlign.center,
                            style: subtitleStyle,
                          ),
                          SizedBox(height: isCompactHeight ? 24 : 42),
                          _MenuButton(
                            label: 'Play',
                            subtitle: 'Start a fresh coding challenge',
                            icon: Icons.play_circle_fill_rounded,
                            onPressed: _isStartingGame ? null : _startGame,
                          ),
                          const SizedBox(height: 14),
                          _MenuButton(
                            label: 'Settings',
                            subtitle: 'Tweak your study pace',
                            icon: Icons.tune_rounded,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          _MenuButton(
                            label: 'High Scores',
                            subtitle: 'See the leaderboard',
                            icon: Icons.leaderboard_rounded,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const HighScoresScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: disabled
                    ? [
                        const Color(0xFFE5E7EB).withValues(alpha: 0.75),
                        const Color(0xFFD1D5DB).withValues(alpha: 0.75),
                      ]
                    : [
                        const Color(0xFFFFFFFF).withValues(alpha: 0.92),
                        const Color(0xFFE0F2FE).withValues(alpha: 0.92),
                      ],
              ),
              border: Border.all(
                color: disabled
                    ? const Color(0xFF9CA3AF).withValues(alpha: 0.35)
                    : const Color(0xFF0284C7).withValues(alpha: 0.42),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A)
                      .withValues(alpha: disabled ? 0.06 : 0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: disabled
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF0369A1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: const Color(0xFF475569)
                      .withValues(alpha: disabled ? 0.6 : 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
