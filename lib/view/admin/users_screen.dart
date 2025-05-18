import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizeapp/view/admin/notification_card.dart';
import '../../modal/category.dart';
import '../../theme/theme.dart';
import '../../utils/device/device_utility.dart';
import '../../utils/theme/theme.dart';

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
        centerTitle: true,
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
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: NotificationItemCard(
                        isDarkMode: TDeviceUtils.getMode(context),
                        theme: TAppTheme.darkTheme,
                        firstName: userData['Firstname'] ?? '',
                        surname: userData['Surname'] ?? '',
                        email: userData['email'] ?? '',
                        image: userData['image_url'],
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
