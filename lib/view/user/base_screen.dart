import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quizeapp/view/user/home_screen.dart';
import 'package:quizeapp/view/user/profile_screen.dart';

import '../../service/auth/bloc/auth_bloc.dart';
import '../../service/auth/bloc/auth_event.dart';
import '../../service/page_index/bloc/page_index_bloc.dart';
import '../../service/page_index/bloc/page_index_event.dart';
import '../../service/page_index/bloc/page_index_state.dart';
import '../../theme/theme.dart';
import '../../utils/dialogs/logout_dialog.dart';
import 'quiz_score_screen.dart';

class BasicScreen extends StatefulWidget {
  const BasicScreen({super.key});

  @override
  State<BasicScreen> createState() => _BasicScreenState();
}

class _BasicScreenState extends State<BasicScreen> {
  final pages = [
    const HomeScreen(),
    const QuizScoreScreen(),
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
                    "Exams App",
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge,
                  ),
                  centerTitle: true,
                  backgroundColor: AppTheme.primaryColor,
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
                      icon: Icon(Iconsax.document),
                      label: 'Results',
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
