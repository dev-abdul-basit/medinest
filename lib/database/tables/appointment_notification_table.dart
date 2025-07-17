import 'dart:convert';

class AppointmentNotificationTable {
  int? anId;
  int? appointmentId;
  int? bookedForFamilyMemberId;
  int? doctorId;
  String? appointmentDate;
  String? appointmentTime;
  String? appointmentNotificationTime;
  int? appointmentNotificationTimeStamp;
  String? mSoundType;
  String? mDeviceSoundUri;
  String? mSoundTitle;
  int? mIsFromDevice;
  String? reminderBeforeTime;
  String? description;
  int? mIsSynced;

  AppointmentNotificationTable({
    this.anId,
    this.appointmentId,
    this.bookedForFamilyMemberId,
    this.doctorId,
    this.appointmentDate,
    this.appointmentTime,
    this.appointmentNotificationTime,
    this.appointmentNotificationTimeStamp,
    this.mSoundType,
    this.mDeviceSoundUri,
    this.mSoundTitle,
    this.mIsFromDevice,
    this.reminderBeforeTime,
    this.description,
    this.mIsSynced,
  });

  factory AppointmentNotificationTable.fromRawJson(String str) =>
      AppointmentNotificationTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AppointmentNotificationTable.fromJson(Map<String, dynamic> json) =>
      AppointmentNotificationTable(
        anId: json["anId"],
        appointmentId: json["AppointmentId"],
        bookedForFamilyMemberId: json["BookedForFamilyMemberId"],
        doctorId: json["DoctorId"],
        appointmentDate: json["AppointmentDate"],
        appointmentTime: json["AppointmentTime"],
        appointmentNotificationTime: json["AppointmentNotificationTime"],
        appointmentNotificationTimeStamp: json["appointmentNotificationTimeStamp"],
        mSoundType: json["mSoundType"],
        mDeviceSoundUri: json["mDeviceSoundUri"],
        mSoundTitle: json["mSoundTitle"],
        mIsFromDevice: json["mIsFromDevice"],
        reminderBeforeTime: json["ReminderBeforeTime"].toString(),
        description: json["Description"],
        mIsSynced: json["mIsSynced"],
      );

  Map<String, dynamic> toJson() => {
        "anId": anId,
        "AppointmentId": appointmentId,
        "BookedForFamilyMemberId": bookedForFamilyMemberId,
        "DoctorId": doctorId,
        "AppointmentDate": appointmentDate,
        "AppointmentTime": appointmentTime,
        "AppointmentNotificationTime": appointmentNotificationTime,
        "appointmentNotificationTimeStamp": appointmentNotificationTimeStamp,
        "mSoundType": mSoundType,
        "mDeviceSoundUri": mDeviceSoundUri,
        "mSoundTitle": mSoundTitle,
        "mIsFromDevice": mIsFromDevice,
        "ReminderBeforeTime": reminderBeforeTime,
        "Description": description,
        "mIsSynced": mIsSynced,
      };
}












