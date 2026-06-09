import 'package:cloud_firestore/cloud_firestore.dart';
import 'question_model.dart';

class QuizModel {
  final String quizId;
  final String title;
  final String category;
  final String hostId;
  final String hostName;
  final String roomCode;
  final DateTime startTime;
  final DateTime endTime;
  final bool isOpen;
  final List<String> participants;
  final List<QuestionModel> questions;
  // NEW features
  final int? timeLimitSeconds;   // per-question timer (null = unlimited)
  final bool showCorrectAnswer;  // show correct answer after each question
  final String difficulty;       // 'easy' | 'medium' | 'hard'
  final int maxParticipants;     // 0 = unlimited
  final String description;

  QuizModel({
    required this.quizId,
    required this.title,
    required this.category,
    required this.hostId,
    required this.hostName,
    required this.roomCode,
    required this.startTime,
    required this.endTime,
    required this.isOpen,
    required this.participants,
    required this.questions,
    this.timeLimitSeconds,
    this.showCorrectAnswer = true,
    this.difficulty = 'medium',
    this.maxParticipants = 0,
    this.description = '',
  });

  factory QuizModel.fromMap(Map<String, dynamic> map, String id) {
    return QuizModel(
      quizId: id,
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      hostId: map['hostId'] ?? '',
      hostName: map['hostName'] ?? '',
      roomCode: map['roomCode'] ?? '',
      startTime: (map['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (map['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isOpen: map['isOpen'] ?? false,
      participants: List<String>.from(map['participants'] ?? []),
      questions: (map['questions'] as List<dynamic>?)
              ?.map((q) => QuestionModel.fromMap(q as Map<String, dynamic>))
              .toList() ??
          [],
      timeLimitSeconds: map['timeLimitSeconds'],
      showCorrectAnswer: map['showCorrectAnswer'] ?? true,
      difficulty: map['difficulty'] ?? 'medium',
      maxParticipants: map['maxParticipants'] ?? 0,
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'hostId': hostId,
      'hostName': hostName,
      'roomCode': roomCode,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'isOpen': isOpen,
      'participants': participants,
      'questions': questions.map((q) => q.toMap()).toList(),
      'timeLimitSeconds': timeLimitSeconds,
      'showCorrectAnswer': showCorrectAnswer,
      'difficulty': difficulty,
      'maxParticipants': maxParticipants,
      'description': description,
    };
  }

  bool get isExpired => DateTime.now().isAfter(endTime);
  bool get isAvailable => isOpen && !isExpired;
  bool get isFull => maxParticipants > 0 && participants.length >= maxParticipants;
  int get participantCount => participants.length;
  int get questionCount => questions.length;

  String get difficultyLabel {
    switch (difficulty) {
      case 'easy': return 'سهل';
      case 'hard': return 'صعب';
      default: return 'متوسط';
    }
  }

  String get difficultyEmoji {
    switch (difficulty) {
      case 'easy': return '🟢';
      case 'hard': return '🔴';
      default: return '🟡';
    }
  }

  QuizModel copyWith({
    String? title, String? category, String? hostId, String? hostName,
    String? roomCode, DateTime? startTime, DateTime? endTime, bool? isOpen,
    List<String>? participants, List<QuestionModel>? questions,
    int? timeLimitSeconds, bool? showCorrectAnswer, String? difficulty,
    int? maxParticipants, String? description,
  }) {
    return QuizModel(
      quizId: quizId,
      title: title ?? this.title,
      category: category ?? this.category,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      roomCode: roomCode ?? this.roomCode,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isOpen: isOpen ?? this.isOpen,
      participants: participants ?? this.participants,
      questions: questions ?? this.questions,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      showCorrectAnswer: showCorrectAnswer ?? this.showCorrectAnswer,
      difficulty: difficulty ?? this.difficulty,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      description: description ?? this.description,
    );
  }
}
