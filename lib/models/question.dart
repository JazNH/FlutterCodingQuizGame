enum Difficulty { easy, medium, hard }

class Question {
  const Question({
    required this.prompt,
    required this.options,
    required this.correctOptionIndexes,
    required this.difficulty,
  });

  final String prompt;
  final List<String> options;
  final Set<int> correctOptionIndexes;
  final Difficulty difficulty;

  bool get isMultiSelect => correctOptionIndexes.length > 1;

  String get displayPrompt {
    if (!isMultiSelect) {
      return prompt;
    }
    return '$prompt (Select all ${correctOptionIndexes.length} correct answers)';
  }
}
