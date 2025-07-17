import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserTable {
  int? uId;
  String? name;
  String? email;
  String? fcmToken;
  String? gender;
  String? birthDate;
  String? age;
  String? bloodGroup;
  String? profileImage;
  String? phoneNumber;
  String? address;

  UserTable({
    this.uId,
    this.name,
    this.email,
    this.fcmToken,
    this.gender,
    this.birthDate,
    this.age,
    this.bloodGroup,
    this.profileImage,
    this.phoneNumber,
    this.address,
  });

  factory UserTable.fromRawJson(String str) =>
      UserTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserTable.fromJson(Map<String, dynamic> json) => UserTable(
        uId: json["uId"],
        name: json["Name"],
        email: json["Email"],
        fcmToken: json["FcmToken"],
        gender: json["Gender"],
        birthDate: json["BirthDate"],
        age: json["Age"],
        bloodGroup: json["BloodGroup"],
        profileImage: json["profileImage"],
        phoneNumber: json["PhoneNumber"],
        address: json["Address"],
      );

  Map<String, dynamic> toJson() => {
        "uId": uId,
        "Name": name,
        "Email": email,
        "FcmToken": fcmToken,
        "Gender": gender,
        "BirthDate": birthDate,
        "Age": age,
        "BloodGroup": bloodGroup,
        "profileImage": profileImage,
        "PhoneNumber": phoneNumber,
        "Address": address,
      };

  fromDocumentSnapshot(DocumentSnapshot<Object?> doc){
    final data = doc.data() as Map<String, dynamic>;
    UserTable user = UserTable.fromJson(data);
    return user;
  }
}












