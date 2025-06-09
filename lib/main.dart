import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quizeapp/service/auth/bloc/auth_bloc.dart';
import 'package:quizeapp/service/auth/firebase_auth_provider.dart';
import 'package:quizeapp/service/page_index/bloc/page_index_bloc.dart';
import 'package:quizeapp/service/select_image/bloc/select_image_bloc.dart';
import 'package:quizeapp/utils/theme/theme.dart';
import 'firebase_options.dart';
import 'service/auth/bloc/auth_event.dart';
import 'service/auth/bloc/auth_state.dart';
import 'service/user/bloc/user_data_bloc.dart';
import 'service/user/firebase_cloud_storage.dart';
import 'view/admin/admin_base_screen.dart';
import 'view/authentication/forgot_password_view.dart';
import 'view/authentication/login_view.dart';
import 'view/authentication/verify_email.dart';
import 'view/coordinatior/home_screen.dart';
import 'view/user/base_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  try {
    await dotenv.load();
  } catch (e) {
    print("Warning: .env file not found. Using default configuration.");
    // You can set default values here or continue without .env
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICMS App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              FirebaseAuthProvider(),
            ),
          ),
          BlocProvider<UserDataBloc>(
            create: (context) => UserDataBloc(
              FirebaseCloudStorage(),
            ),
          ),
          BlocProvider<SelectImageBloc>(
            create: (context) => SelectImageBloc(),
          ),
          BlocProvider<PageIndexBloc>(
            create: (context) => PageIndexBloc(),
          )
        ],
        child: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state.isLoading) {
        // LoadingScreen().show(
        //   context: context,
        //   text: "Please wait a moment",
        // );
        const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        //   LoadingScreen().hide();
      }
    }, builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        if (state.role == "admin") {
          return const AdminBaseScreen();
        } else if (state.role == "coordinator") {
          return const CoordinatorHomeScreen();
        } else if (state.role == "user") {
          return const BasicScreen();

          // return const AdminBaseScreen();
        } else {
          return Center(
            child: Text("See a Coordinator"),
          );
        }
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmailView();
      } else if (state is AuthStateLoggedOut) {
        return const LoginScreen();
        //  ProfileScreen();
      } else if (state is AuthStateForgotPassword) {
        return const ForgotPasswordView();
      }
      if (state is StateEditUserInfo) {
        return const BasicScreen();
      } else if (state is StateEditAdminInfo) {
        return const AdminBaseScreen();
      } else if (state is StateEditCoordinatorInfo) {
        return const CoordinatorHomeScreen();
      }
      //
      else {
        return const Scaffold(
            body: Center(
          child: CircularProgressIndicator(),
        ));
      }
    });
  }
}
