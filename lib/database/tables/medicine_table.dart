import 'dart:convert';

class MedicineTable {
  int? mId;
  String? mName;
  String? mDosage;
  String? mColorPhotoType;
  String? mColorPhoto;
  String? mSoundType;
  String? mStartDate;
  String? mEndDate;
  String? mFrequencyType;
  String? mDayOfWeek;
  String? mTime;
  int? mIsActive;
  String? mCurrentTime;
  int? mIsFromDevice;
  int? mIsSynced;
  int? mIsDeleted;
  String? mDeviceSoundUri;
  String? mSoundTitle;
  String? mUnits;
  int? mSelectedShapeId;
  int? mIsNoEndDate;
  int? mFamilyMemberId;
  int? mDoctorId;
  String? mIsBeforeOrAfterFood;

  MedicineTable({
    this.mId,
    this.mName,
    this.mDosage,
    this.mColorPhotoType,
    this.mColorPhoto,
    this.mSoundType,
    this.mStartDate,
    this.mEndDate,
    this.mFrequencyType,
    this.mDayOfWeek,
    this.mTime,
    this.mIsActive,
    this.mCurrentTime,
    this.mIsFromDevice,
    this.mIsSynced,
    this.mIsDeleted,
    this.mDeviceSoundUri,
    this.mSoundTitle,
    this.mUnits,
    this.mSelectedShapeId,
    this.mIsNoEndDate,
    this.mFamilyMemberId,
    this.mDoctorId,
    this.mIsBeforeOrAfterFood,
  });

  factory MedicineTable.fromRawJson(String str) =>
      MedicineTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MedicineTable.fromJson(Map<String, dynamic> json) => MedicineTable(
        mId: json["mId"],
        mName: json["mName"],
        mDosage: json["mDosage"],
        mColorPhotoType: json["mColorPhotoType"],
        mColorPhoto: json["mColorPhoto"],
        mSoundType: json["mSoundType"],
        mStartDate: json["mStartDate"],
        mEndDate: json["mEndDate"],
        mFrequencyType: json["mFrequencyType"],
        mDayOfWeek: json["mDayOfWeek"],
        mTime: json["mTime"],
        mIsActive: json["mIsActive"],
        mCurrentTime: json["mCurrentTime"],
        mIsFromDevice: json["mIsFromDevice"],
        mIsSynced: json["mIsSynced"],
        mIsDeleted: json["mIsDeleted"],
        mDeviceSoundUri: json["mDeviceSoundUri"],
        mSoundTitle: json["mSoundTitle"],
        mUnits: json["mUnits"],
        mSelectedShapeId: json["mSelectedShapeId"],
        mIsNoEndDate: json["mIsNoEndDate"],
        mFamilyMemberId: json["mFamilyMemberId"],
        mDoctorId: json["mDoctorId"],
        mIsBeforeOrAfterFood: json["mIsBeforeOrAfterFood"],
      );

  Map<String, dynamic> toJson() => {
        "mId": mId,
        "mName": mName,
        "mDosage": mDosage,
        "mColorPhotoType": mColorPhotoType,
        "mColorPhoto": mColorPhoto,
        "mSoundType": mSoundType,
        "mStartDate": mStartDate,
        "mEndDate": mEndDate,
        "mFrequencyType": mFrequencyType,
        "mDayOfWeek": mDayOfWeek,
        "mTime": mTime,
        "mIsActive": mIsActive,
        "mCurrentTime": mCurrentTime,
        "mIsFromDevice": mIsFromDevice,
        "mIsSynced": mIsSynced,
        "mIsDeleted": mIsDeleted,
        "mDeviceSoundUri": mDeviceSoundUri,
        "mSoundTitle": mSoundTitle,
        "mUnits": mUnits,
        "mSelectedShapeId": mSelectedShapeId,
        "mIsNoEndDate": mIsNoEndDate,
        "mFamilyMemberId": mFamilyMemberId,
        "mDoctorId": mDoctorId,
        "mIsBeforeOrAfterFood": mIsBeforeOrAfterFood,
      };
  factory MedicineTable.fromMap(Map<String, dynamic> map) {
    return MedicineTable(
      mId: map["mId"],
      mName: map["mName"],
      mDosage: map["mDosage"],
      mColorPhotoType: map["mColorPhotoType"],
      mColorPhoto: map["mColorPhoto"],
      mSoundType: map["mSoundType"],
      mStartDate: map["mStartDate"],
      mEndDate: map["mEndDate"],
      mFrequencyType: map["mFrequencyType"],
      mDayOfWeek: map["mDayOfWeek"],
      mTime: map["mTime"],
      mIsActive: map["mIsActive"],
      mCurrentTime: map["mCurrentTime"],
      mIsFromDevice: map["mIsFromDevice"],
      mIsSynced: map["mIsSynced"],
      mIsDeleted: map["mIsDeleted"],
      mDeviceSoundUri: map["mDeviceSoundUri"],
      mSoundTitle: map["mSoundTitle"],
      mUnits: map["mUnits"],
      mSelectedShapeId: map["mSelectedShapeId"],
      mIsNoEndDate: map["mIsNoEndDate"],
      mFamilyMemberId: map["mFamilyMemberId"],
      mDoctorId: map["mDoctorId"],
      mIsBeforeOrAfterFood: map["mIsBeforeOrAfterFood"],
    );
  }
}
