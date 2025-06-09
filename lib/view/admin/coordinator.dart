import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizeapp/utils/device/device_utility.dart';
import 'package:quizeapp/utils/theme/theme.dart';
import 'package:quizeapp/view/admin/notification_card.dart';
import '../../service/user/bloc/user_data_bloc.dart';
import '../../service/user/bloc/user_data_event.dart';
import '../../service/user/bloc/user_data_state.dart';
import 'make_coordinator.dart';

class CoordinatorScreen extends StatefulWidget {
  const CoordinatorScreen({super.key});

  @override
  State<CoordinatorScreen> createState() => _CoordinatorScreenState();
}

class _CoordinatorScreenState extends State<CoordinatorScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedMembership;

  @override
  void initState() {
    BlocProvider.of<UserDataBloc>(context).add(
      const CoordinatorEventFetchUserData(),
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
      // appBar: AppBar(
      //   title: Text(
      //     "Admin Dashboard",
      //     style: Theme.of(context).textTheme.titleMedium,
      //   ),
      //   centerTitle: true,
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const MakeCoordinator()));
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<UserDataBloc, UserDataState>(
        builder: (context, state) {
          if (state is UserDataStateLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CoordinatorDataStateLoaded) {
            final coordinators = state.userData;
            final searchQuery = _searchController.text.toLowerCase();

            final filteredCoordinators = coordinators.where((coordinator) {
              final matchesSearch = coordinator.firstName_!
                      .toLowerCase()
                      .contains(searchQuery) ||
                  coordinator.surname_!.toLowerCase().contains(searchQuery) ||
                  (coordinator.email_?.toLowerCase().contains(searchQuery) ??
                      false);

              final matchesMembership = _selectedMembership == null ||
                  coordinator.membership?.toLowerCase() ==
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
                      hintText: 'Search All Coordinators',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredCoordinators.length,
                    itemBuilder: (context, index) {
                      final coordinator = filteredCoordinators[index];
                      return Padding(
                        padding: const EdgeInsets.all(8),
                        child: NotificationItemCard(
                          isDarkMode: TDeviceUtils.getMode(context),
                          theme: TAppTheme.darkTheme,
                          firstName: coordinator.firstName_,
                          surname: coordinator.surname_,
                          email: coordinator.email_,
                          image: coordinator.imageUrl_,
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
