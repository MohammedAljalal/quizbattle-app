import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_model.dart';

class QuizService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    final code = List.generate(4, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'QB-$code';
  }

  Future<String> createQuiz(QuizModel quiz) async {
    final doc = await _db.collection('quizzes').add(quiz.toMap());
    return doc.id;
  }

  Stream<List<QuizModel>> getHostQuizzes(String hostId) {
    return _db
        .collection('quizzes')
        .where('hostId', isEqualTo: hostId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => QuizModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<QuizModel?> getQuizByRoomCode(String code) async {
    final snap = await _db
        .collection('quizzes')
        .where('roomCode', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return QuizModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  Stream<QuizModel?> watchQuiz(String quizId) {
    return _db.collection('quizzes').doc(quizId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return QuizModel.fromMap(doc.data()!, doc.id);
    });
  }

  Future<void> closeRoom(String quizId) async {
    await _db.collection('quizzes').doc(quizId).update({'isOpen': false});
  }

  Future<void> deleteQuiz(String quizId) async {
    await _db.collection('quizzes').doc(quizId).delete();
  }

  Future<void> addParticipant(String quizId, String userId) async {
    await _db.collection('quizzes').doc(quizId).update({
      'participants': FieldValue.arrayUnion([userId]),
    });
  }

  bool isRoomValid(QuizModel quiz) {
    return quiz.isOpen && !quiz.isExpired;
  }
}
