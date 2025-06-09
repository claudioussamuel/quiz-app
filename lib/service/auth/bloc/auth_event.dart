import 'package:flutter/foundation.dart';
import '../../user/user.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogIn(this.email, this.password);
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({this.email});
}

class EventEditUserInfo extends AuthEvent {
  final UserInfo userInfo;

  const EventEditUserInfo({
    required this.userInfo,
  });
}

class EventAdminEditUserInfo extends AuthEvent {
  final UserInfo userInfo;

  const EventAdminEditUserInfo({
    required this.userInfo,
  });
}

class EventCoordinatorEditUserInfo extends AuthEvent {
  final UserInfo userInfo;

  const EventCoordinatorEditUserInfo({
    required this.userInfo,
  });
}

class EventDeleteUserInfo extends AuthEvent {
  final String userId;

  const EventDeleteUserInfo({
    required this.userId,
  });
}
