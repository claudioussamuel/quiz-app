import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../modal/category.dart';
import '../../modal/quiz.dart';
import '../../service/auth/bloc/auth_bloc.dart';
import '../../service/select_image/bloc/select_image_bloc.dart'
    show SelectImageBloc;
import '../../service/user/firebase_cloud_storage.dart';
import '../../service/user/user.dart';
import '../user/edit_profile_screen.dart';
import '../admin/billing_history_screen.dart';
import '../user/student_id_screen.dart';

class UserInfoAdmin extends StatefulWidget {
  const UserInfoAdmin({super.key, required this.userData});
  final Map<String, dynamic> userData;

  @override
  State<UserInfoAdmin> createState() => _UserInfoAdminState();
}

class _UserInfoAdminState extends State<UserInfoAdmin> {
  List<Quiz> _quizzes = [];

  getQuiz() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("quizzes")
        .where("categoryId", isEqualTo: widget.userData["program"])
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

  Future<UserInfo?> fetchUserInfoByEmail(String email) async {
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
    getQuiz();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                        InkWell(
                          onTap: () async {
                            final FirebaseCloudStorage _userInfoService =
                                FirebaseCloudStorage();
                            final userInfo = await _userInfoService
                                .fetchUserInfoStreamByEmail(
                                    widget.userData['email'])
                                .first;
                            if (userInfo != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider<SelectImageBloc>(
                                        create: (_) => SelectImageBloc(),
                                      ),
                                      // BlocProvider<AuthBloc>(
                                      //   create: (_) => AuthBloc(),
                                      // ),
                                    ],
                                    child: EditProfileScreen(
                                      userInfo: userInfo,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('User info not found!')),
                              );
                            }
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.blueAccent.withOpacity(0.1),
                            ),
                            child: Icon(
                              Iconsax.edit,
                              color: Colors.black,
                            ),
                          ),
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
                          image: DecorationImage(
                              image: NetworkImage(
                                widget.userData['image_url'],
                              ),
                              fit: BoxFit.cover),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 0.1,
                              blurRadius: 2,
                              offset: Offset(0, 5),
                            )
                          ]),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      widget.userData['Firstname'],
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      widget.userData['Surname'],
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
                            subtitle: Text(widget.userData['email'] ?? '-'),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Iconsax.user_tag,
                                color: Colors.blueAccent),
                            title: Text('Coordinator'),
                            subtitle: FutureBuilder<UserInfo?>(
                              future: fetchUserInfoByEmail(
                                  widget.userData['coordinator'] ?? '-'),
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
                            subtitle: Text(widget.userData['debit'].toString()),
                            trailing: IconButton(
                              icon: Icon(Iconsax.edit),
                              onPressed: () {},
                            ),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.access_time,
                                color: Colors.blueAccent),
                            title: Text('Cohort'),
                            subtitle: FutureBuilder<Category?>(
                              future:
                                  fetchCategoryById(widget.userData['program']),
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
                                  subtitle:
                                      Text('${widget.userData[quiz.id]} %'),
                                  trailing: IconButton(
                                    icon: Icon(Iconsax.edit),
                                    onPressed: () {},
                                  ),
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
                                              userEmail:
                                                  widget.userData['email']),
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
                                          userEmail: widget.userData['email']),
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
