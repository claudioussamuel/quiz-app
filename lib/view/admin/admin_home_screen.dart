import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizeapp/theme/theme.dart';
import 'package:iconsax/iconsax.dart';

import 'manage_categories_screen.dart';
import 'manage_quizzes_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchStatistics() async {
    final categoriesCount = await _firestore.collection('categories').get();
    final quizzesCount = await _firestore.collection('quizzes').get();

    // get latest 5 quizzes
    final latestQuizzes = await _firestore
        .collection('quizzes')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .limit(5)
        .get();

    final categories = await _firestore.collection("categories").get();
    final categoryData = await Future.wait(
      categories.docs.map(
        (
          category,
        ) async {
          final quizCount = await _firestore
              .collection("quizzes")
              .where("categoryId", isEqualTo: category.id)
              .count()
              .get();
          return {
            "name": category.data()["name"] as String,
            "count": quizCount.count,
          };
        },
      ),
    );
    return {
      "totalCategories": categoriesCount.size,
      "totalQuizzes": quizzesCount.size,
      "latestQuizzes": latestQuizzes.docs,
      "categoryData": categoryData,
    };
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
            ),
           const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: SafeArea(
        child: FutureBuilder(
          future: _fetchStatistics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text("An error occurred"),
              );
            }

            final stats = snapshot.data as Map<String, dynamic>;
            final List<dynamic> categoryData = stats["categoryData"];
            final List<QueryDocumentSnapshot> latestQuizzes =
                stats["latestQuizzes"];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Statistics",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildStatCard(
                          "Total Cohort",
                          stats["totalCategories"].toString(),
                          Icons.category_rounded,
                          AppTheme.primaryColor,
                        ),
                        _buildStatCard(
                          "Total Quizzes",
                          stats["totalQuizzes"].toString(),
                          Icons.quiz_rounded,
                          AppTheme.secondaryColor,
                        ),
                      ],
                    ),
                  )),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Recent Activity",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: latestQuizzes.length,
                    itemBuilder: (context, index) {
                      final quiz =
                          latestQuizzes[index].data() as Map<String, dynamic>;
                      return Container(
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ListTile(
                          leading: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: AppTheme.primaryColor,
                            ),
                            child: Icon(
                              Icons.quiz_rounded,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            quiz["title"] as String,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          subtitle: Text(
                            "Created on: ${_formatDate(quiz["createdAt"].toDate())}",
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Quick Actions",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                 const SizedBox(height: 10),
                  Padding(
                    padding:const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics:const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildDashboardCard(
                          context,
                          "Quizzes",
                          Icons.quiz_rounded,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ManageQuizzesScreen()),
                            );
                          },
                        ),
                        _buildDashboardCard(
                          context,
                          "Cohort",
                          Icons.category_rounded,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ManageCategoriesScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
