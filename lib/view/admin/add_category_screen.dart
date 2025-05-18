import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quizeapp/modal/category.dart';

import '../../theme/theme.dart';

class AddCategoryScreen extends StatefulWidget {
  final Category? category;
  const AddCategoryScreen({super.key, this.category});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _descriptionController =
        TextEditingController(text: widget.category?.description);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      if (widget.category != null) {
        final updateCategory = widget.category!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );

        await _firebase
            .collection("categories")
            .doc(widget.category!.id)
            .update(
              updateCategory.toMap(),
            );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cohort updated successfully"),
          ),
        );
      } else {
        await _firebase.collection("categories").add(
              Category(
                name: _nameController.text.trim(),
                createdAt: DateTime.now(),
                description: _descriptionController.text.trim(),
                id: _firebase
                    .collection(
                      "categories",
                    )
                    .doc()
                    .id,
              ).toMap(),
            );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cohort added successfully"),
          ),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_nameController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Discard Changes"),
              content: const Text("Are you sure you want to discard changes?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text(
                    "Cancel",
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    "Discard",
                    style: TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                )
              ],
            ),
          ) ??
          false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.category == null ? "Add Cohort" : "Edit Cohort",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(
                20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cohort Name",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Create a cohort for organizing your quizzes",
                      style: TextStyle(
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                        fillColor: Colors.white,
                        labelText: "Cohort Name",
                        hintText: "Enter cohort name",
                        prefixIcon: Icon(
                          Icons.category_rounded,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Cohort name is required" : null,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                        labelText: "Description",
                        hintText: "Enter description",
                        prefixIcon: Icon(
                          Icons.description_rounded,
                          color: AppTheme.primaryColor,
                        ),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      validator: (value) => value!.isEmpty
                          ? "Cohort description is required"
                          : null,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveCategory,
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.category != null
                                    ? "Update Cohort"
                                    : "Add Cohort",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
          //   _isLoading
          //       ? const Center(
          //           child: CircularProgressIndicator(),
          //         )
          //       : Padding(
          //           padding: const EdgeInsets.all(16.0),
          //           child: Form(
          //             key: _formKey,
          //             child: Column(
          //               children: [
          //                 TextFormField(
          //                   controller: _nameController,
          //                   decoration: const InputDecoration(
          //                     labelText: "Category Name",
          //                   ),
          //                   validator: (value) {
          //                     if (value!.isEmpty) {
          //                       return "Category name is required";
          //                     }
          //                     return null;
          //                   },
          //                 ),
          //                 const SizedBox(
          //                   height: 16.0,
          //                 ),
          //                 TextFormField(
          //                   controller: _descriptionController,
          //                   decoration: const InputDecoration(
          //                     labelText: "Category Description",
          //                   ),
          //                   validator: (value) {
          //                     if (value!.isEmpty) {
          //                       return "Category description is required";
          //                     }
          //                     return null;
          //                   },
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          ),
    );
  }
}
