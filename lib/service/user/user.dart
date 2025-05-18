import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'user_storage_constants.dart';

@immutable
class UserInfo {
  final String? ownerUserId;
  final String? imageUrl_;
  final String? firstName_; //23
  final String? surname_; //32
  final String? email_; //3
  final String? nameOfInstitution_; //4
  final String? yearOfGraduation_; // 1
  final String? address_; //2
  final String? phone_; // 32
  final String? country_;
  final String? gender_; //3
  final String? dateOfBirth_; //4
  final String? title_; //5
  final String? tertiary_; //32
  final String? city_; //32
  final String? profession_; //32
  final String? userId_; //32
  final String? membership; //32
  final int? debit;
  final String? program; //32

  // membershipIdConst

  const UserInfo(
      {this.debit,
      this.ownerUserId,
      this.firstName_,
      this.surname_,
      this.email_,
      this.nameOfInstitution_,
      this.yearOfGraduation_,
      this.address_,
      this.phone_,
      this.imageUrl_,
      this.gender_,
      this.dateOfBirth_,
      this.title_,
      this.tertiary_,
      this.city_,
      this.profession_,
      this.userId_,
      this.country_,
      this.membership,
      this.program});

  Map<String, dynamic> toMap() {
    return {
      ownerUserIdFieldNameConst: ownerUserId,
      firstNameConst: firstName_,
      surnameConst: surname_,
      emailConst: email_,
      yearOfGraduationConst: yearOfGraduation_,
      addressConst: address_,
      phoneConst: phone_,
      imageUrlConst: imageUrl_,
      genderConst: gender_,
      dateOfBirthConst: dateOfBirth_,
      debitConst: debit,
      titleConst: title_,
      tertiaryConst: tertiary_,
      cityConst: city_,
      professionConst: profession_,
      countryConst: country_,
      membershipConst: membership,
      userIdConst: userId_,
      nameOfInstitutionConst: nameOfInstitution_,
    };
  }

  factory UserInfo.fromMap(String id, Map<String, dynamic> map) {
    return UserInfo(
      ownerUserId: id,
      firstName_: map[firstNameConst] ?? "",
      surname_: map[surnameConst] ?? "",
      email_: map[emailConst] ?? "",
      nameOfInstitution_: map[nameOfInstitutionConst] ?? "",
      yearOfGraduation_: map[yearOfGraduationConst] ?? "",
      address_: map[addressConst] ?? "",
      phone_: map[phoneConst] ?? "",
      imageUrl_: map[imageUrlConst] ??
          "https://cdn-icons-png.flaticon.com/512/9203/9203764.png",
      gender_: map[genderConst] ?? "",
      dateOfBirth_: map[dateOfBirthConst] ?? "",
      title_: map[titleConst] ?? "",
      tertiary_: map[tertiaryConst] ?? "",
      city_: map[cityConst] ?? "",
      profession_: map[professionConst] ?? "",
      userId_: map[userIdConst] ?? "",
      country_: map[countryConst] ?? "Ghana",
      membership: map[membershipConst] ?? "",
      program: map["program"] ?? "",
      debit: map[debitConst] ?? 0,
    );
  }

  UserInfo.fromSnapshot(DocumentSnapshot<Map<String?, dynamic>> snapshot)
      : ownerUserId = snapshot.id,
        firstName_ = snapshot.data()?[firstNameConst] ?? "",
        surname_ = snapshot.data()?[surnameConst] ?? "",
        email_ = snapshot.data()?[emailConst] ?? "",
        yearOfGraduation_ = snapshot.data()?[yearOfGraduationConst] ?? "",
        address_ = snapshot.data()?[addressConst] ?? "",
        phone_ = snapshot.data()?[phoneConst] ?? "",
        nameOfInstitution_ = snapshot.data()?[nameOfInstitutionConst] ?? "",
        imageUrl_ = snapshot.data()?[imageUrlConst] ??
            "https://cdn-icons-png.flaticon.com/512/9203/9203764.png",
        gender_ = snapshot.data()?[genderConst] ?? "",
        dateOfBirth_ = snapshot.data()?[dateOfBirthConst] ?? "",
        title_ = snapshot.data()?[titleConst] ?? "",
        tertiary_ = snapshot.data()?[tertiaryConst] ?? "",
        city_ = snapshot.data()?[cityConst] ?? "",
        profession_ = snapshot.data()?[professionConst] ?? "",
        userId_ = snapshot.data()?[userIdConst] ?? "",
        country_ = snapshot.data()?[countryConst] ?? "Ghana",
        membership = snapshot.data()?[membershipConst] ?? "",
        program = snapshot.data()?["program"] ?? "",
        debit = snapshot.data()?[debitConst] ?? 0;
}
