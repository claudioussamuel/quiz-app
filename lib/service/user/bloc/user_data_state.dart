import 'package:flutter/foundation.dart' show immutable;
import '../user.dart';

@immutable
abstract class UserDataState {
  final bool isLoading;
  final String? loadingText;
  const UserDataState({
    required this.isLoading,
    this.loadingText = "Please wait a moment",
  });
}

class UserDataStateUnInitialized extends UserDataState {
  const UserDataStateUnInitialized({
    required super.isLoading,
  });
}

class UserDataStateLoading extends UserDataState {
  const UserDataStateLoading({
    required super.isLoading,
  });
}

class UserDataStateLoaded extends UserDataState {
  final List<UserInfo> userData;
  const UserDataStateLoaded({
    required super.isLoading,
    required this.userData,
  });
}

class UserDataByCoordinatorStateLoaded extends UserDataState {
  final List<UserInfo> userData;
  const UserDataByCoordinatorStateLoaded({
    required super.isLoading,
    required this.userData,
  });
}

class CoordinatorDataStateLoaded extends UserDataState {
  final List<UserInfo> userData; // Assuming UserData is a defined class
  const CoordinatorDataStateLoaded({
    required super.isLoading,
    required this.userData,
  });
}

class UserPendingDataStateLoaded extends UserDataState {
  final List<UserInfo> userData; // Assuming UserData is a defined class
  const UserPendingDataStateLoaded({
    required super.isLoading,
    required this.userData,
  });
}

class UserInActiveDataStateLoaded extends UserDataState {
  final List<UserInfo> userData; // Assuming UserData is a defined class
  const UserInActiveDataStateLoaded({
    required super.isLoading,
    required this.userData,
  });
}

class UserDataStateError extends UserDataState {
  final Exception? exception;
  const UserDataStateError({
    required super.isLoading,
    required this.exception,
  });
}

class UserDataStateUpdated extends UserDataState {
  final UserInfo updatedUserData; // Assuming UserData is a defined class
  const UserDataStateUpdated({
    required super.isLoading,
    required this.updatedUserData,
  });
}

class UserDataStateDeleted extends UserDataState {
  const UserDataStateDeleted({
    required super.isLoading,
  });
}
