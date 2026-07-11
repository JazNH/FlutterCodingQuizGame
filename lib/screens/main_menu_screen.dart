import 'package:flutter/material.dart';

import 'game_screen.dart';
import 'high_scores_screen.dart';
import 'settings_screen.dart';
import '../widgets/bubbly_background.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  Future<void> _startGame(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final playerName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Player Name'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name.';
                }
                if (value.trim().length < 2) {
                  return 'Use at least 2 characters.';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!context.mounted || playerName == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(playerName: playerName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: BubblyBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Python Quiz Pop', style: textTheme.headlineMedium),
                    const SizedBox(height: 14),
                    Text(
                      'Sharpen your Python 3 skills and climb the leaderboard.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 42),
                    _MenuButton(
                      label: 'Play',
                      onPressed: () => _startGame(context),
                    ),
                    const SizedBox(height: 14),
                    _MenuButton(
                      label: 'Settings',
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
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
