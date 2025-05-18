import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import '../auth_user.dart';
import 'auth_event.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = "Please wait a moment",
  });
}

class AuthStateUnInitialized extends AuthState {
  const AuthStateUnInitialized({
    required super.isLoading,
  });
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({
    required super.isLoading,
    required this.exception,
  });
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;

  const AuthStateForgotPassword({
    required super.isLoading,
    required this.hasSentEmail,
    required this.exception,
  });
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  final String role;
  const AuthStateLoggedIn({
    required super.isLoading,
    required this.user,
    required this.role,
  });
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({
    required super.isLoading,
  });
}

class StateEditUserInfo extends AuthState {
  const StateEditUserInfo({
    required super.isLoading,
  });
}

class StateEditUserInfoLoading extends AuthState {
  const StateEditUserInfoLoading({
    required super.isLoading,
  });
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  AuthStateLoggedOut({
    required this.exception,
    required bool isLoading,
    String? loadingText,
  }) : super(
          loadingText: loadingText,
          isLoading: isLoading,
        );

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String surname;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth;
  final String title;
  final String address;
  final String institution;
  final String city;
  final String country;
  final String qualification;
  final String tertiary;
  final String yearOfGraduation;
  final String imageUrl;
  final String profession;

  const AuthEventRegister({
    required this.email,
    required this.password,
    required this.firstName,
    required this.surname,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.title,
    required this.address,
    required this.institution,
    required this.city,
    required this.country,
    required this.qualification,
    required this.tertiary,
    required this.yearOfGraduation,
    required this.imageUrl,
    required this.profession,
  });
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}
