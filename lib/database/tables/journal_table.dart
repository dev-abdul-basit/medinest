import 'dart:convert';

class JournalTable {
  int? aId;
   int? bookedForFamilyMemberId;
  // int? doctorId;
  // String? appointmentDate;
  // String? appointmentTime;
  // String? mSoundType;
  // String? mDeviceSoundUri;
  String? mSoundTitle;
  // int? mIsFromDevice;
  // String? reminderBeforeTime;
  String? description;
  int? mIsSynced;
  int? mIsDeleted;

  // int? isReSchedule;
  // int? isAccept;

  JournalTable({
    this.aId,
     this.bookedForFamilyMemberId,
    // this.doctorId,
    // this.appointmentDate,
    // this.appointmentTime,
    // this.mSoundType,
    // this.mDeviceSoundUri,
     this.mSoundTitle,
    // this.mIsFromDevice,
    // this.reminderBeforeTime,
    this.description,
    this.mIsSynced,
    this.mIsDeleted,

    // this.isReSchedule,
    //this.isAccept,
  });

  factory JournalTable.fromRawJson(String str) =>
      JournalTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory JournalTable.fromJson(Map<String, dynamic> json) =>
      JournalTable(
        aId: json["aId"],
         bookedForFamilyMemberId: json["BookedForFamilyMemberId"],
        // doctorId: json["DoctorId"],
        // appointmentDate: json["AppointmentDate"],
        // appointmentTime: json["AppointmentTime"],
        // mSoundType: json["mSoundType"],
        // mDeviceSoundUri: json["mDeviceSoundUri"],
         mSoundTitle: json["mSoundTitle"],
        // mIsFromDevice: json["mIsFromDevice"],
        // reminderBeforeTime: json["ReminderBeforeTime"].toString(),
        description: json["Description"],
        mIsSynced: json["mIsSynced"],
        mIsDeleted: json["mIsDeleted"],
      );

  Map<String, dynamic> toJson() => {
    "aId": aId,
     "BookedForFamilyMemberId": bookedForFamilyMemberId,
    // "DoctorId": doctorId,
    // "AppointmentDate": appointmentDate,
    // "AppointmentTime": appointmentTime,
    // "mSoundType": mSoundType,
    // "mDeviceSoundUri": mDeviceSoundUri,
     "mSoundTitle": mSoundTitle,
    // "mIsFromDevice": mIsFromDevice,
    // "ReminderBeforeTime": reminderBeforeTime,
    "Description": description,
    "mIsSynced": mIsSynced,
    "mIsDeleted": mIsDeleted,
  };
}
