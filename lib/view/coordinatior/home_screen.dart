import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../service/auth/bloc/auth_bloc.dart';
import '../../service/auth/bloc/auth_event.dart';
import '../../service/page_index/bloc/page_index_bloc.dart';
import '../../service/page_index/bloc/page_index_event.dart';
import '../../service/page_index/bloc/page_index_state.dart';
import '../../theme/theme.dart';
import '../../utils/dialogs/logout_dialog.dart';
import '../user/profile_screen.dart';
import 'main_screen.dart';

class CoordinatorHomeScreen extends StatefulWidget {
  const CoordinatorHomeScreen({super.key});

  @override
  State<CoordinatorHomeScreen> createState() => _CoordinatorHomeScreenState();
}

class _CoordinatorHomeScreenState extends State<CoordinatorHomeScreen> {
  final pages = [
    const MainScreen(),
    Container(),
    Container(),
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
              constraints: const BoxConstraints(maxWidth: 840),
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    "Coordinator App",
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge,
                  ),
                  centerTitle: true,
                 
                ),
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
                      InkWell(
                        onTap: () async {
                          final shouldLogout = await showLogOutDialog(context);
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
                      icon: Icon(Iconsax.calendar_tick),
                      label: 'Events',
                    ),
                    NavigationDestination(
                      icon: Icon(Iconsax.document),
                      label: 'Receipts',
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
