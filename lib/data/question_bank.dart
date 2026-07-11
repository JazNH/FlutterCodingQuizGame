import 'dart:math';

import '../models/question.dart';

class QuestionBank {
  QuestionBank({Random? random}) : _random = random ?? Random();

  final Random _random;

  late final List<Question> _easyPool = _buildEasyQuestions();
  late final List<Question> _mediumPool = _buildMediumQuestions();
  late final List<Question> _hardPool = _buildHardQuestions();

  final List<Question> _easyDeck = <Question>[];
  final List<Question> _mediumDeck = <Question>[];
  final List<Question> _hardDeck = <Question>[];

  Question nextForIndex(int questionNumber, int easyPhaseEnd, int mediumPhaseEnd) {
    if (questionNumber <= easyPhaseEnd) {
      return _popQuestion(_easyPool, _easyDeck);
    }
    if (questionNumber <= mediumPhaseEnd) {
      return _popQuestion(_mediumPool, _mediumDeck);
    }
    return _popQuestion(_hardPool, _hardDeck);
  }

  int randomEasyPhaseEnd() => _random.nextInt(24) + 7; // 7..30

  int randomMediumPhaseEnd(int easyPhaseEnd) {
    final min = max(60, easyPhaseEnd + 1);
    final maxValue = 62;
    if (min >= maxValue) {
      return min;
    }
    return min + _random.nextInt(maxValue - min + 1);
  }

  Question _popQuestion(List<Question> source, List<Question> deck) {
    if (deck.isEmpty) {
      deck.addAll(source);
      deck.shuffle(_random);
    }
    return deck.removeLast();
  }

  List<Question> _buildEasyQuestions() {
    return const <Question>[
      Question(
        prompt: 'Which keyword defines a function in Python?',
        options: ['func', 'def', 'function', 'lambda'],
        correctOptionIndexes: {1},
        difficulty: Difficulty.easy,
      ),
      Question(
        prompt: 'What is the output of print(type(5))?',
        options: ['<class int>', '<int>', 'int', '<class \"int\">'],
        correctOptionIndexes: {3},
        difficulty: Difficulty.easy,
      ),
      Question(
        prompt: 'Which symbol starts a comment in Python?',
        options: ['//', '#', '/*', '--'],
        correctOptionIndexes: {1},
        difficulty: Difficulty.easy,
      ),
      Question(
        prompt: 'Which collection is ordered and mutable?',
        options: ['set', 'tuple', 'list', 'frozenset'],
        correctOptionIndexes: {2},
        difficulty: Difficulty.easy,
      ),
      Question(
        prompt: 'How do you create an empty dictionary?',
        options: ['[]', '{}', '()', 'dict[]'],
        correctOptionIndexes: {1},
        difficulty: Difficulty.easy,
      ),
      Question(
        prompt: 'Which built-in gets the length of a string?',
        options: ['size()', 'count()', 'len()', 'length()'],
        correctOptionIndexes: {2},
        difficulty: Difficulty.easy,
      ),
      Question(
        prompt: 'What does bool(0) return?',
        options: ['True', 'False', '0', 'None'],
        correctOptionIndexes: {1},
        difficulty: Difficulty.easy,
      ),
      Question(
        prompt: 'Which operator checks equality?',
        options: ['=', '===', '==', '!='],
        correctOptionIndexes: {2},
        difficulty: Difficulty.easy,
      ),
      Question(
        prompt: 'Which function converts text to lowercase?',
        options: ['lower()', 'downcase()', 'small()', 'toLower()'],
        correctOptionIndexes: {0},
        difficulty: Difficulty.easy,
      ),
      Question(
        prompt: 'What is the result of 3 ** 2?',
        options: ['6', '9', '8', '5'],
        correctOptionIndexes: {1},
        difficulty: Difficulty.easy,
      ),
      Question(
        prompt: 'Which are valid Python variable names?',
        options: ['2cats', '_count', 'user-name', 'class'],
        correctOptionIndexes: {1},
        difficulty: Difficulty.easy,
      ),
      Question(
        prompt: 'Which method adds an item to the end of a list?',
        options: ['insert()', 'append()', 'push()', 'extendone()'],
        correctOptionIndexes: {1},
        difficulty: Difficulty.easy,
      ),
      Question(
        prompt: 'Which keyword is used for looping over items?',
        options: ['foreach', 'loop', 'for', 'iterate'],
        correctOptionIndexes: {2},
        difficulty: Difficulty.easy,
      ),
      Question(
        prompt: 'What does input() return?',
        options: ['int', 'str', 'bool', 'float'],
        correctOptionIndexes: {1},
        difficulty: Difficulty.easy,
      ),
      Question(
        prompt: 'Which statements are true about Python?',
        options: [
          'It is interpreted',
          'Indentation matters',
          'It requires semicolons every line',
          'It supports OOP'
        ],
        correctOptionIndexes: {0, 1, 3},
        difficulty: Difficulty.easy,
      ),
    ];
  }

  List<Question> _buildMediumQuestions() {
    return const <Question>[
      Question(
        prompt: 'What is the output of [x * 2 for x in range(3)]?',
        options: ['[2, 4, 6]', '[0, 2, 4]', '[1, 2, 3]', '[0, 1, 2]'],
        correctOptionIndexes: {1},
        difficulty: Difficulty.medium,
      ),
      Question(
        prompt: 'Which data type is immutable?',
        options: ['list', 'set', 'dict', 'tuple'],
        correctOptionIndexes: {3},
        difficulty: Difficulty.medium,
      ),
      Question(
        prompt: 'What does dict.get(key, default) return if key is missing?',
        options: ['KeyError', 'None only', 'default value', 'empty string'],
        correctOptionIndexes: {2},
        difficulty: Difficulty.medium,
      ),
      Question(
        prompt: 'Which keyword handles exceptions?',
        options: ['handle', 'catch', 'except', 'rescue'],
        correctOptionIndexes: {2},
        difficulty: Difficulty.medium,
      ),
      Question(
        prompt: 'What does enumerate(items) provide in a loop?',
        options: [
          'Only values',
          'Only indexes',
          'Index and value pairs',
          'Sorted values'
        ],
        correctOptionIndexes: {2},
        difficulty: Difficulty.medium,
      ),
      Question(
        prompt: 'Select valid ways to copy a list shallowly.',
        options: ['lst.copy()', 'list(lst)', 'copy.deepcopy(lst)', 'lst[:]'],
        correctOptionIndexes: {0, 1, 3},
        difficulty: Difficulty.medium,
      ),
      Question(
        prompt: 'What is the result of "-".join(["a", "b", "c"])?',
        options: ['abc', 'a-b-c', '[a,b,c]', 'a b c'],
        correctOptionIndexes: {1},
        difficulty: Difficulty.medium,
      ),
      Question(
        prompt: 'Which statement about sets is true?',
        options: [
          'They keep insertion order in all Python versions',
          'They allow duplicates',
          'They store unique elements',
          'They are indexable'
        ],
        correctOptionIndexes: {2},
        difficulty: Difficulty.medium,
      ),
      Question(
        prompt: 'What does the with statement help manage?',
        options: [
          'Manual memory allocation',
          'Context managers and cleanup',
          'Only loops',
          'Only recursion'
        ],
        correctOptionIndexes: {1},
        difficulty: Difficulty.medium,
      ),
      Question(
        prompt: 'Which operator checks object identity?',
        options: ['==', 'is', '===', 'equals'],
        correctOptionIndexes: {1},
        difficulty: Difficulty.medium,
      ),
      Question(
        prompt: 'Choose valid dictionary iteration patterns.',
        options: [
          'for k in d:',
          'for k, v in d.items():',
          'for v in d.values():',
          'for pair in d.pairs():'
        ],
        correctOptionIndexes: {0, 1, 2},
        difficulty: Difficulty.medium,
      ),
      Question(
        prompt: 'What is a lambda in Python?',
        options: [
          'A named class',
          'An anonymous function',
          'A loop type',
          'A package manager'
        ],
        correctOptionIndexes: {1},
        difficulty: Difficulty.medium,
      ),
      Question(
        prompt: 'Which method removes and returns a dict value by key?',
        options: ['pop()', 'remove()', 'discard()', 'delete()'],
        correctOptionIndexes: {0},
        difficulty: Difficulty.medium,
      ),
      Question(
        prompt: 'Which are valid f-string examples?',
        options: ['f"Score: {score}"', '"Score: {score}"', 'F"{name}"', 'f\'{x}\''],
        correctOptionIndexes: {0, 2, 3},
        difficulty: Difficulty.medium,
      ),
      Question(
        prompt: 'What does range(2, 8, 2) generate?',
        options: ['2,4,6', '2,3,4,5,6,7', '0,2,4,6', '2,4,6,8'],
        correctOptionIndexes: {0},
        difficulty: Difficulty.medium,
      ),
    ];
  }

  List<Question> _buildHardQuestions() {
    return const <Question>[
      Question(
        prompt: 'What does @decorator above a function do?',
        options: [
          'Imports a module',
          'Wraps/modifies function behavior',
          'Creates a thread',
          'Enables type checking only'
        ],
        correctOptionIndexes: {1},
        difficulty: Difficulty.hard,
      ),
      Question(
        prompt: 'Which statement about generators is true?',
        options: [
          'They store all values immediately',
          'They yield values lazily',
          'They are only for numbers',
          'They must return lists'
        ],
        correctOptionIndexes: {1},
        difficulty: Difficulty.hard,
      ),
      Question(
        prompt: 'Select valid magic methods in Python classes.',
        options: ['__init__', '__str__', '__len__', '__start__'],
        correctOptionIndexes: {0, 1, 2},
        difficulty: Difficulty.hard,
      ),
      Question(
        prompt: 'What is the purpose of __name__ == "__main__"?',
        options: [
          'Checks Python version',
          'Runs code only when file is executed directly',
          'Loads packages lazily',
          'Enables optimization mode'
        ],
        correctOptionIndexes: {1},
        difficulty: Difficulty.hard,
      ),
      Question(
        prompt: 'Which collections are from the collections module?',
        options: ['defaultdict', 'Counter', 'namedtuple', 'superdict'],
        correctOptionIndexes: {0, 1, 2},
        difficulty: Difficulty.hard,
      ),
      Question(
        prompt: 'What does functools.lru_cache primarily provide?',
        options: [
          'Thread pools',
          'Memoization of function calls',
          'Async scheduling',
          'Command-line parsing'
        ],
        correctOptionIndexes: {1},
        difficulty: Difficulty.hard,
      ),
      Question(
        prompt: 'Which statements about list vs tuple are correct?',
        options: [
          'Lists are mutable',
          'Tuples are hashable if elements are hashable',
          'Tuples are always faster in every operation',
          'Lists can change size'
        ],
        correctOptionIndexes: {0, 1, 3},
        difficulty: Difficulty.hard,
      ),
      Question(
        prompt: 'What does the walrus operator := allow?',
        options: [
          'Type casting',
          'Assignment inside expressions',
          'Creating decorators',
          'Bit shifting'
        ],
        correctOptionIndexes: {1},
        difficulty: Difficulty.hard,
      ),
      Question(
        prompt: 'Which are true about asyncio coroutines?',
        options: [
          'Defined with async def',
          'Awaited with await',
          'Always run on separate OS threads',
          'Can be scheduled by an event loop'
        ],
        correctOptionIndexes: {0, 1, 3},
        difficulty: Difficulty.hard,
      ),
      Question(
        prompt: 'What does __slots__ in a class help with?',
        options: [
          'Automatic testing',
          'Restricting attributes and reducing memory overhead',
          'Network communication',
          'Encryption'
        ],
        correctOptionIndexes: {1},
        difficulty: Difficulty.hard,
      ),
      Question(
        prompt: 'Select all valid context manager creation patterns.',
        options: [
          'Implement __enter__ and __exit__',
          'Use contextlib.contextmanager',
          'Subclass list only',
          'Use with statement consumers'
        ],
        correctOptionIndexes: {0, 1, 3},
        difficulty: Difficulty.hard,
      ),
      Question(
        prompt: 'What does typing.Optional[int] mean?',
        options: [
          'Exactly int only',
          'int or None',
          'A required integer',
          'A list of ints'
        ],
        correctOptionIndexes: {1},
        difficulty: Difficulty.hard,
      ),
      Question(
        prompt: 'Which module handles JSON serialization in stdlib?',
        options: ['pickle', 'marshal', 'json', 'serde'],
        correctOptionIndexes: {2},
        difficulty: Difficulty.hard,
      ),
      Question(
        prompt: 'What can cause mutable default argument bugs?',
        options: [
          'Defaults evaluated once at function definition time',
          'Defaults evaluated on every call',
          'Using immutable strings',
          'Using keyword-only args'
        ],
        correctOptionIndexes: {0},
        difficulty: Difficulty.hard,
      ),
      Question(
        prompt: 'Choose true statements about Python packaging.',
        options: [
          'pyproject.toml can define build metadata',
          'pip installs from PyPI by default',
          'setup.py is the only possible config file',
          'Virtual environments isolate dependencies'
        ],
        correctOptionIndexes: {0, 1, 3},
        difficulty: Difficulty.hard,
      ),
    ];
  }
}
