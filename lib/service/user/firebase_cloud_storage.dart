import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart';
import 'user_storage_constants.dart';
import 'cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection("users");

  Future<void> updateNote({required UserInfo user}) async {
    try {
      await notes.doc(user.ownerUserId).update(user.toMap());
    } catch (_) {
      throw CouldNotUpdateUserException();
    }
  }

  Future<List<UserInfo>> getUserData() async {
    final snapshot = await notes
        // .orderBy(
        //   "Firstname",
        // )
        .where(
          'role',
          isEqualTo: 'user',
        )
        .get(); // Fetching data once
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      return UserInfo.fromSnapshot(doc);
    }).toList();
  }

  Future<List<UserInfo>> getUserPerCoordinatorData(
    String email,
  ) async {
    final snapshot = await notes
        .where(
          'coordinator',
          isEqualTo: email,
        )
        .get();
    return snapshot.docs.map((doc) {
      //  Map<String, dynamic> data = doc.data();
      return UserInfo.fromSnapshot(doc);
    }).toList();
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (_) {
      throw CouldNotDeleteUserException();
    }
  }

  Stream<Iterable<UserInfo>> allNotes({required String ownerUserId}) {
    final allNote = notes
        .where(ownerUserIdFieldNameConst, isEqualTo: ownerUserId)
        .snapshots()
        .map(
          (event) => event.docs.map(
            (doc) => UserInfo.fromSnapshot(
              doc,
            ),
          ),
        );

    return allNote;
  }

  Future<Iterable<UserInfo>> getNotes({
    required String ownerUserId,
  }) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldNameConst,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map((doc) {
              return UserInfo.fromSnapshot(doc);
            }),
          );
    } catch (e) {
      throw CouldNotGetAllUsersException();
    }
  }

  Future<UserInfo?> fetchUserInfo(String documentId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await notes.doc(documentId).get();

      if (doc.exists) {
        return UserInfo.fromSnapshot(doc);
      } else {
        print("Document does not exist");
        return null;
      }
    } catch (e) {
      print("Error fetching user info: $e");
      return null;
    }
  }

  updateQuizScoreByEmail(
    String email,
    String quizName,
    int newScore,
  ) async {
    try {
      final snapshot = await notes
          .where(
            'email',
            isEqualTo: email,
          )
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        // Update the quiz score in the document
        await notes.doc(docId).update({
          quizName: newScore, // Assuming 'quizScore' is the field to update
        });
      } else {
        print("No user found with the provided email.");
      }
    } catch (e) {
      print("Error updating quiz score: $e");
    }
  }

  Stream<UserInfo?> fetchUserInfoStreamByEmail(String email) {
    try {
      return notes
          .where(
            'email',
            isEqualTo: email,
          )
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          return UserInfo.fromSnapshot(doc);
        } else {
          return null;
        }
      });
    } catch (e) {
      return Stream.value(null);
    }
  }

  Stream<UserInfo?> fetchUserInfoStreamByPhoneNumber(String phoneNumber) {
    try {
      return notes
          .where('phoneNumber', isEqualTo: phoneNumber)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          return UserInfo.fromSnapshot(doc);
        } else {
          return null;
        }
      });
    } catch (e) {
      print("Error fetching user info: $e");
      // Return an empty stream in case of error
      return Stream.value(null);
    }
  }

  Stream<List<Map<String, dynamic>>> fetchReceiptsByEmail(String email) {
    try {
      return notes
          .where('email', isEqualTo: email)
          .snapshots()
          .asyncMap((snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          final subcollectionSnapshot =
              await doc.reference.collection("receipts").get();
          return subcollectionSnapshot.docs.map((receipt) {
            return receipt.data();
          }).toList();
        } else {
          throw Exception("Document does not exist");
        }
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Stream<List<Map<String, dynamic>>> fetchHistoryByEmail(
    String email,
  ) {
    try {
      return notes
          .where('email', isEqualTo: email)
          .snapshots()
          .asyncMap((snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          final subcollectionSnapshot =
              await doc.reference.collection("history").get();
          return subcollectionSnapshot.docs.map((receipt) {
            return receipt.data();
          }).toList();
        } else {
          throw Exception("Document does not exist");
        }
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> createNewReferral({
    required String firstName,
    required String surName,
    required String coordinator,
    required String email,
    required String program,
    required String cohort,
  }) async {
    await notes.doc().set({
      "role": "user",
      "email": email,
      "program": program,
      "cohort": cohort,
      "coordinator": coordinator,
      'Firstname': firstName,
      'Surname': surName,
    });
  }

    Future<void> createCoordinator({
    required String firstName,
    required String surName,
    required String email,
  }) async {
    await notes.doc().set({
      "role": "coordinator",
      "email": email,
      'Firstname': firstName,
      'Surname': surName,
    });
  }


  createNewNote({required UserInfo user}) async {
    try {
      QuerySnapshot userDocs = await notes
          .where(
            'email',
            isEqualTo: user.email_,
          )
          .get();

      if (userDocs.docs.isNotEmpty) {
        DocumentReference userDoc = userDocs.docs.first.reference;
        await userDoc.update(
          user.toMap(),
        );
      } else {
        await notes.doc().set(
              user.toMap(),
            );
      }
    } catch (e) {
      throw Exception("Could not change user role.");
    }
  }

  Future<void> changeUserRoleToCoordinator(String email) async {
    try {
      QuerySnapshot userDocs = await notes
          .where(
            'email',
            isEqualTo: email,
          )
          .get();

      if (userDocs.docs.isNotEmpty) {
        DocumentReference userDoc = userDocs.docs.first.reference;
        await userDoc.update({
          'role': 'coordinator',
        });
      } else {
        print(
          "No user found with the provided email.",
        );
      }
    } catch (e) {
      print("Error changing user role: $e");
      throw Exception("Could not change user role.");
    }
  }

  Future<List<UserInfo>> getCoordinatorData() async {
    final snapshot = await notes
        .where("role", isEqualTo: "coordinator")
        .get(); // Fetching data once
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      return UserInfo(
        userId_: data[ownerUserIdFieldNameConst],
        address_: data[addressConst],
        city_: data[cityConst],
        country_: data[countryConst],
        dateOfBirth_: data[dateOfBirthConst],
        email_: data[emailConst],
        firstName_: data[firstNameConst],
        surname_: data[surnameConst],
        gender_: data[genderConst],
        imageUrl_: data[imageUrlConst],
        membership: data[membershipConst],
        nameOfInstitution_: data[nameOfInstitutionConst],
        ownerUserId: data[ownerUserIdFieldNameConst],
        phone_: data[phoneConst],
        profession_: data[professionConst],
        tertiary_: data[tertiaryConst],
        title_: data[titleConst],
        yearOfGraduation_: data[yearOfGraduationConst],
        debit: data[debitConst],
      );
    }).toList();
  }

  Future<void> deleteUserData(String userId) {
    return notes.doc(userId).delete();
  }

  Future<String?> fetchUserRole(String email) async {
    try {
      QuerySnapshot userDocs = await notes
          .where(
            'email',
            isEqualTo: email,
          )
          .get();

      if (userDocs.docs.isNotEmpty) {
        return userDocs.docs.first['role'];
      }
    } catch (e) {
      print("Error fetching user role: $e");
    }
    return null;
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();

  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
