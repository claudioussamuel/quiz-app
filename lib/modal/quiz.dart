import 'question.dart';

class Quiz {
  final String id;
  final String title;
  final String categoryId;
  final int timeLimit;
  final List<Question> questions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Quiz({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.timeLimit,
    required this.questions,
    this.createdAt,
    this.updatedAt,
  });

  factory Quiz.fromMap(String id, Map<String, dynamic> map) {
    return Quiz(
      id: id,
      title: map['title'] ?? "",
      categoryId: map['categoryId'] ?? "",
      timeLimit: map['timeLimit'] ?? 0,
      questions: List<Question>.from(
        (map['questions'] ?? []).map(
          (question) => Question.fromMap(question),
        ),
      ),
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isUpdate = false}) {
    return {
      'title': title,
      'categoryId': categoryId,
      'timeLimit': timeLimit,
      'questions': questions.map((question) => question.toMap()).toList(),
      if (isUpdate) 'updatedAt': DateTime.now(),
      'createdAt': createdAt,
    };
  }

  Quiz copyWith(
      {String? id,
      String? title,
      String? categoryId,
      int? timeLimit,
      List<Question>? questions,
      DateTime? createdAt}) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      timeLimit: timeLimit ?? this.timeLimit,
      questions: questions ?? this.questions,
      createdAt: createdAt,
    );
  }
}
