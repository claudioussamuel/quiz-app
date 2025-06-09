import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizeapp/view/user/widget.dart';
import '../../service/auth/auth_service.dart';
import '../../service/auth/bloc/auth_bloc.dart';
import '../../service/select_image/bloc/select_image_bloc.dart';
import '../../service/select_image/bloc/select_image_event.dart';
import '../../service/user/firebase_cloud_storage.dart';
import '../../utils/constants/size.dart';
import '../user/heading_section.dart';
import 'edit_profile_screen.dart';

class CoordinatorProfileScreen extends StatefulWidget {
  const CoordinatorProfileScreen({super.key});

  @override
  State<CoordinatorProfileScreen> createState() =>
      _CoordinatorProfileScreenState();
}

class _CoordinatorProfileScreenState extends State<CoordinatorProfileScreen> {
  late final FirebaseCloudStorage _userInfoService;
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  Widget build(BuildContext context) {
    _userInfoService = FirebaseCloudStorage();
    return StreamBuilder(
        stream: _userInfoService.fetchUserInfoStreamByEmail(userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.waiting:
              if (snapshot.hasData) {
                final userInfo = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
                  child: ListView(
                    children: [
                      // Profile Picture
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.black,
                              backgroundImage: CachedNetworkImageProvider(
                                  userInfo?.imageUrl_ ?? ""),
                              radius: 64,
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<SelectImageBloc>().add(
                                      SelectImageEventFireStore(
                                        imageSource: userInfo?.imageUrl_ ?? "",
                                      ),
                                    );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider.value(
                                          value:
                                              BlocProvider.of<SelectImageBloc>(
                                                  context),
                                        ),
                                        BlocProvider.value(
                                          value: BlocProvider.of<AuthBloc>(
                                            context,
                                          ),
                                        ),
                                      ],
                                      child: EditCoordinatorProfileScreen(
                                        userInfo: userInfo!,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                "Edit Profile Info",
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: TSizes.spaceBtwItems / 2,
                      ),
                      const Divider(),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      const TSectionHeading(
                        showActionButton: false,
                        title: "Personal Information",
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      ProfileMenu(
                        title: "First Name",
                        value: userInfo?.firstName_ ?? "",
                        onTap: () {},
                      ),
                      ProfileMenu(
                        title: "Surname",
                        value: userInfo?.surname_ ?? "",
                        onTap: () {},
                      ),
                      ProfileMenu(
                        title: "Email",
                        value: userInfo?.email_ ?? "",
                        onTap: () {},
                      ),
                      ProfileMenu(
                        title: "Phone",
                        value: userInfo?.phone_ ?? "",
                        onTap: () {},
                      ),
                      const Divider(),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      const TSectionHeading(
                        showActionButton: false,
                        title: "Academic Information",
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),
                      ProfileMenu(
                        title: "Tertiary",
                        value: userInfo?.tertiary_ ?? "",
                        onTap: () {},
                      ),
                      ProfileMenu(
                        title: "University Education",
                        value: "First Degree",
                        onTap: () {},
                      ),

                      ProfileMenu(
                        title: "Grad",
                        value: userInfo?.yearOfGraduation_ ?? "",
                        onTap: () {},
                      ),

                      const TSectionHeading(
                        showActionButton: false,
                        title: "Membership Details",
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      ProfileMenu(
                        title: "Mem. Type",
                        value: userInfo?.membership ?? "",
                        onTap: () {},
                      ),
                      ProfileMenu(
                        title: "Address",
                        value: userInfo?.address_ ?? "",
                        onTap: () {},
                      ),
                      ProfileMenu(
                        title: "City",
                        value: userInfo?.city_ ?? "",
                        onTap: () {},
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        });
  }
}
