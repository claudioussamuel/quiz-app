import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../service/auth/bloc/auth_bloc.dart';
import '../../service/auth/bloc/auth_event.dart';
import '../../service/auth/bloc/auth_state.dart';
import '../../service/user/firebase_cloud_storage.dart';
import '../../service/user/user.dart';
import '../../utils/constants/size.dart';
import '../../utils/dialogs/error_dialog.dart';
import '../../utils/dialogs/password_reset_email_sent_dialog.dart';
import '../../utils/dialogs/verify_email_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;
  late final TextEditingController _phoneController;
  late final FirebaseCloudStorage _userInfoService;
  UserInfo? _userInfo;

  @override
  void initState() {
    _userInfoService = FirebaseCloudStorage();
    _controller = TextEditingController();
    _phoneController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            await showErrorDialog(
              context,
              "We could not process your request. Please make sure that you are a registered user",
            );
          }
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: TSizes.defaultSpace, left: TSizes.md, right: TSizes.md),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: Column(
                  children: [
                    Text(
                      "Forgot Password",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: TSizes.defaultSpace),
                    Text(
                      "If you forgot your password, simply enter your email or phone number",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: TSizes.defaultSpace),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      autofocus: true,
                      controller: _controller,
                      decoration: const InputDecoration(hintText: "Your Email"),
                    ),
                    const SizedBox(height: TSizes.defaultSpace),
                    Text(
                      "OR",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: TSizes.defaultSpace),
                    TextField(
                      keyboardType: TextInputType.phone,
                      autocorrect: false,
                      controller: _phoneController,
                      decoration:
                          const InputDecoration(hintText: "Your Phone Number"),
                    ),
                    const SizedBox(height: TSizes.defaultSpace),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          child: const Text(
                            "Send me Password reset link",
                          ),
                          onPressed: () async {
                            final email = _controller.text.trim();
                            final phoneNumber = _phoneController.text.trim();

                            if (email.isEmpty) {
                              // Fetch user info using phone number if email is empty
                              _userInfo = await _userInfoService
                                  .fetchUserInfoStreamByPhoneNumber(phoneNumber)
                                  .first;
                            } else {
                              // Fetch user info using email
                              _userInfo = await _userInfoService
                                  .fetchUserInfoStreamByEmail(email)
                                  .first;
                            }

                            if (context.mounted) {
                              final shouldVerify = await showVerifyEmailDialog(
                                context,
                                "${_userInfo?.firstName_ ?? "User Not Found"} ${_userInfo?.surname_ ?? ""}",
                              );

                              if (shouldVerify) {
                                if (context.mounted) {
                                  context.read<AuthBloc>().add(
                                        AuthEventForgotPassword(
                                          email: "${_userInfo?.email_}",
                                        ),
                                      );
                                }
                              }
                            }
                          }),
                    ),
                    const SizedBox(height: TSizes.defaultSpace),
                    TextButton(
                      child: const Text(
                        "Back to login page",
                      ),
                      onPressed: () {
                        context.read<AuthBloc>().add(
                              const AuthEventLogOut(),
                            );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
