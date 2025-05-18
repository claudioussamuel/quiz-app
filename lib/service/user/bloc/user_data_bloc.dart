import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../firebase_cloud_storage.dart';
import '../user.dart';
import 'user_data_event.dart';
import 'user_data_state.dart';

class UserDataBloc extends Bloc<UserDataEvent, UserDataState> {
  final FirebaseCloudStorage _firestoreService;
  UserDataBloc(this._firestoreService)
      : super(
          const UserDataStateUnInitialized(
            isLoading: true,
          ),
        ) {
    on<UserEventFetchUserData>((event, emit) async {
      emit(const UserDataStateLoading(isLoading: true));
      try {
        // Fetch user data logic here
        List<UserInfo> userData = await _firestoreService.getUserData();
        print("Manhatten ${userData.length}");

        emit(UserDataStateLoaded(isLoading: false, userData: userData));
      } on Exception catch (e) {
        emit(UserDataStateError(isLoading: false, exception: e));
      }
    });

    on<UserEventFetchUserDataByCoordinator>((event, emit) async {
      emit(const UserDataStateLoading(isLoading: true));
      try {
        // Fetch user data logic here
        List<UserInfo> userData =
            await _firestoreService.getUserPerCoordinatorData(
          event.email,
        );

        emit(
          UserDataByCoordinatorStateLoaded(
            isLoading: false,
            userData: userData,
          ),
        );
      } on Exception catch (e) {
        emit(UserDataStateError(isLoading: false, exception: e));
      }
    });

    on<CoordinatorEventFetchUserData>((event, emit) async {
      emit(const UserDataStateLoading(isLoading: true));
      try {
        // Fetch user data logic here
        List<UserInfo> userData = await _firestoreService.getCoordinatorData();
        print("Manhatten ${userData.length}");

        emit(CoordinatorDataStateLoaded(isLoading: false, userData: userData));
      } on Exception catch (e) {
        emit(UserDataStateError(isLoading: false, exception: e));
      }
    });
  }
}
