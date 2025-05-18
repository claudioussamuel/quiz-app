import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizeapp/modal/category.dart';
import 'package:quizeapp/modal/question.dart';
import 'package:quizeapp/modal/quiz.dart';
import 'package:quizeapp/theme/theme.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class AddQuizScreen extends StatefulWidget {
  final String? categoryId;

  final String? categoryName;
  const AddQuizScreen({super.key, this.categoryId, this.categoryName});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
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

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeLimitController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _selectedCategoryId;
  List<QuestionFromItem> _questionFromItem = [];
  List<List<dynamic>> _data = [];
  String? filePath;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _addQuestion();
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

  void _addQuestion() {
    setState(() {
      _questionFromItem.add(
        QuestionFromItem(
            questionController: TextEditingController(),
            optionControllers: List.generate(
              4,
              (_) => TextEditingController(),
            ),
            correctOptionIndex: 0),
      );
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questionFromItem[index].dispose();
      _questionFromItem.removeAt(index);
    });
  }

  Future<void> _saveQuez() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please Select Cohort",
          ),
        ),
      );
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
              options: item.optionControllers
                  .map(
                    (e) => e.text.trim(),
                  )
                  .toList(),
              correctOptionIndex: item.correctOptionIndex,
            ),
          )
          .toList();
      await _firestore.collection("quizzes").doc().set(
            Quiz(
              id: _firestore.collection("quizzes").doc().id,
              title: _titleController.text.trim(),
              categoryId: _selectedCategoryId!,
              timeLimit: int.parse(_timeLimitController.text),
              questions: questions,
              createdAt: DateTime.now(),
            ).toMap(),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quiz added successfully'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add quiz',
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

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    // if no file is picked
    if (result == null) return;
    // we will log the name, size and path of the
    // first picked file (if multiple are selected)
    print(result.files.first.name);
    filePath = result.files.first.path!;

    final input = File(filePath!).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();
    print('${fields.length} fields in the file.');

    setState(() {
      _data = fields;
      _populateQuestionsFromCSV(fields);
    });
  }

  void _populateQuestionsFromCSV(List<List<dynamic>> fields) {
    // Clear existing questions
    _questionFromItem.clear();

    // Skip the header row and iterate through the CSV data
    for (var i = 1; i < fields.length; i++) {
      final row = fields[i];
      if (row.length < 6) continue; // Ensure there are enough columns

      final questionText = row[0].toString();
      final options = row
          .sublist(1, 5)
          .map((e) => TextEditingController(text: e.toString()))
          .toList();
      final correctOptionIndex = int.tryParse(row[5].toString()) ?? 0;

      _questionFromItem.add(
        QuestionFromItem(
          questionController: TextEditingController(text: questionText),
          optionControllers: options,
          correctOptionIndex: correctOptionIndex,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          widget.categoryName != null
              ? "Add ${widget.categoryName}"
              : "Add Quiz",
          style: Theme.of(
            context,
          ).textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveQuez,
            icon: const Icon(Icons.save),
            color: AppTheme.primaryColor,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  height: 18,
                ),
                if (widget.categoryId == null)
                  StreamBuilder(
                    stream: _firestore
                        .collection("categories")
                        .orderBy('name')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text("Error");
                      }
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        );
                      }

                      final categories = snapshot.data!.docs
                          .map(
                            (
                              doc,
                            ) =>
                                Category.fromMap(
                              doc.id,
                              doc.data() as Map<String, dynamic>,
                            ),
                          )
                          .toList();
                      return DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: "Cohort",
                          hintText: "Select Cohort",
                          prefixIcon: Icon(
                            Icons.category,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        items: categories
                            .map((category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.name),
                                ))
                            .toList(),
                        validator: (value) {
                          value == null ? "Please select a Cohort" : null;
                        },
                        onChanged: (value) {
                          _selectedCategoryId = value;
                        },
                      );
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
                  height: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Text(
                        //   "Questions",
                        //   style: TextStyle(
                        //     color: AppTheme.textPrimaryColor,
                        //     fontWeight: FontWeight.bold,
                        //     fontSize: 20,
                        //   ),
                        // ),

                        ElevatedButton.icon(
                          onPressed: _pickFile,
                          label: Text(
                            "Import Question",
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(16),
                            foregroundColor: Colors.white,
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addQuestion,
                          label: Text(
                            "Add Question",
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(16),
                            foregroundColor: Colors.white,
                            backgroundColor: AppTheme.primaryColor,
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
                          onPressed: _isLoading ? null : _saveQuez,
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
                                  "Save Quiz",
                                ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
