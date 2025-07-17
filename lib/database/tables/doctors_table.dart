import 'dart:convert';

class DoctorsTable {
  int? dId;
  String? name;
  String? gender;
  String? experience;
  String? email;
  String? profileImage;
  String? phoneNumber;
  String? hospitalName;
  String? hospitalAddress;
  int? mIsSynced;
  int? mIsDeleted;

  DoctorsTable({
    this.dId,
    this.name,
    this.gender,
    this.experience,
    this.email,
    this.profileImage,
    this.phoneNumber,
    this.hospitalName,
    this.hospitalAddress,
    this.mIsSynced,
    this.mIsDeleted,
  });

  factory DoctorsTable.fromRawJson(String str) =>
      DoctorsTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DoctorsTable.fromJson(Map<String, dynamic> json) => DoctorsTable(
    dId: json["dId"],
        name: json["Name"],
        gender: json["Gender"],
        experience: json["Experience"],
        email: json["Email"],
        profileImage: json["profileImage"],
        phoneNumber: json["PhoneNumber"],
        hospitalName: json["HospitalName"],
        hospitalAddress: json["HospitalAddress"],
        mIsSynced: json["mIsSynced"],
        mIsDeleted: json["mIsDeleted"] ?? 0,
      );

  Map<String, dynamic> toJson() =>
      {
        "dId": dId,
        "Name": name,
        "Gender": gender,
        "Experience": experience,
        "Email": email,
        "profileImage": profileImage,
        "PhoneNumber": phoneNumber,
        "HospitalName": hospitalName,
        "HospitalAddress": hospitalAddress,
        "mIsDeleted": mIsDeleted,
      };
}












