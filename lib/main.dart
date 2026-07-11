import 'package:flutter/material.dart';

import 'screens/main_menu_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PythonQuizApp());
}

class PythonQuizApp extends StatelessWidget {
  const PythonQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Python Quiz Game',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const MainMenuScreen(),
    );
  }
}
