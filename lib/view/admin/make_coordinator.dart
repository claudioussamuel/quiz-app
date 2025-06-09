import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import '../../service/page_index/bloc/page_index_bloc.dart';
import '../../service/user/bloc/user_data_bloc.dart';
import '../../service/user/firebase_cloud_storage.dart';
import 'admin_base_screen.dart';

class MakeCoordinator extends StatefulWidget {
  const MakeCoordinator({super.key});

  @override
  State<MakeCoordinator> createState() => _MakeCoordinatorState();
}

class _MakeCoordinatorState extends State<MakeCoordinator> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false; // Add loading state

  // creating smtp server for gmail
  final gmailSmtp = gmail("webofficerbruno@gmail.com", "pwmo sggt yvex xqvt");

  // send mail to user using smtp
  sendMailFromGmail(String sender, sub, text) async {
    final message = Message()
      ..from = Address("webofficerbruno@gmail.com", "ICMS Support Team")
      ..recipients.add(sender)
      ..subject = sub
      ..text = text;

    try {
      final sendReport = await send(message, gmailSmtp);
      print("Message sent: $sendReport");
    } on MailerException catch (e) {
      print("Message not sent.");

      for (var p in e.problems) {
        print("Problem: ${p.code} : ${p.msg}");
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });

      try {
        FirebaseApp tempApp = await Firebase.initializeApp(
            name: "flutter", options: Firebase.app().options);

        UserCredential newUser = await FirebaseAuth.instanceFor(app: tempApp)
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: "&1234!@#^&",
        );

        // Create coordinator in Firestore
        await FirebaseCloudStorage().createCoordinator(
          firstName: _firstNameController.text.trim(),
          surName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
        );

        await sendMailFromGmail(_emailController.text.trim(),
            "Successfully Add As A Coordinator", """
Hello ${_firstNameController.text.trim()}, 

Your account has been successfully upgraded to a **Coordinator** role on the ICMS App.

Thank you for being a valued member of our platform.

Best regards,  
The ICMS Team

""");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coordinator created successfully')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MultiBlocProvider(
                providers: [
                  BlocProvider<PageIndexBloc>(
                    create: (context) => PageIndexBloc(),
                  ),
                  BlocProvider<UserDataBloc>(
                    create: (context) => UserDataBloc(FirebaseCloudStorage()),
                  ),
                ],
                child: const AdminBaseScreen(),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Stop loading
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Coordinator',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Surname Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Sign Up'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
