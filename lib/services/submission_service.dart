import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/submission_model.dart';
import '../models/question_model.dart';

class SubmissionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  int calculateScore(List<int> answers, List<QuestionModel> questions) {
    if (questions.isEmpty) return 0;
    int correct = 0;
    for (int i = 0; i < answers.length && i < questions.length; i++) {
      if (answers[i] == questions[i].correctAnswer) correct++;
    }
    return (correct * (1000 / questions.length)).round();
  }

  int calculateCorrectCount(List<int> answers, List<QuestionModel> questions) {
    int correct = 0;
    for (int i = 0; i < answers.length && i < questions.length; i++) {
      if (answers[i] == questions[i].correctAnswer) correct++;
    }
    return correct;
  }

  Future<SubmissionModel> submitAnswers({
    required String quizId,
    required String userId,
    required String userName,
    required List<int> answers,
    required List<QuestionModel> questions,
    int timeTakenSeconds = 0,
    List<int> timePerQuestion = const [],
  }) async {
    final score = calculateScore(answers, questions);
    final correctCount = calculateCorrectCount(answers, questions);

    final submission = SubmissionModel(
      submissionId: '',
      quizId: quizId,
      userId: userId,
      userName: userName,
      answers: answers,
      score: score,
      totalQuestions: questions.length,
      correctCount: correctCount,
      submittedAt: DateTime.now(),
      timeTakenSeconds: timeTakenSeconds,
      timePerQuestion: timePerQuestion,
    );

    final doc = await _db.collection('submissions').add(submission.toMap());

    return SubmissionModel(
      submissionId: doc.id,
      quizId: quizId,
      userId: userId,
      userName: userName,
      answers: answers,
      score: score,
      totalQuestions: questions.length,
      correctCount: correctCount,
      submittedAt: submission.submittedAt,
      timeTakenSeconds: timeTakenSeconds,
      timePerQuestion: timePerQuestion,
    );
  }

  Stream<List<SubmissionModel>> getLeaderboard(String quizId) {
    return _db
        .collection('submissions')
        .where('quizId', isEqualTo: quizId)
        .orderBy('score', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SubmissionModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<SubmissionModel?> getUserSubmission(String quizId, String userId) async {
    final snap = await _db
        .collection('submissions')
        .where('quizId', isEqualTo: quizId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return SubmissionModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  Stream<List<SubmissionModel>> getHostSubmissions(String quizId) {
    return _db
        .collection('submissions')
        .where('quizId', isEqualTo: quizId)
        .orderBy('score', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SubmissionModel.fromMap(d.data(), d.id))
            .toList());
  }

  /// Returns the participant's rank (1-based) in a quiz
  Future<int> getUserRank(String quizId, String userId) async {
    final snap = await _db
        .collection('submissions')
        .where('quizId', isEqualTo: quizId)
        .orderBy('score', descending: true)
        .get();
    final docs = snap.docs;
    for (int i = 0; i < docs.length; i++) {
      if (docs[i].data()['userId'] == userId) return i + 1;
    }
    return docs.length + 1;
  }
}
