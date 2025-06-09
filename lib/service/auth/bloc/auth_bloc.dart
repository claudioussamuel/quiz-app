import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizeapp/service/user/user.dart';

import '../../user/firebase_cloud_storage.dart';
import '../auth_provider.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUnInitialized(isLoading: true)) {
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });

    // send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    // Register
    on<AuthEventRegister>((event, emit) async {
      FirebaseCloudStorage _userInfoService = FirebaseCloudStorage();
      final email = event.email;
      final password = event.password;

      try {
        await provider.createUser(
          email: email,
          password: password,
        );

        await provider.sendEmailVerification();
        await _userInfoService.createNewNote(
          user: UserInfo(
            firstName_: event.firstName,
            surname_: event.surname,
            email_: email,
            nameOfInstitution_: event.institution,
            yearOfGraduation_: event.yearOfGraduation,
            address_: event.address,
            phone_: event.phoneNumber,
            imageUrl_: event.imageUrl,
            gender_: event.gender,
            dateOfBirth_: event.dateOfBirth,
            title_: event.title,
            tertiary_: event.tertiary,
            city_: event.city,
            profession_: event.profession,
            country_: event.country,
          ),
        );

        emit(const AuthStateNeedsVerification(isLoading: false));
      } on Exception catch (e) {
        emit(
          AuthStateRegistering(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });

    // Initialize
    on<AuthEventInitialize>((event, emit) async {
      FirebaseCloudStorage _userInfoService = FirebaseCloudStorage();
      final user = provider.currentUser;
      if (user == null) {
        emit(AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        var role = await _userInfoService.fetchUserRole(user.email);

        emit(AuthStateLoggedIn(
          isLoading: false,
          user: user,
          role: role ?? "",
        ));
      }
    });

    // Login
    on<AuthEventLogIn>((event, emit) async {
      FirebaseCloudStorage _userInfoService = FirebaseCloudStorage();

      emit(
        AuthStateLoggedOut(
            exception: null,
            isLoading: true,
            loadingText: "Please wait while I log you in"),
      );

      final email = event.email;
      final password = event.password;

      try {
        final user = await provider.login(
          email: email,
          password: password,
        );

        if (!user.isEmailVerified) {
          emit(
            AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
          emit(const AuthStateNeedsVerification(
            isLoading: false,
          ));
        } else {
          // emit(
          //   AuthStateLoggedOut(
          //     exception: null,
          //     isLoading: false,
          //   ),
          // );
          var role = await _userInfoService.fetchUserRole(user.email);

          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
            role: role ?? "",
          ));
        }
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });

    // Log Out
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
        ));
      }
    });
    on<EventEditUserInfo>((event, emit) async {
      FirebaseCloudStorage firebaseCloudStorage = FirebaseCloudStorage();
      emit(const StateEditUserInfoLoading(isLoading: true));
      await firebaseCloudStorage.updateNote(user: event.userInfo);

      emit(const StateEditUserInfo(isLoading: false));
    });

    on<EventAdminEditUserInfo>((event, emit) async {
      FirebaseCloudStorage firebaseCloudStorage = FirebaseCloudStorage();
      emit(const StateEditUserInfoLoading(isLoading: true));
      await firebaseCloudStorage.updateNote(user: event.userInfo);

      emit(const StateEditAdminInfo(isLoading: false));
    });

    on<EventCoordinatorEditUserInfo>((event, emit) async {
      FirebaseCloudStorage firebaseCloudStorage = FirebaseCloudStorage();
      emit(const StateEditUserInfoLoading(isLoading: true));
      await firebaseCloudStorage.updateNote(user: event.userInfo);

      emit(const StateEditCoordinatorInfo(isLoading: false));
    });

    on<AuthEventForgotPassword>((event, emit) async {
      emit(
        const AuthStateForgotPassword(
          isLoading: false,
          hasSentEmail: false,
          exception: null,
        ),
      );
      final email = event.email;
      if (email == null) {
        return;
      }
      emit(
        const AuthStateForgotPassword(
          isLoading: true,
          hasSentEmail: false,
          exception: null,
        ),
      );
      bool didSendEmail;
      Exception? exception;

      try {
        await provider.sendPassedReset(toEmail: email);
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }
      emit(
        AuthStateForgotPassword(
          isLoading: false,
          hasSentEmail: didSendEmail,
          exception: exception,
        ),
      );
    });
  }
}
