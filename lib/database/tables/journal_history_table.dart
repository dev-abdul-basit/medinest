import 'dart:convert';

class JournalHistoryTable {
  int? ahId;
  int? doctorId;
  String? acceptTime;
  int? isAccept;
  int? mIsSynced;
  int? appointmentId;
  String? appointmentFor;
  int? appointmentForId;
  int? isReSchedule;

  JournalHistoryTable({
    this.ahId,
    this.doctorId,
    this.acceptTime,
    this.isAccept,
    this.mIsSynced,
    this.appointmentId,
    this.appointmentFor,
    this.appointmentForId,
    this.isReSchedule,
  });

  factory JournalHistoryTable.fromRawJson(String str) =>
      JournalHistoryTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory JournalHistoryTable.fromJson(Map<String, dynamic> json) => JournalHistoryTable(
    ahId: json["ahId"],
    doctorId: json["doctorId"],
    acceptTime: json["acceptTime"],
    isAccept: json["isAccept"],
    mIsSynced: json["mIsSynced"],
    appointmentId: json["appointmentId"],
    appointmentFor: json["appointmentFor"],
    appointmentForId: json["appointmentForId"],
    isReSchedule: json["isReSchedule"],
      );

  Map<String, dynamic> toJson() =>
      {
        "ahId": ahId,
        "doctorId": doctorId,
        "acceptTime": acceptTime,
        "isAccept": isAccept,
        "mIsSynced": mIsSynced,
        "appointmentId": appointmentId,
        "appointmentFor": appointmentFor,
        "appointmentForId": appointmentForId,
        "isReSchedule": isReSchedule,
      };
}












