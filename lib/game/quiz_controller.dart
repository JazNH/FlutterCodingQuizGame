import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/question_bank.dart';
import '../models/app_settings.dart';
import '../models/question.dart';

enum GameOverReason { wrongAnswer, timeout, completed }
enum AnswerResult { invalid, correct, wrong, completed }

class QuizController extends ChangeNotifier {
  QuizController({
    required this.playerName,
    required this.settings,
    QuestionBank? questionBank,
  }) : _questionBank = questionBank ?? QuestionBank();

  final String playerName;
  final AppSettings settings;
  final QuestionBank _questionBank;

  Timer? _timer;
  static const int maxQuestionNumber = 100;

  int _score = 0;
  int _questionNumber = 1;
  int _answeredCount = 0;
  int _remainingSeconds = 0;
  late final int _easyPhaseEnd;
  late final int _mediumPhaseEnd;
  bool _isGameOver = false;
  bool _awaitingNextQuestion = false;
  GameOverReason? _gameOverReason;

  Question? _currentQuestion;
  final Set<int> _selectedOptions = <int>{};

  int get score => _score;
  int get questionNumber => _questionNumber;
  int get answeredCount => _answeredCount;
  int get remainingSeconds => _remainingSeconds;
  bool get isGameOver => _isGameOver;
  bool get awaitingNextQuestion => _awaitingNextQuestion;
  GameOverReason? get gameOverReason => _gameOverReason;
  Question get currentQuestion => _currentQuestion!;
  Set<int> get selectedOptions => _selectedOptions;

  String get difficultyLabel {
    if (_questionNumber <= _easyPhaseEnd) {
      return 'Easy';
    }
    if (_questionNumber <= _mediumPhaseEnd) {
      return 'Medium';
    }
    return 'Hard';
  }

  void start() {
    _easyPhaseEnd = _questionBank.randomEasyPhaseEnd();
    _mediumPhaseEnd = _questionBank.randomMediumPhaseEnd(_easyPhaseEnd);
    _loadNextQuestion();
  }

  void toggleOption(int optionIndex) {
    if (_isGameOver || _awaitingNextQuestion) {
      return;
    }

    final question = _currentQuestion;
    if (question == null) {
      return;
    }

    if (!question.isMultiSelect) {
      _selectedOptions
        ..clear()
        ..add(optionIndex);
      notifyListeners();
      return;
    }

    if (_selectedOptions.contains(optionIndex)) {
      _selectedOptions.remove(optionIndex);
    } else {
      _selectedOptions.add(optionIndex);
    }
    notifyListeners();
  }

  AnswerResult submitAnswer() {
    if (_isGameOver || _currentQuestion == null || _selectedOptions.isEmpty) {
      return AnswerResult.invalid;
    }

    _answeredCount += 1;

    final isCorrect = setEquals(
      _selectedOptions,
      _currentQuestion!.correctOptionIndexes,
    );

    if (!isCorrect) {
      _endGame(GameOverReason.wrongAnswer);
      return AnswerResult.wrong;
    }

    _score += 1;
    if (_questionNumber >= maxQuestionNumber) {
      _endGame(GameOverReason.completed);
      return AnswerResult.completed;
    }

    _awaitingNextQuestion = true;
    _timer?.cancel();
    notifyListeners();
    return AnswerResult.correct;
  }

  void moveToNextQuestion() {
    if (_isGameOver || !_awaitingNextQuestion) {
      return;
    }
    _awaitingNextQuestion = false;
    _questionNumber += 1;
    _loadNextQuestion();
  }

  void _loadNextQuestion() {
    _selectedOptions.clear();
    _currentQuestion = _questionBank.nextForIndex(
      _questionNumber,
      _easyPhaseEnd,
      _mediumPhaseEnd,
    );
    _restartTimer();
    notifyListeners();
  }

  void _restartTimer() {
    _timer?.cancel();
    _remainingSeconds = settings.secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _remainingSeconds = 0;
        _endGame(GameOverReason.timeout);
        return;
      }
      _remainingSeconds -= 1;
      notifyListeners();
    });
  }

  void _endGame(GameOverReason reason) {
    _timer?.cancel();
    _isGameOver = true;
    _gameOverReason = reason;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
