import 'package:cloud_firestore/cloud_firestore.dart';

class SubmissionModel {
  final String submissionId;
  final String quizId;
  final String userId;
  final String userName;
  final List<int> answers;
  final int score;
  final int totalQuestions;
  final int correctCount;
  final DateTime submittedAt;
  final int timeTakenSeconds; // NEW: how long it took
  final List<int> timePerQuestion; // NEW: seconds per question

  SubmissionModel({
    required this.submissionId,
    required this.quizId,
    required this.userId,
    required this.userName,
    required this.answers,
    required this.score,
    required this.totalQuestions,
    required this.correctCount,
    required this.submittedAt,
    this.timeTakenSeconds = 0,
    this.timePerQuestion = const [],
  });

  factory SubmissionModel.fromMap(Map<String, dynamic> map, String id) {
    return SubmissionModel(
      submissionId: id,
      quizId: map['quizId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      answers: List<int>.from(map['answers'] ?? []),
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      correctCount: map['correctCount'] ?? 0,
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeTakenSeconds: map['timeTakenSeconds'] ?? 0,
      timePerQuestion: List<int>.from(map['timePerQuestion'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'userId': userId,
      'userName': userName,
      'answers': answers,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'timeTakenSeconds': timeTakenSeconds,
      'timePerQuestion': timePerQuestion,
    };
  }

  double get percentage =>
      totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0;

  int get starCount {
    if (percentage >= 80) return 3;
    if (percentage >= 50) return 2;
    return 1;
  }

  String get timeTakenFormatted {
    final m = timeTakenSeconds ~/ 60;
    final s = timeTakenSeconds % 60;
    return m > 0 ? '${m}د ${s}ث' : '${s}ث';
  }
}
