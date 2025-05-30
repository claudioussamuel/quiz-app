import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quizeapp/modal/category.dart';
import 'package:quizeapp/modal/quiz.dart';

import '../../theme/theme.dart';
import 'add_quiz_screen.dart';
import 'admin_home_screen.dart';
import 'edit_quiz_screen.dart';

class ManageQuizzesScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  const ManageQuizzesScreen({super.key, this.categoryId, this.categoryName});

  @override
  State<ManageQuizzesScreen> createState() => _ManageQuizzesScreenState();
}

class _ManageQuizzesScreenState extends State<ManageQuizzesScreen> {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedCategoryId;
  List<Category> _categories = [];
  Category? _initialCategory;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() async {
    try {
      final querySnapshot = await _firebase.collection("categories").get();
      final categories = querySnapshot.docs
          .map((doc) => Category.fromMap(doc.id, doc.data()))
          .toList();
      setState(() {
        _categories = categories;
        if (widget.categoryId != null) {
          _initialCategory = _categories.firstWhere(
            (element) => element.id == widget.categoryId,
            orElse: () => Category(
              name: "Unknown",
              description: "",
              id: widget.categoryId!,
            ),
          );
          _selectedCategoryId = _initialCategory!.id;
        }
      });
    } catch (e) {}
  }

  Stream<QuerySnapshot> _getQuizStream() {
    Query query = _firebase.collection("quizzes");

    String? filterCategoryId = _selectedCategoryId ?? widget.categoryId;

    if (_selectedCategoryId != null) {
      query = query.where("categoryId", isEqualTo: filterCategoryId);
    }

    return query.snapshots();
  }

  Widget _buildTitle() {
    String? categoryId = _selectedCategoryId ?? widget.categoryId;
    if (categoryId == null) {
      return Text(
        'All Quizzes',
        style: Theme.of(
          context,
        ).textTheme.titleMedium,
      );
    }
    return StreamBuilder<DocumentSnapshot>(
        stream: _firebase
            .collection(
              "categories",
            )
            .doc(
              categoryId,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text(
              "Loaing...",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            );
          }
          final category = Category.fromMap(
            snapshot.data!.id,
            snapshot.data!.data() as Map<String, dynamic>,
          );

          return Text(
            category.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminHomeScreen())),
        ),
        title: _buildTitle(),
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppTheme.primaryColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddQuizScreen(
                    categoryId: widget.categoryId,
                    categoryName: widget.categoryName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Quizzes",
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: "Cohort",
              ),
              value: _selectedCategoryId,
              items: [
                DropdownMenuItem(
                  child: const Text("All Cohort"),
                  value: null,
                ),
                if (_initialCategory != null &&
                    _categories.every((c) => c.id != _initialCategory!.id))
                  DropdownMenuItem(
                    child: Text(_initialCategory!.name),
                    value: _initialCategory!.id,
                  ),
                ..._categories.map((category) => DropdownMenuItem(
                      child: Text(category.name),
                      value: category.id,
                    ))
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: _getQuizStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final quizzes = snapshot.data!.docs
                  .map((doc) => Quiz.fromMap(
                        doc.id,
                        doc.data() as Map<String, dynamic>,
                      ))
                  .where(
                    (quiz) =>
                        _searchQuery.isEmpty ||
                        quiz.title.toLowerCase().contains(
                              _searchQuery,
                            ),
                  )
                  .toList();

              if (quizzes.isEmpty) {
                return Center(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.quiz,
                          size: 100,
                          color: AppTheme.primaryColor,
                        ),
                        SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddQuizScreen(
                                      categoryId: widget.categoryId,
                                    ),
                                  ),
                                );
                              },
                              child: const Text("Add Quiz"),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: quizzes.length,
                itemBuilder: (context, index) {
                  final quiz = quizzes[index];
                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.quiz,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      title: Text(
                        quiz.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        children: [
                          SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.question_answer_outlined,
                                size: 16,
                                color: AppTheme.textSecondaryColor,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "${quiz.questions.length} Questions",
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                              SizedBox(width: 16),
                              const Icon(
                                Icons.timer_outlined,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "${quiz.timeLimit} mins",
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              value: "edit",
                              child: ListTile(
                                leading: Icon(
                                  Icons.edit,
                                  color: AppTheme.primaryColor,
                                ),
                                title: Text("Edit"),
                              ),
                            ),
                            PopupMenuItem(
                              value: "delete",
                              child: ListTile(
                                leading: Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                title: Text("Delete"),
                              ),
                            ),
                          ];
                        },
                        onSelected: (value) =>
                            _handleQuizActions(context, value, quiz),
                      ),
                    ),
                  );
                },
              );
            },
          ))
        ],
      ),
    );
  }

  Future<void> _handleQuizActions(
    BuildContext context,
    String value,
    Quiz quiz,
  ) async {
    if (value == "edit") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditQuizScreen(
            quiz: quiz,
          ),
        ),
      );
    } else if (value == "delete") {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete Quiz"),
            content: const Text("Are you sure you want to delete this quiz?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context, true);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        try {
          await _firebase.collection("quizzes").doc(quiz.id).delete();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete quiz"),
            ),
          );
        }
      }
    }
  }
}
