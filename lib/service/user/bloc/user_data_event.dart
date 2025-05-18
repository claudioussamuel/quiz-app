import 'package:flutter/foundation.dart';
import '../user.dart';

@immutable
abstract class UserDataEvent {
  const UserDataEvent();
}

class UserEventFetchUserData extends UserDataEvent {
  const UserEventFetchUserData();
}

class UserEventFetchUserDataByCoordinator extends UserDataEvent {
  final String email;
  const UserEventFetchUserDataByCoordinator({
    required this.email,
  });
}

class CoordinatorEventFetchUserData extends UserDataEvent {
  const CoordinatorEventFetchUserData();
}

class UserEventFetchUserDataInActive extends UserDataEvent {
  const UserEventFetchUserDataInActive();
}

class UserEventFetchUserDataActive extends UserDataEvent {
  const UserEventFetchUserDataActive();
}

class UserEventDeleteUserData extends UserDataEvent {
  final String userId;
  const UserEventDeleteUserData(this.userId);
}

class UserEventUpdateUserData extends UserDataEvent {
  final UserInfo updatedData;
  const UserEventUpdateUserData(this.updatedData);
}
