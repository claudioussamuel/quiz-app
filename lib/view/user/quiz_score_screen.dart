import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../modal/quiz.dart';

class QuizScoreScreen extends StatefulWidget {
  const QuizScoreScreen({super.key});

  @override
  State<QuizScoreScreen> createState() => _QuizScoreScreenState();
}

class _QuizScoreScreenState extends State<QuizScoreScreen> {
  List<Quiz> _quizzes = [];
  Map<String, dynamic> personalUser = {};
  bool _isLoading = true;

  String? user = FirebaseAuth.instance.currentUser?.email;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserInfoStreamByEmail(user ?? "");
    _fetchQuizzes();
  }

  Future<void> fetchUserInfoStreamByEmail(String email) async {
    try {
      print("Mr. Opoku  ${email}");
      FirebaseFirestore.instance
          .collection("users")
          .where(
            'email',
            isEqualTo: email,
          )
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          setState(() {
            personalUser = doc.data();
          });
        } else {
          setState(() {
            personalUser = {};
          });
        }
      });
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  Future<void> _fetchQuizzes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("quizzes")
          .where("categoryId", isEqualTo: personalUser["program"])
          .get();

      setState(() {
        _quizzes = snapshot.docs
            .map(
              (doc) => Quiz.fromMap(
                doc.id,
                doc.data(),
              ),
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load quizzes",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _quizzes.length,
              itemBuilder: (context, index) {
                final quiz = _quizzes[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 30,
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          quiz.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text('${personalUser[quiz.id]}%')
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
