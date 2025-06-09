import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../service/user/bloc/user_data_bloc.dart';
import '../../service/user/bloc/user_data_event.dart';
import '../../service/user/bloc/user_data_state.dart';
import '../../utils/device/device_utility.dart';
import '../../utils/theme/theme.dart';
import '../admin/notification_card.dart';
import 'user_creation_screen.dart'; // Import the new screen
import 'user_info_coordinator.dart'; // Import the new screen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedMembership;

  @override
  void initState() {
    BlocProvider.of<UserDataBloc>(context).add(
      UserEventFetchUserDataByCoordinator(
        email: FirebaseAuth.instance.currentUser?.email ?? "",
      ),
    );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserCreationScreen(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
        ),
      ),
      body: BlocBuilder<UserDataBloc, UserDataState>(
        builder: (context, state) {
          if (state is UserDataStateLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserDataByCoordinatorStateLoaded) {
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
                    decoration: const InputDecoration(
                      hintText: 'Search Your Referrals',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserInfoCoordinator(
                                    userEmail: user.email_ ?? ""),
                              ),
                            );
                          },
                          child: NotificationItemCard(
                            isDarkMode: TDeviceUtils.getMode(context),
                            theme: TAppTheme.darkTheme,
                            firstName: user.firstName_,
                            surname: user.surname_,
                            email: user.email_,
                            image: user.imageUrl_,
                          ),
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
