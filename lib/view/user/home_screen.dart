import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizeapp/modal/category.dart';
import 'package:quizeapp/service/auth/auth_service.dart';
import 'package:quizeapp/service/user/user.dart';
import '../../service/user/firebase_cloud_storage.dart';
import '../../theme/theme.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];

  List<String> _categoryFilters = ["All"];
  String _selectedFilter = "All";

  final FirebaseCloudStorage _userInfoService = FirebaseCloudStorage();
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    UserInfo? user =
        await _userInfoService.fetchUserInfoStreamByEmail(userEmail).first;
    print("Claudious ${user?.program}");
    final snapshot = await FirebaseFirestore.instance
        .collection(
          'categories',
        )
        .get();

    setState(() {
      _allCategories = snapshot.docs
          .map((doc) {
            if (doc.id == user?.program) {
              return Category.fromMap(
                doc.id,
                doc.data(),
              );
            } else {
              return null;
            }
          })
          .where((category) => category != null)
          .cast<Category>()
          .toList();
      _filteredCategories = _allCategories;
      _categoryFilters = _allCategories
          .map(
            (e) => e.name,
          )
          .toSet()
          .toList();
    });
  }

  // Future<void> _fetchCategories() async {
  //   final snapshot = await FirebaseFirestore.instance
  //       .collection('categories')
  //       .orderBy(
  //         'createdAt',
  //         descending: true,
  //       )
  //       .get();

  //   setState(() {
  //     _allCategories = snapshot.docs
  //         .map(
  //           (doc) => Category.fromMap(
  //             doc.id,
  //             doc.data(),
  //           ),
  //         )
  //         .toList();
  //     _filteredCategories = _allCategories;
  //     _categoryFilters = ["All"] +
  //         _allCategories
  //             .map(
  //               (e) => e.name,
  //             )
  //             .toSet()
  //             .toList();
  //   });
  // }

  void _filterCategories(String query, {String? categoryFilter}) {
    setState(() {
      _filteredCategories = _allCategories.where((category) {
        final categoryName = category.name.toLowerCase();
        final searchLower = query.toLowerCase();
        final categoryFilterLower = categoryFilter?.toLowerCase() ?? "";

        final isCategoryMatch = categoryFilter == "All" ||
            categoryName.contains(categoryFilterLower);

        return isCategoryMatch && categoryName.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 225,
            pinned: true,
            floating: true,
            centerTitle: false,
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            // title: Text(
            //   "Exams App",
            //   style: TextStyle(
            //     fontSize: 20,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.white,
            //   ),
            // ),
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome, Learner!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Let's take this exams",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (query) {
                            _filterCategories(query);
                          },
                          decoration: InputDecoration(
                            hintText: "Search Cohort...",
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppTheme.primaryColor,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: AppTheme.primaryColor,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterCategories("");
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              collapseMode: CollapseMode.pin,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categoryFilters.length,
                itemBuilder: (context, index) {
                  final filter = _categoryFilters[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: _selectedFilter == filter
                              ? Colors.white
                              : AppTheme.primaryColor,
                        ),
                      ),
                      selected: _selectedFilter == filter,
                      selectedColor: AppTheme.primaryColor,
                      backgroundColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                          _filterCategories(
                            _searchController.text,
                            categoryFilter: filter,
                          );
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _filteredCategories.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        "No Cohort found.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      // childAspectRatio: 0.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = _filteredCategories[index];

                        return _buildCategoryCard(
                          category,
                          index,
                        );
                      },
                      childCount: _filteredCategories.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 100 + index),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(0, index.isEven ? 0 : -10, 0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryScreen(
                  category: category,
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(
                    Icons.quiz,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  category.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
