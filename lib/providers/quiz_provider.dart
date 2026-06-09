import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../services/quiz_service.dart';

class QuizProvider extends ChangeNotifier {
  final QuizService _quizService = QuizService();

  QuizModel? _currentQuiz;
  int _currentQuestionIndex = 0;
  List<int> _selectedAnswers = [];
  bool _isLoading = false;
  String? _error;

  // Timer tracking
  DateTime? _questionStartTime;
  DateTime? _quizStartTime;
  List<int> _timePerQuestion = [];

  // Answer reveal (show correct after selecting)
  bool _answerRevealed = false;
  bool get answerRevealed => _answerRevealed;

  QuizModel? get currentQuiz => _currentQuiz;
  int get currentQuestionIndex => _currentQuestionIndex;
  List<int> get selectedAnswers => _selectedAnswers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<int> get timePerQuestion => _timePerQuestion;

  QuestionModel? get currentQuestion {
    if (_currentQuiz == null) return null;
    if (_currentQuestionIndex >= _currentQuiz!.questions.length) return null;
    return _currentQuiz!.questions[_currentQuestionIndex];
  }

  bool get isLastQuestion {
    if (_currentQuiz == null) return false;
    return _currentQuestionIndex >= _currentQuiz!.questions.length - 1;
  }

  int? get currentSelectedAnswer {
    if (_currentQuestionIndex < _selectedAnswers.length) {
      final v = _selectedAnswers[_currentQuestionIndex];
      return v == -1 ? null : v;
    }
    return null;
  }

  double get progress {
    if (_currentQuiz == null || _currentQuiz!.questions.isEmpty) return 0;
    return (_currentQuestionIndex + 1) / _currentQuiz!.questions.length;
  }

  int get totalTimeTaken {
    if (_quizStartTime == null) return 0;
    return DateTime.now().difference(_quizStartTime!).inSeconds;
  }

  void startQuiz(QuizModel quiz) {
    _currentQuiz = quiz;
    _currentQuestionIndex = 0;
    _selectedAnswers = List.filled(quiz.questions.length, -1);
    _timePerQuestion = List.filled(quiz.questions.length, 0);
    _quizStartTime = DateTime.now();
    _questionStartTime = DateTime.now();
    _answerRevealed = false;
    notifyListeners();
  }

  void selectAnswer(int answerIndex) {
    if (_currentQuestionIndex >= _selectedAnswers.length) return;
    // Only allow selecting if not yet answered
    if (_selectedAnswers[_currentQuestionIndex] != -1) return;

    // Record time taken for this question
    if (_questionStartTime != null) {
      _timePerQuestion[_currentQuestionIndex] =
          DateTime.now().difference(_questionStartTime!).inSeconds;
    }

    _selectedAnswers[_currentQuestionIndex] = answerIndex;

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Reveal answer if quiz has showCorrectAnswer enabled
    if (_currentQuiz?.showCorrectAnswer == true) {
      _answerRevealed = true;
    }

    notifyListeners();
  }

  void nextQuestion() {
    if (!isLastQuestion) {
      _answerRevealed = false;
      _currentQuestionIndex++;
      _questionStartTime = DateTime.now();
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _answerRevealed = _selectedAnswers[_currentQuestionIndex - 1] != -1;
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  Future<QuizModel?> findQuizByCode(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      return await _quizService.getQuizByRoomCode(code);
    } catch (e) {
      _error = 'حدث خطأ في البحث';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetQuiz() {
    _currentQuiz = null;
    _currentQuestionIndex = 0;
    _selectedAnswers = [];
    _timePerQuestion = [];
    _quizStartTime = null;
    _questionStartTime = null;
    _answerRevealed = false;
    notifyListeners();
  }
}
