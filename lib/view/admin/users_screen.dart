import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:quizeapp/service/user/firebase_cloud_storage.dart';
import 'package:quizeapp/view/admin/notification_card.dart';
import '../../modal/category.dart';
import '../../theme/theme.dart';
import '../../utils/device/device_utility.dart';
import '../../utils/theme/theme.dart';
import 'make_coordinator.dart';
import 'user_info_admin.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;
  List<Category> _categories = [];
  Category? _initialCategory;

  final gmailSmtp = gmail("webofficerbruno@gmail.com", "pwmo sggt yvex xqvt");

  // send mail to user using smtp
  sendMailFromGmail(String sender, sub, text) async {
    final message = Message()
      ..from = Address("webofficerbruno@gmail.com", "ICMS Support Team")
      ..recipients.add(sender)
      ..subject = sub
      ..html = text;

    try {
      final sendReport = await send(message, gmailSmtp);
      print("Message sent: $sendReport");
    } on MailerException catch (e) {
      print("Message not sent.");

      for (var p in e.problems) {
        print("Problem: ${p.code} : ${p.msg}");
      }
    }
  }

  void _fetchCategories() async {
    try {
      final querySnapshot = await _firebase.collection("categories").get();
      final categories = querySnapshot.docs
          .map((doc) => Category.fromMap(doc.id, doc.data()))
          .toList();
      setState(() {
        _categories = categories;
      });
    } catch (e) {}
  }

  Stream<QuerySnapshot> _getUsersStream() {
    Query query = _firebase.collection("users");

    String? filterCategoryId = _selectedCategoryId;

    if (_selectedCategoryId != null) {
      query = query
          .where(
            "program",
            isEqualTo: filterCategoryId,
          )
          .where(
            "role",
            isEqualTo: "user",
          );
    } else {
      query = query.where(
        "role",
        isEqualTo: "user",
      );
    }

    return query.snapshots();
  }

  Widget _buildTitle() {
    String? categoryId = _selectedCategoryId;
    if (categoryId == null) {
      return Text(
        'All Students',
        style: Theme.of(context).textTheme.titleMedium,
      );
    }
    return StreamBuilder<DocumentSnapshot>(
        stream: _firebase.collection("categories").doc(categoryId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text(
              "Loading...",
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
            style: Theme.of(context).textTheme.titleMedium,
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTitle(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Students",
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
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
                  child: const Text("All Cohorts"),
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
              stream: _getUsersStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final users = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final firstName =
                      (data['firstName'] ?? '').toString().toLowerCase();
                  final lastName =
                      (data['lastName'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();

                  return _searchQuery.isEmpty ||
                      firstName.contains(_searchQuery) ||
                      lastName.contains(_searchQuery) ||
                      email.contains(_searchQuery);
                }).toList();

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 100,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No students found",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userData =
                        users[index].data() as Map<String, dynamic>;
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserInfoAdmin(
                              userData: userData,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: NotificationItemCard(
                          showTrailing: true,
                          onTrailingPressed: () async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Change Role'),
                                  content: Text(
                                      'Are you sure you want to change the role of ${userData['Firstname']} ${userData['Surname']}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        // Create coordinator in Firestore
                                        await FirebaseCloudStorage()
                                            .changeUserRoleToCoordinator(
                                                userData['email'], "admin");

                                        await sendMailFromGmail(
                                            userData['email'],
                                            "Successfully Add As A Admin", '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Update - ICMS</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            border-bottom: 2px solid #4a90e2;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .logo {
            font-size: 24px;
            font-weight: bold;
            color: #4a90e2;
        }
        .content {
            background-color: #f9f9f9;
            padding: 25px;
            border-radius: 8px;
            margin-bottom: 30px;
        }
        .highlight {
            background-color: #e8f4fd;
            padding: 15px;
            border-left: 4px solid #4a90e2;
            margin: 20px 0;
        }
        .footer {
            border-top: 1px solid #ddd;
            padding-top: 20px;
            font-size: 14px;
            color: #666;
        }
        .button {
            display: inline-block;
            background-color: #4a90e2;
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 5px;
            margin: 15px 0;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo">ICMS Platform</div>
    </div>
    
    <div class="content">
        <h2>Account Permission Update</h2>
        
        <p>Dear ${userData['Firstname']},</p>
        
        <p>We are writing to inform you that your account permissions have been updated in the ICMS application.</p>
        
        <div class="highlight">
            <strong>New Role:</strong> Administrator<br>
            <strong>Effective Date:</strong> Immediately<br>
            <strong>Account Status:</strong> Active
        </div>
        
        <p>This update provides you with expanded access to administrative features within the platform. You can now access the administrator dashboard and manage system settings.</p>
        
        <a href="#" class="button">Access ICMS Dashboard</a>
        
        <p>If you have any questions about your new permissions or need assistance accessing the administrator features, please contact our support team.</p>
        
        <p>We appreciate your continued participation in our platform.</p>
    </div>
    
    <div class="footer">
        <p><strong>ICMS Support Team</strong><br>
        This message was sent regarding your ICMS account permissions.<br>
        For support inquiries, please contact us through the platform.</p>
        
        <p><small>This is an automated notification regarding your account status. Please do not reply to this email.</small></p>
    </div>
</body>
</html>
''');

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Coordinator created successfully')),
                                        );
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Make Admin'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        // Create coordinator in Firestore
                                        await FirebaseCloudStorage()
                                            .changeUserRoleToCoordinator(
                                                userData['email'],
                                                "coordinator");

                                        await sendMailFromGmail(
                                            userData['email'],
                                            "Successfully Add As A Coordinator",
                                            '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Update - ICMS</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            border-bottom: 2px solid #4a90e2;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .logo {
            font-size: 24px;
            font-weight: bold;
            color: #4a90e2;
        }
        .content {
            background-color: #f9f9f9;
            padding: 25px;
            border-radius: 8px;
            margin-bottom: 30px;
        }
        .highlight {
            background-color: #e8f4fd;
            padding: 15px;
            border-left: 4px solid #4a90e2;
            margin: 20px 0;
        }
        .footer {
            border-top: 1px solid #ddd;
            padding-top: 20px;
            font-size: 14px;
            color: #666;
        }
        .button {
            display: inline-block;
            background-color: #4a90e2;
            color: white;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 5px;
            margin: 15px 0;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="logo">ICMS Platform</div>
    </div>
    
    <div class="content">
        <h2>Account Permission Update</h2>
        
        <p>Dear ${userData['Firstname']},</p>
        
        <p>We are writing to inform you that your account permissions have been updated in the ICMS application.</p>
        
        <div class="highlight">
            <strong>New Role:</strong> Coordinator<br>
            <strong>Effective Date:</strong> Immediately<br>
            <strong>Account Status:</strong> Active
        </div>
        
        <p>This update provides you with expanded access to administrative features within the platform. You can now access the administrator dashboard and manage system settings.</p>
        
        <a href="#" class="button">Access ICMS Dashboard</a>
        
        <p>If you have any questions about your new permissions or need assistance accessing the administrator features, please contact our support team.</p>
        
        <p>We appreciate your continued participation in our platform.</p>
    </div>
    
    <div class="footer">
        <p><strong>ICMS Support Team</strong><br>
        This message was sent regarding your ICMS account permissions.<br>
        For support inquiries, please contact us through the platform.</p>
        
        <p><small>This is an automated notification regarding your account status. Please do not reply to this email.</small></p>
    </div>
</body>
</html>
''');

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Coordinator created successfully')),
                                        );
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Make Coordinator'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          isDarkMode: TDeviceUtils.getMode(context),
                          theme: TAppTheme.darkTheme,
                          firstName: userData['Firstname'] ?? '',
                          surname: userData['Surname'] ?? '',
                          email: userData['email'] ?? '',
                          image: userData['image_url'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
