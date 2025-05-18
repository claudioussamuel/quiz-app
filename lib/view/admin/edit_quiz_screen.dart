import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizeapp/modal/quiz.dart';
import '../../modal/question.dart';
import '../../theme/theme.dart';

class EditQuizScreen extends StatefulWidget {
  final Quiz quiz;
  const EditQuizScreen({super.key, required this.quiz});

  @override
  State<EditQuizScreen> createState() => _EditQuizScreenState();
}

class QuestionFromItem {
  final TextEditingController questionController;
  final List<TextEditingController> optionControllers;
  int correctOptionIndex;

  QuestionFromItem(
      {required this.questionController,
      required this.optionControllers,
      required this.correctOptionIndex});

  void dispose() {
    questionController.dispose();
    optionControllers.forEach((element) {
      element.dispose();
    });
  }
}

class _EditQuizScreenState extends State<EditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _timeLimitController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  late List<QuestionFromItem> _questionFromItem;

  @override
  void initState() {
    // TODO: implement initStatet
    super.initState();
    _initData();
  }

  void _addQuestion() {
    setState(() {
      _questionFromItem.add(QuestionFromItem(
          questionController: TextEditingController(),
          optionControllers: List.generate(4, (_) => TextEditingController()),
          correctOptionIndex: 0));
    });
  }

  void _removeQuestion(int index) {
    if (_questionFromItem.length > 1) {
      setState(() {
        _questionFromItem[index].dispose();
        _questionFromItem.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Quiz must be at least one question",
          ),
        ),
      );
    }
  }

  Future<void> _updateQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final questions = _questionFromItem
          .map(
            (item) => Question(
              text: item.questionController.text.trim(),
              options:
                  item.optionControllers.map((e) => e.text.trim()).toList(),
              correctOptionIndex: item.correctOptionIndex,
            ),
          )
          .toList();

      final updateQuiz = widget.quiz.copyWith(
        title: _titleController.text.trim(),
        timeLimit: int.parse(
          _timeLimitController.text.trim(),
        ),
        questions: questions,
        createdAt: widget.quiz.createdAt,
      );

      await _firestore.collection("quizzes").doc(widget.quiz.id).update(
            updateQuiz.toMap(isUpdate: true),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quiz Update successfully'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to upate quiz',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _titleController.dispose();
    _timeLimitController.dispose();
    for (var item in _questionFromItem) {
      item.dispose();
    }
  }

  void _initData() {
    _titleController = TextEditingController(text: widget.quiz.title);
    _timeLimitController =
        TextEditingController(text: widget.quiz.timeLimit.toString());

    _questionFromItem = widget.quiz.questions.map((question) {
      return QuestionFromItem(
        questionController: TextEditingController(text: question.text),
        optionControllers: question.options
            .map((options) => TextEditingController(text: options))
            .toList(),
        correctOptionIndex: question.correctOptionIndex,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          "Edit Quiz",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _updateQuiz,
            icon: Icon(Icons.save),
            color: AppTheme.primaryColor,
          )
        ],
      ),
      body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              Text(
                "Quiz Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Quiz Title",
                  hintText: "Enter quiz title",
                  prefixIcon: Icon(
                    Icons.title,
                    color: AppTheme.primaryColor,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter quiz title";
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _timeLimitController,
                decoration: InputDecoration(
                  labelText: "Time Limit (in minute)",
                  hintText: "Enter time limit",
                  prefixIcon: Icon(
                    Icons.timer,
                    color: AppTheme.primaryColor,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter time Limit";
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return "Please enter a valid time limit";
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 32,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Questions",
                        style: TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addQuestion,
                        label: Text(
                          "Add Question",
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppTheme.primaryColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  ..._questionFromItem.asMap().entries.map((entry) {
                    final index = entry.key;
                    final QuestionFromItem question = entry.value;

                    return Card(
                      margin: EdgeInsets.only(bottom: 18),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Question ${index + 1}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor),
                                  ),
                                  if (_questionFromItem.length > 1)
                                    IconButton(
                                      onPressed: () {
                                        _removeQuestion(index);
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: question.questionController,
                                decoration: InputDecoration(
                                  labelText: "Question title",
                                  hintText: "Enter question",
                                  prefixIcon: Icon(
                                    Icons.question_answer,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter question";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              ...question.optionControllers
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final optionIndex = entry.key;
                                final controller = entry.value;

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                          activeColor: AppTheme.primaryColor,
                                          value: optionIndex,
                                          groupValue:
                                              question.correctOptionIndex,
                                          onChanged: (value) {
                                            setState(() {
                                              question.correctOptionIndex =
                                                  value!;
                                            });
                                          }),
                                      Expanded(
                                        child: TextFormField(
                                          controller: controller,
                                          decoration: InputDecoration(
                                            labelText:
                                                'Option ${optionIndex + 1}',
                                            hintText: 'Enter option',
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter option';
                                            }
                                            return null;
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              })
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(
                    height: 32,
                  ),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateQuiz,
                        child: _isLoading
                            ? SizedBox(
                                height: 28,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Update Quiz",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
