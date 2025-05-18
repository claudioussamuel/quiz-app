import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../service/auth/bloc/auth_bloc.dart';
import '../../service/auth/bloc/auth_event.dart';
import '../../service/auth/bloc/auth_state.dart';
import '../../utils/constants/size.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(
              top: TSizes.defaultSpace, left: TSizes.md, right: TSizes.md),
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.message, size: TSizes.defaultSpace * 3),
              const SizedBox(height: TSizes.defaultSpace),
              const Text(
                "We've sent you an email verification. Please open it and verify your account",
              ),
              const SizedBox(height: TSizes.defaultSpace),
              const Text(
                  "If you haven't received a verification email yet, press the button below"),
              const SizedBox(height: TSizes.defaultSpace),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    context
                        .read<AuthBloc>()
                        .add(const AuthEventSendEmailVerification());
                  },
                  child: const Text("Send email verification"),
                ),
              ),
              const SizedBox(height: TSizes.defaultSpace),
              TextButton(
                  onPressed: () async {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  child: const Text("Login"))
            ],
          ),
        ),
      ),
    );
  }
}
