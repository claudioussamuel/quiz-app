import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cohortController = TextEditingController();

  // Define the necessary variables
  String? _selectedCategoryId; // To hold the selected category ID
  Category? _initialCategory; // To hold the initial category
  List<Category> _categories = []; // To hold the list of categories

  String? getCurrentUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.email;
  }

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
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    ///emailController.text = getCurrentUserEmail() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Student',
          style: Theme.of(
            context,
          ).textTheme.titleMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: TSizes.fontSizeMd,
            ),
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            const SizedBox(
              height: TSizes.fontSizeMd,
            ),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Surname'),
            ),
            const SizedBox(
              height: TSizes.fontSizeMd,
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(
              height: TSizes.fontSizeMd,
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
            const SizedBox(
              height: TSizes.fontSizeMd,
            ),
            TextField(
              controller: cohortController,
              decoration: const InputDecoration(labelText: 'Cohort'),
            ),
            const SizedBox(
              height: TSizes.fontSizeMd,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: () async {
                  await createUser(
                    program: _selectedCategoryId ?? "",
                    email: emailController.text,
                    cohort: cohortController.text,
                    coordinator: getCurrentUserEmail() ?? "",
                    firstName: firstNameController.text,
                    surName: lastNameController.text,
                    context: context,
                  );
                },
                child: const Text('Create User'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createUser({
    required String firstName,
    required String surName,
    required String email,
    required String program,
    required String cohort,
    required String coordinator,
    required BuildContext context,
  }) async {
    try {
      await FirebaseCloudStorage().createNewReferral(
        cohort: cohort,
        email: email,
        program: program,
        coordinator: coordinator,
        firstName: firstName,
        surName: surName,
      );

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
    } catch (e) {
      print(
        "Error creating user: $e",
      );
    }
  }
}
