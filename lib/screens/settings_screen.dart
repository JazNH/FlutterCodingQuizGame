import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../widgets/bubbly_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = StorageService();

  AppSettings? _settings;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loaded = await _storage.loadSettings();
    if (!mounted) {
      return;
    }
    setState(() => _settings = loaded);
  }

  Future<void> _onStyleChanged(PlayStyle style) async {
    if (_settings == null) {
      return;
    }

    setState(() {
      _saving = true;
      _settings = _settings!.copyWith(playStyle: style);
    });

    await _storage.saveSettings(_settings!);

    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BubblyBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: settings == null
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Play Style',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Quick mode is 30 seconds per question. Study mode is 60 seconds per question.',
                              ),
                              const SizedBox(height: 18),
                              SegmentedButton<PlayStyle>(
                                segments: const [
                                  ButtonSegment<PlayStyle>(
                                    value: PlayStyle.quick,
                                    label: Text('Quick (30s)'),
                                  ),
                                  ButtonSegment<PlayStyle>(
                                    value: PlayStyle.study,
                                    label: Text('Study (60s)'),
                                  ),
                                ],
                                selected: {settings.playStyle},
                                onSelectionChanged: (selection) {
                                  _onStyleChanged(selection.first);
                                },
                              ),
                              if (_saving) ...[
                                const SizedBox(height: 16),
                                const LinearProgressIndicator(minHeight: 3),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
