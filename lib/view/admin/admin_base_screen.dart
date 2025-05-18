import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quizeapp/service/user/firebase_cloud_storage.dart';
import 'package:quizeapp/view/admin/admin_home_screen.dart';
import 'package:quizeapp/view/admin/coordinator.dart';
import 'package:quizeapp/view/admin/users_screen.dart';
import 'package:quizeapp/view/user/profile_screen.dart';
import '../../service/auth/bloc/auth_bloc.dart';
import '../../service/auth/bloc/auth_event.dart';
import '../../service/page_index/bloc/page_index_bloc.dart';
import '../../service/page_index/bloc/page_index_event.dart';
import '../../service/page_index/bloc/page_index_state.dart';
import '../../service/user/bloc/user_data_bloc.dart';
import '../../utils/dialogs/logout_dialog.dart';
import 'exam_score_screen.dart';
import 'make_coordinator.dart';
import 'user_scree.dart';

class AdminBaseScreen extends StatefulWidget {
  const AdminBaseScreen({super.key});

  @override
  State<AdminBaseScreen> createState() => _AdminBaseScreenState();
}

class _AdminBaseScreenState extends State<AdminBaseScreen> {
  final pages = [
    const AdminHomeScreen(),
    const UsersScreen(),
    const CoordinatorScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final changePageBloc = context.read<PageIndexBloc>();
    return BlocBuilder<PageIndexBloc, PageIndexState>(
      builder: (context, state) {
        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 840,
              ),
              child: Scaffold(
                // appBar: AppBar(
                //   title: Text(
                //     "Exams App",
                //     style: Theme.of(
                //       context,
                //     ).textTheme.titleLarge,
                //   ),
                //   centerTitle: true,
                //   backgroundColor: AppTheme.primaryColor,
                // ),
                drawer: Drawer(
                  child: ListView(
                    children: [
                      DrawerHeader(
                        child: Center(
                          child: Text(
                            "Menu",
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge!.copyWith(
                                  fontSize: 25,
                                ),
                          ),
                        ),
                      ),
                      //
                      InkWell(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => UserDataBloc(
                                  FirebaseCloudStorage(),
                                ),
                                child: const ExamScoreScreen(),
                              ),
                            ),
                          );
                        },
                        child: const ListTile(
                          leading: Icon(
                            Iconsax.document,
                          ),
                          title: Text(
                            "Quiz Scores",
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => UserDataBloc(
                                  FirebaseCloudStorage(),
                                ),
                                child: const MakeCoordinator(),
                              ),
                            ),
                          );
                        },
                        child: const ListTile(
                          leading: Icon(
                            Iconsax.user,
                          ),
                          title: Text(
                            "Make Coordinator",
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final shouldLogout = await showLogOutDialog(
                            context,
                          );
                          //  devtools.log(shouldLogout.toString());

                          if (shouldLogout) {
                            if (context.mounted) {
                              context.read<AuthBloc>().add(
                                    const AuthEventLogOut(),
                                  );
                            }
                          }
                        },
                        child: const ListTile(
                          leading: Icon(Iconsax.logout),
                          title: Text("Logout"),
                        ),
                      ),
                    ],
                  ),
                ),
                body: pages[state.index],
                bottomNavigationBar: NavigationBar(
                  selectedIndex: state.index,
                  onDestinationSelected: (int index) {
                    changePageBloc.add(ChangePageIndex(index: index));
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Iconsax.home),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Iconsax.people),
                      label: 'students',
                    ),
                    NavigationDestination(
                      icon: Icon(Iconsax.people),
                      label: 'Coordinators',
                    ),
                    NavigationDestination(
                      icon: Icon(Iconsax.user),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
