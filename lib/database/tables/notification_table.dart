import 'dart:convert';

class MedicineNotificationTable {
  int? nId;
  int? notificationMid;
  String? nCurrentTime;
  String? nName;
  String? nDosage;
  String? nColorPhotoType;
  String? nColorPhoto;
  String? nSoundType;
  String? nStartDate;
  String? nEndDate;
  String? nFrequencyType;
  String? nDayOfWeek;
  String? nTime;
  int? nIsActive;
  String? nNotificationTime;
  int? nIsFromDevice;
  int? nIsSynced;
  String? nDeviceSoundUri;
  String? nSoundTitle;
  String? nUnits;
  int? nSelectedShapeId;
  int? nIsNoEndDate;
  int? nFamilyMemberId;
  int? nDoctorId;
  int? nNotificationTimeStamp;
  String? nIsBeforeOrAfterFood;

  MedicineNotificationTable({
    this.nId,
    this.notificationMid,
    this.nCurrentTime,
    this.nName,
    this.nDosage,
    this.nColorPhotoType,
    this.nColorPhoto,
    this.nSoundType,
    this.nStartDate,
    this.nEndDate,
    this.nFrequencyType,
    this.nDayOfWeek,
    this.nTime,
    this.nIsActive,
    this.nNotificationTime,
    this.nIsFromDevice,
    this.nIsSynced,
    this.nDeviceSoundUri,
    this.nSoundTitle,
    this.nUnits,
    this.nSelectedShapeId,
    this.nIsNoEndDate,
    this.nFamilyMemberId,
    this.nDoctorId,
    this.nNotificationTimeStamp,
    this.nIsBeforeOrAfterFood,
  });

  factory MedicineNotificationTable.fromRawJson(String str) =>
      MedicineNotificationTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MedicineNotificationTable.fromJson(Map<String, dynamic> json) => MedicineNotificationTable(
    nId: json["nId"],
        notificationMid: json["notificationMid"],
        nCurrentTime: json["nCurrentTime"],
        nName: json["nName"],
        nDosage: json["nDosage"],
        nColorPhotoType: json["nColorPhotoType"],
        nColorPhoto: json["nColorPhoto"],
        nSoundType: json["nSoundType"],
        nStartDate: json["nStartDate"],
        nEndDate: json["nEndDate"],
        nFrequencyType: json["nFrequencyType"],
        nDayOfWeek: json["nDayOfWeek"],
        nTime: json["nTime"],
        nIsActive: json["nIsActive"],
        nNotificationTime: json["nNotificationTime"],
        nIsFromDevice: json["nIsFromDevice"],
        nIsSynced: json["nIsSynced"],
        nDeviceSoundUri: json["nDeviceSoundUri"],
        nSoundTitle: json["nSoundTitle"],
        nUnits: json["nUnits"],
        nSelectedShapeId: json["nSelectedShapeId"],
        nIsNoEndDate: json["nIsNoEndDate"],
        nFamilyMemberId: json["nFamilyMemberId"],
        nDoctorId: json["nDoctorId"],
    nNotificationTimeStamp: json["nNotificationTimeStamp"],
        nIsBeforeOrAfterFood: json["nIsBeforeOrAfterFood"],
      );

  Map<String, dynamic> toJson() => {
        "nId": nId,
        "notificationMid": notificationMid,
        "nCurrentTime": nCurrentTime,
        "nName": nName,
        "nDosage": nDosage,
        "nColorPhotoType": nColorPhotoType,
        "nColorPhoto": nColorPhoto,
        "nSoundType": nSoundType,
        "nStartDate": nStartDate,
        "nEndDate": nEndDate,
        "nFrequencyType": nFrequencyType,
        "nDayOfWeek": nDayOfWeek,
        "nTime": nTime,
        "nIsActive": nIsActive,
        "nNotificationTime": nNotificationTime,
        "nIsFromDevice": nIsFromDevice,
        "nIsSynced": nIsSynced,
        "nDeviceSoundUri": nDeviceSoundUri,
        "nSoundTitle": nSoundTitle,
        "nUnits": nUnits,
        "nSelectedShapeId": nSelectedShapeId,
        "nIsNoEndDate": nIsNoEndDate,
        "nFamilyMemberId": nFamilyMemberId,
        "nDoctorId": nDoctorId,
        "nNotificationTimeStamp": nNotificationTimeStamp,
        "nIsBeforeOrAfterFood": nIsBeforeOrAfterFood,
      };
  factory MedicineNotificationTable.fromMap(Map<String, dynamic> map) {
    return MedicineNotificationTable(
      nId: map['nId'],
      notificationMid: map['notificationMid'],
      nCurrentTime: map['nCurrentTime'],
      nName: map['nName'],
      nDosage: map['nDosage'],
      nColorPhotoType: map['nColorPhotoType'],
      nColorPhoto: map['nColorPhoto'],
      nSoundType: map['nSoundType'],
      nStartDate: map['nStartDate'],
      nEndDate: map['nEndDate'],
      nFrequencyType: map['nFrequencyType'],
      nDayOfWeek: map['nDayOfWeek'],
      nTime: map['nTime'],
      nIsActive: map['nIsActive'],
      nNotificationTime: map['nNotificationTime'],
      nIsFromDevice: map['nIsFromDevice'],
      nIsSynced: map['nIsSynced'],
      nDeviceSoundUri: map['nDeviceSoundUri'],
      nSoundTitle: map['nSoundTitle'],
      nUnits: map["nUnits"],
      nSelectedShapeId: map["nSelectedShapeId"],
      nIsNoEndDate: map["nIsNoEndDate"],
      nFamilyMemberId: map["nFamilyMemberId"],
      nDoctorId: map["nDoctorId"],
      nNotificationTimeStamp: map["nNotificationTimeStamp"],
      nIsBeforeOrAfterFood: map["nIsBeforeOrAfterFood"],
    );
  }
}


























