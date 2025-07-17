import 'dart:convert';

class FamilyMemberTable {
  int? fId;
  String? name;
  String? gender;
  String? birthDate;
  String? age;
  String? bloodGroup;
  String? email;
  String? phoneNumber;
  String? profileImage;
  int? mIsSynced;
  int? mIsDeleted;

  FamilyMemberTable({
    this.fId,
    this.name,
    this.gender,
    this.birthDate,
    this.age,
    this.bloodGroup,
    this.email,
    this.phoneNumber,
    this.profileImage,
    this.mIsSynced,
    this.mIsDeleted,
  });

  factory FamilyMemberTable.fromRawJson(String str) =>
      FamilyMemberTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FamilyMemberTable.fromJson(Map<String, dynamic> json) =>
      FamilyMemberTable(
        fId: json["fId"],
        name: json["Name"],
        gender: json["Gender"],
        birthDate: json["BirthDate"],
        age: json["Age"],
        bloodGroup: json["BloodGroup"],
        email: json["Email"],
        phoneNumber: json["PhoneNumber"],
        profileImage: json["profileImage"],
        mIsSynced: json["mIsSynced"],
        mIsDeleted: json["mIsDeleted"],
      );

  Map<String, dynamic> toJson() => {
        "fId": fId,
        "Name": name,
        "Gender": gender,
        "BirthDate": birthDate,
        "Age": age,
        "BloodGroup": bloodGroup,
        "Email": email,
        "PhoneNumber": phoneNumber,
        "profileImage": profileImage,
        "mIsDeleted": mIsDeleted,
      };
}












