import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../modal/category.dart';
import '../../modal/quiz.dart';
import '../../service/user/user.dart';
import '../admin/billing_history_screen.dart';
import '../user/student_id_screen.dart';

class UserInfoCoordinator extends StatefulWidget {
  const UserInfoCoordinator({super.key, required this.userEmail});
  final String userEmail;

  @override
  State<UserInfoCoordinator> createState() => _UserInfoCoordinatorState();
}

class _UserInfoCoordinatorState extends State<UserInfoCoordinator> {
  List<Quiz> _quizzes = [];

  Map<String, dynamic> userData = {};
  bool _isLoading = true;

  getQuiz() async {
    if (userData["program"] == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection("quizzes")
        .where("categoryId", isEqualTo: userData["program"])
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
    });
  }

  Future<UserInfo?> fetchCoordinatorInfoByEmail(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;

        return UserInfo.fromSnapshot(doc);
      } else {
        print("No user found with the provided email.");
        return null;
      }
    } catch (e) {
      print("Error fetching user info by email: $e");
      return null;
    }
  }

  Future<UserInfo?> fetchUserInfoByEmail(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        userData = doc.data();
        setState(() {
          _isLoading = false;
        });
        return UserInfo.fromSnapshot(doc);
      } else {
        print("No user found with the provided email.");
        setState(() {
          _isLoading = false;
        });
        return null;
      }
    } catch (e) {
      print("Error fetching user info by email: $e");
      setState(() {
        _isLoading = false;
      });
      return null;
    }
  }

  Future<Category?> fetchCategoryById(String id) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("categories")
          .doc(id)
          .get();

      if (doc.exists) {
        return Category.fromMap(doc.id, doc.data()!);
      } else {
        print("No category found with the provided ID.");
        return null;
      }
    } catch (e) {
      print("Error fetching category by ID: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfoByEmail(widget.userEmail).then((_) {
      getQuiz();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (userData.isEmpty) {
      return Scaffold(
        body: Center(child: Text('User data not found.')),
      );
    }
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          //color: Colors.blueAccent.withOpacity(0.1),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.blueAccent.withOpacity(0.1),
                              ),
                              child: Icon(
                                Iconsax.arrow_left,
                                color: Colors.black,
                              )),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 40),
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.blueAccent,
                          image: userData['image_url'] != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                    userData['image_url'],
                                  ),
                                  fit: BoxFit.cover)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 0.1,
                              blurRadius: 2,
                              offset: Offset(0, 5),
                            )
                          ]),
                      child: userData['image_url'] == null
                          ? Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      userData['Firstname'] ?? '-',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      userData['Surname'] ?? '-',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
              DraggableScrollableSheet(
                  initialChildSize: 0.65,
                  minChildSize: 0.4,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) {
                    return Container(
                      padding: EdgeInsets.only(top: 40, left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: ListView(
                        controller: scrollController,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.email_outlined,
                                color: Colors.blueAccent),
                            title: Text('Email'),
                            subtitle: Text(userData['email'] ?? '-'),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Iconsax.user_tag,
                                color: Colors.blueAccent),
                            title: Text('Coordinator'),
                            subtitle: FutureBuilder<UserInfo?>(
                              future: fetchCoordinatorInfoByEmail(
                                  userData['coordinator'] ?? '-'),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text('Loading...');
                                } else if (snapshot.hasError) {
                                  return Text('Error');
                                } else if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return Text('Not found');
                                } else {
                                  final userInfo = snapshot.data!;
                                  return Text(
                                      '${userInfo.firstName_} ${userInfo.surname_}');
                                }
                              },
                            ),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.verified_user_outlined,
                                color: Colors.blueAccent),
                            title: Text('Debt'),
                            subtitle: Text(userData['debit'].toString()),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.access_time,
                                color: Colors.blueAccent),
                            title: Text('Cohort'),
                            subtitle: FutureBuilder<Category?>(
                              future: fetchCategoryById(userData['program']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text('Loading...');
                                } else if (snapshot.hasError) {
                                  return Text('Error');
                                } else if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return Text('Not found');
                                } else {
                                  final category = snapshot.data!;
                                  return Text(category.name);
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 32),
                          if (_quizzes.isNotEmpty) ...[
                            Text('Quizzes',
                                style: Theme.of(context).textTheme.titleMedium),
                            SizedBox(height: 8),
                            ..._quizzes.map((quiz) => ListTile(
                                  leading: Icon(Icons.quiz,
                                      color: Colors.blueAccent),
                                  title: Text(quiz.title),
                                  subtitle: Text('${userData[quiz.id]} %'),
                                )),
                            Divider(),
                          ],
                          Text('Admin Actions',
                              style: Theme.of(context).textTheme.titleMedium),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BillingHistoryScreen(
                                              userEmail: userData['email']),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.account_balance),
                                label: Text('See Billing History'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.all(8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: Colors.blueAccent),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  //StudentIdScreen

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentIdScreen(
                                          userEmail: userData['email']),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.edit),
                                label: Text('Student Id '),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyanAccent,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.all(8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: Colors.cyanAccent),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
