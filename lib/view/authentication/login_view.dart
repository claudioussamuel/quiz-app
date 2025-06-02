import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../service/auth/auth_exceptions.dart';
import '../../service/auth/bloc/auth_bloc.dart';
import '../../service/auth/bloc/auth_event.dart';
import '../../service/auth/bloc/auth_state.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/size.dart';
import '../../utils/constants/text_string.dart';
import '../../utils/device/device_utility.dart';
import '../../utils/dialogs/error_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController email;
  late TextEditingController password;

  @override
  void initState() {
    email = TextEditingController();
    password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  // Add this variable to track password visibility
  bool _isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    final dark = TDeviceUtils.getMode(context);
    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthStateLoggedOut) {
            if (state.exception is UserNotFoundAuthException) {
              await showErrorDialog(context, "User not found");
            }
            if (state.exception is WrongPasswordAuthException) {
              if (context.mounted) {
                await showErrorDialog(context, "Wrong Credentials");
              }
            }
            // else {
            //   if (context.mounted) {
            //     await showErrorDialog(context, "Authentication Error");
            //   }
            // }
          }
        },
        child: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      2 * TSizes.buttomHeight,
                  maxWidth: 840,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(TSizes.buttomHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image(
                            //   width: 100,
                            //   image: AssetImage(
                            //     dark ? TImage.lightApplogo : TImage.darkApplogo,
                            //   ),
                            // ),
                            Text(
                              TText.loginTitle,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(
                              height: TSizes.sm,
                            ),
                            Text(
                              TText.loginSubTitle,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),

                        //Forms
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: TSizes.spaceBtwItems),
                          child: Form(
                            child: Column(
                              children: [
                                // Email
                                TextFormField(
                                  controller: email,
                                  decoration: const InputDecoration(
                                    labelText: TText.email,
                                    prefixIcon: Icon(
                                      Iconsax.direct_right,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),
                                // Password
                                TextFormField(
                                  controller: password,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: TText.password,
                                    prefixIcon: const Icon(
                                      Iconsax.password_check,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Iconsax.eye
                                            : Iconsax.eye_slash,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),

                                // Remember me and forget Password
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        context.read<AuthBloc>().add(
                                              const AuthEventForgotPassword(),
                                            );
                                      },
                                      child: const Text(TText.forgetPassword),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwItems,
                                ),
                                //Login
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final email = this.email.text;
                                      final password = this.password.text;

                                      context.read<AuthBloc>().add(
                                            AuthEventLogIn(
                                              email.trim(),
                                              password.trim(),
                                            ),
                                          );
                                    },
                                    child: const Text(TText.signIn),
                                  ),
                                ),
                                const SizedBox(
                                  height: TSizes.spaceBtwSections,
                                ),
                               
                               
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
