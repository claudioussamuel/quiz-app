import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EachQuizScoreScreen extends StatefulWidget {
  final String quizId;
  const EachQuizScoreScreen({
    super.key,
    required this.quizId,
  });

  @override
  State<EachQuizScoreScreen> createState() => _EachQuizScoreScreenState();
}

class _EachQuizScoreScreenState extends State<EachQuizScoreScreen> {
  List<Map<String, dynamic>> _students = [{}];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where(widget.quizId, isNull: false)
          .get();

      setState(() {
        _students = snapshot.docs
            .map(
              (doc) => doc.data(),
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
        const SnackBar(
          content: Text(
            "Failed to load Users",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz Scores',
          style: Theme.of(
            context,
          ).textTheme.titleMedium,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      "${student['Firstname']} ${student['Surname']}",
                    ),
                    subtitle: Text('Score: ${student[widget.quizId]}%'),
                  ),
                );
              },
            ),
    );
  }
}
