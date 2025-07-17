import 'dart:convert';

class MedicineHistoryTable {
  int? hId;
  int? doctorId;
  String? takenTime;
  int? isTaken;
  String? medicineName;
  int? mIsSynced;
  int? medicineId;
  String? medicineTakenBy;
  int? takenById;
  int? isSkipped;

  MedicineHistoryTable({
    this.hId,
    this.doctorId,
    this.takenTime,
    this.isTaken,
    this.medicineName,
    this.mIsSynced,
    this.medicineId,
    this.medicineTakenBy,
    this.takenById,
    this.isSkipped,
  });

  factory MedicineHistoryTable.fromRawJson(String str) =>
      MedicineHistoryTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MedicineHistoryTable.fromJson(Map<String, dynamic> json) => MedicineHistoryTable(
    hId: json["hId"],
    doctorId: json["doctorId"],
    takenTime: json["takenTime"],
    isTaken: json["isTaken"],
    medicineName: json["medicineName"],
    mIsSynced: json["mIsSynced"],
    medicineId: json["medicineId"],
    medicineTakenBy: json["medicineTakenBy"],
    takenById: json["takenById"],
    isSkipped: json["isSkipped"],
      );

  Map<String, dynamic> toJson() =>
      {
        "hId": hId,
        "doctorId": doctorId,
        "takenTime": takenTime,
        "isTaken": isTaken,
        "medicineName": medicineName,
        "mIsSynced": mIsSynced,
        "medicineId": medicineId,
        "medicineTakenBy": medicineTakenBy,
        "takenById": takenById,
        "isSkipped": isSkipped,
      };
}












