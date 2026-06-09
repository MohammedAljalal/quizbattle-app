class QuestionModel {
  final String questionText;
  final List<String> options;
  final int correctAnswer; // index 0-3

  QuestionModel({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }

  QuestionModel copyWith({
    String? questionText,
    List<String>? options,
    int? correctAnswer,
  }) {
    return QuestionModel(
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
    );
  }
}
