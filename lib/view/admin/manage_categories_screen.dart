import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizeapp/modal/category.dart';

import '../../theme/theme.dart';
import 'add_category_screen.dart';
import 'admin_home_screen.dart';
import 'manage_quizzes_screen.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminHomeScreen())),
        ),
        title: Text(
          'Manage Cohort',
          style: Theme.of(
            context,
          ).textTheme.titleMedium,
        ),
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
                  builder: (context) => const AddCategoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
          stream: _firebaseFirestore
              .collection("categories")
              .orderBy("name")
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              final categories = snapshot.data?.docs
                  .map(
                    (doc) => Category.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    ),
                  )
                  .toList();
              if (categories!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 100,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddCategoryScreen(),
                                ),
                              );
                            },
                            child: const Text("Add Cohort"),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    margin: EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.category_outlined,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        category.description,
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: "edit",
                            child: ListTile(
                              leading: Icon(
                                Icons.edit,
                                color: AppTheme.primaryColor,
                              ),
                              title: Text("Edit"),
                              contentPadding: EdgeInsets.zero,
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
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          _handleCategoryActions(context, value, category);
                        },
                      ),
                      onTap: () {
                        //  QuizListScreen(categoryId: category.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageQuizzesScreen(
                              categoryId: category.id,
                              categoryName: category.name,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Future<void> _handleCategoryActions(
      BuildContext context, String action, Category category) async {
    if (action == "edit") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddCategoryScreen(
            category: category,
          ),
        ),
      );
    } else if (action == "delete") {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Delete Cohort"),
          content: const Text("Are you sure you want to delete this Cohort?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                "Cancel",
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
            )
          ],
        ),
      );

      if (confirm == true) {
        await _firebaseFirestore
            .collection(
              "categories",
            )
            .doc(
              category.id,
            )
            .delete();
      }
    }
  }
}
