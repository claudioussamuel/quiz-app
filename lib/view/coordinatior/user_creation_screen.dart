import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:quizeapp/utils/constants/size.dart';
import 'package:quizeapp/service/user/firebase_cloud_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../modal/category.dart';
import '../../service/page_index/bloc/page_index_bloc.dart';
import '../../service/user/bloc/user_data_bloc.dart';
import 'home_screen.dart';

class UserCreationScreen extends StatefulWidget {
  const UserCreationScreen({super.key});

  @override
  _UserCreationScreenState createState() => _UserCreationScreenState();
}

class _UserCreationScreenState extends State<UserCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  // Define the necessary variables
  String? _selectedCategoryId;
  Category? _initialCategory;
  List<Category> _categories = [];


    // creating smtp server for gmail
  final gmailSmtp = gmail("webofficerbruno@gmail.com","pwmo sggt yvex xqvt");

  // send mail to user using smtp
  sendMailFromGmail(String sender, sub, text) async{
    final message = Message()
    ..from = const Address("webofficerbruno@gmail.com", "ICMS Support Team")
    ..recipients.add(sender)
    ..subject = sub
    ..text = text;


    try {
      final sendReport = await send(message, gmailSmtp);
      print("Message sent: $sendReport");
    }on MailerException catch (e) {
      print("Message not sent.");

      for (var p in e.problems) {
        print("Problem: ${p.code} : ${p.msg}");
      }
      
    }
  }



  String? getCurrentUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.email;
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching categories: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Student',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Surname',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter surname';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                    hintText: "Select Program",
                  ),
                  value: _selectedCategoryId,
                  items: [
                    DropdownMenuItem(
                      child: const Text("All Programs"),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a program';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Create User'),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {

     FirebaseApp tempApp = await Firebase.initializeApp(name: "flutter", options: Firebase.app().options);

        UserCredential newUser = await FirebaseAuth.instanceFor(app: tempApp).createUserWithEmailAndPassword(
          email: emailController.text.trim(), 
          password: "&1234!@#^&",
        );

        await createUser(
          program: _selectedCategoryId ?? "",
          email: emailController.text.trim(),
          coordinator: getCurrentUserEmail() ?? "",
          firstName: firstNameController.text.trim(),
          surName: lastNameController.text.trim(),
          context: context,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student created successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> createUser({
    required String firstName,
    required String surName,
    required String email,
    required String program,
    required String coordinator,
    required BuildContext context,
  }) async {
    try {
      await FirebaseCloudStorage().createNewReferral(
        email: email,
        program: program,
        coordinator: coordinator,
        firstName: firstName,
        surName: surName,
      );

 await sendMailFromGmail(
          email,
          "Successfully Add As A Student", 
          """
Hello $firstName, 

Your account has been successfully add as a Student role on the ICMS App.

Thank you for being a valued member of our platform.

Best regards,  
The ICMS Team

""");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: [
                BlocProvider<UserDataBloc>(
                  create: (context) => UserDataBloc(
                    FirebaseCloudStorage(),
                  ),
                ),
                BlocProvider<PageIndexBloc>(
                  create: (context) => PageIndexBloc(),
                )
              ],
              child: const CoordinatorHomeScreen(),
            ),
          ),
        );
      }
    } catch (e) {
      throw Exception("Error creating user: $e");
    }
  }
}
