import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../service/user/bloc/user_data_bloc.dart';
import '../../service/user/bloc/user_data_event.dart';
import '../../service/user/bloc/user_data_state.dart';
import '../../service/user/firebase_cloud_storage.dart';
import 'notification_card.dart';

class MakeCoordinator extends StatefulWidget {
  const MakeCoordinator({super.key});

  @override
  State<MakeCoordinator> createState() => _MakeCoordinatorState();
}

class _MakeCoordinatorState extends State<MakeCoordinator> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedMembership;

  @override
  void initState() {
    BlocProvider.of<UserDataBloc>(context).add(const UserEventFetchUserData());
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: Theme.of(
            context,
          ).textTheme.titleMedium,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<UserDataBloc, UserDataState>(
        builder: (context, state) {
          if (state is UserDataStateLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UserDataStateLoaded) {
            final users = state.userData;
            final searchQuery = _searchController.text.toLowerCase();

            final filteredUsers = users.where((user) {
              final matchesSearch = user.firstName_!
                      .toLowerCase()
                      .contains(searchQuery) ||
                  user.surname_!.toLowerCase().contains(searchQuery) ||
                  (user.email_?.toLowerCase().contains(searchQuery) ?? false);

              final matchesMembership = _selectedMembership == null ||
                  user.membership?.toLowerCase() ==
                      _selectedMembership?.toLowerCase();

              return matchesSearch && matchesMembership;
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search All Users',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: NotificationItemCard(
                          isDarkMode:
                              Theme.of(context).brightness == Brightness.dark,
                          theme: Theme.of(context),
                          firstName: user.firstName_,
                          surname: user.surname_,
                          email: user.email_,
                          image: user.imageUrl_,
                          showTrailing: true,
                          onTrailingPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Action'),
                                  content: Text(
                                      'Do you want to make ${user.firstName_} ${user.surname_} a coordinator?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          await FirebaseCloudStorage()
                                              .changeUserRoleToCoordinator(
                                                  user.email_!);
                                          Navigator.of(context).pop();
                                        } catch (e) {
                                          print("Error changing user role: $e");
                                        }
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is UserDataStateError) {
            return Center(child: Text('Error: ${state.exception}'));
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
