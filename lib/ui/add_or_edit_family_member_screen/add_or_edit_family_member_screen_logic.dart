import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/add_success_dialoge.dart';
import 'package:medinest/Widgets/pick_form_dialog.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/helper/firestore_helper.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/utils.dart';

class AddOrEditFamilyMemberScreenLogic extends GetxController {
  TextEditingController userNameController = TextEditingController();
  TextEditingController userBirthDateController = TextEditingController();
  TextEditingController userAgeController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPhoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? selectedGender;

  String? selectedBloodGroup;
  DateTime? birthDate = DateTime.now();

  bool isShowProgress = false;
  bool isEdit = false;
  bool isFromMedicineOrAppointment = false;
  var data = Get.parameters;
  FamilyMemberTable? familyMember;
  int? familyMemberId;
  final ImagePicker _picker = ImagePicker();
  XFile? pickedNewFile;
  String? profileUrl;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    isEdit = data[Constant.idIsEditProfile] == 'true';
    isFromMedicineOrAppointment =
        data[Constant.isFromMedicineOrAppointment] == 'true';

    await setDataForEdit();
    update();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  Future<void> selectBirthDate() async {
    Utils.unFocusKeyboard();
    final DateTime currentDate = DateTime.now();

// Ensure startDate is not before the current date
    birthDate ??= currentDate;

    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: birthDate!,
      firstDate: DateTime(1901),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: sampleDatePickerThemeData,
            colorScheme: ColorScheme.light(
              primary: Get.theme.colorScheme.primary,
              onPrimary: Get.theme.colorScheme.background,
              onSurface: Get.theme.colorScheme.primary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    Get.theme.colorScheme.primary, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != birthDate) {
      birthDate = picked;
      userBirthDateController.text =
          DateFormat('d MMM, yyyy').format(birthDate!);
      userAgeController.text = daysBetween(birthDate!);
      update([Constant.idUserBirthDateInput, Constant.idUserAgeInput]);
    }
  }

  String daysBetween(DateTime from) {
    DateTime birthdate = DateTime(from.year, from.month, from.day);
    Duration difference = DateTime.now().difference(birthdate);

    int years = difference.inDays ~/ 365;
    int months = (difference.inDays % 365) ~/ 30;
    return '$years years and $months months';
  }

  DatePickerThemeData sampleDatePickerThemeData = DatePickerThemeData(
    headerBackgroundColor: Get.theme.colorScheme.primary,
    headerForegroundColor: Get.theme.colorScheme.onError,
    headerHeadlineStyle:
        const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
    headerHelpStyle:
        const TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
    yearOverlayColor: MaterialStateProperty.all<Color>(Colors.blue[100]!),
    weekdayStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Get.theme.colorScheme.onError),
    shadowColor: Colors.grey[300],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    surfaceTintColor: Colors.white,
  );

  Future<void> submitData(BuildContext context) async {
    if (!await InternetConnectivity.isInternetConnect(Get.context!)){
      Utils.showToast(null, "txtCheckYourInternetConnectivity".tr);
      return ;
    }
    if (formKey.currentState!.validate()) {
      try {
        isShowProgress = true;
        update([Constant.idProVersionProgress]);
        var storageRef = FirebaseStorage.instance
            .ref()
            .child('member_images/${userNameController.text}.jpg');
        UploadTask uploadTask;
        String? downloadUrl;

        if (pickedNewFile != null) {
          uploadTask = storageRef.putFile(File(pickedNewFile!.path));
          downloadUrl = await (await uploadTask).ref.getDownloadURL();
        }
        FamilyMemberTable familyMemberTable = FamilyMemberTable(
            fId: isEdit ? familyMember?.fId : null,
            email: userEmailController.text.trim(),
            name: userNameController.text,
            gender: selectedGender,
            birthDate: userBirthDateController.text,
            age: userAgeController.text,
            bloodGroup: selectedBloodGroup,
            phoneNumber: userPhoneController.text,
            profileImage: downloadUrl,
            mIsDeleted: 0,
            mIsSynced: 0);
        if (isEdit) {
          await DataBaseHelper.instance
              .updateFamilyMember(familyMemberTable.fId!, familyMemberTable);

          if (await InternetConnectivity.isInternetConnect(Get.context!)) {
            bool? isSuccess =
                await FireStoreHelper().addOrUpdateFamilyMember(familyMemberTable);
            if (isSuccess != null && isSuccess) {
              AddSuccessDialog(
                      successDescription: 'txtSuccessfullyEdited'.tr,
                      buttonText: 'txtBackToFamilyMember'.tr,
                      isMemberOrDoctor: true)
                  .scaleDialog(Get.context!);
              clearData();
            }
          } else {
            AddSuccessDialog(
                    successDescription: 'txtSuccessfullyEdited'.tr,
                    buttonText: 'txtBackToFamilyMember'.tr,
                    isMemberOrDoctor: true)
                .scaleDialog(Get.context!);
            clearData();
          }

          isShowProgress = false;
          update([Constant.idProVersionProgress]);
        } else {
          int userId = await DataBaseHelper.instance
              .insertFamilyMember(familyMemberTable);
          familyMemberTable.fId = userId;
          if (await InternetConnectivity.isInternetConnect(Get.context!)) {
            bool? isSuccess =
                await FireStoreHelper().addOrUpdateFamilyMember(familyMemberTable);
            Debug.printLog("Add FamilyMemberTable $isSuccess");
            if (isSuccess != null && isSuccess) {
              AddSuccessDialog(
                      successDescription: 'txtSuccessfully'.tr,
                      buttonText: 'txtBackToFamilyMember'.tr,
                      isMemberOrDoctor: true)
                  .scaleDialog(Get.context!);
              clearData();
            }
          } else {
            AddSuccessDialog(
                    successDescription: 'txtSuccessfully'.tr,
                    buttonText: 'txtBackToFamilyMember'.tr,
                    isMemberOrDoctor: true)
                .scaleDialog(Get.context!);
            clearData();
          }
          isShowProgress = false;
          update([Constant.idProVersionProgress]);
        }
      } catch (e) {
        isShowProgress = false;
        update([Constant.idProVersionProgress]);
        Debug.printLog(":::::${e.toString()}");
      }
    }
  }

  Future<void> setDataForEdit() async {
    if (isEdit) {
      familyMemberId = int.parse(data[Constant.idMemberId]!);
      await DataBaseHelper.instance
          .getFamilyMemberData(familyMemberId)
          .then((value) {
        if (value.isEmpty) return;
        familyMember = value.first;
        userNameController.text = familyMember!.name!;
        userBirthDateController.text = familyMember!.birthDate ?? '';
        if (familyMember!.birthDate != null &&
            familyMember!.birthDate!.isNotEmpty){
          birthDate = DateFormat('d MMM, yyyy').parse(familyMember!.birthDate!);
        }
        userAgeController.text = familyMember!.age ?? "";
        userPhoneController.text = familyMember!.phoneNumber ?? '';
        selectedGender = familyMember!.gender;
        selectedBloodGroup = familyMember!.bloodGroup;
        userEmailController.text = familyMember!.email ?? '';
        userAgeController.text = familyMember!.age ?? '';
        userPhoneController.text = familyMember!.phoneNumber ?? '';
        selectedGender = familyMember!.gender;
        selectedBloodGroup = familyMember!.bloodGroup;
        profileUrl = familyMember!.profileImage;
        userEmailController.text = familyMember!.email ?? '';
        Debug.printLog(":::::${selectedGender.toString()}");
        Debug.printLog(":::::${selectedBloodGroup.toString()}");
        update([
          Constant.idProfilePhoto,
          Constant.idSelectGender,
          Constant.idSelectBloodGroup
        ]);
      });
    }
  }

  void clearData() {
    userNameController.text = '';
    userBirthDateController.text = '';
    userAgeController.text = '';
    userPhoneController.text = '';
    selectedGender = null;
    selectedBloodGroup = null;
    userEmailController.text = '';
    pickedNewFile = null;
    profileUrl = null;
    update([
      Constant.idSelectGender,
      Constant.idSelectBloodGroup,
      Constant.idProfilePhoto
    ]);
  }

  openImagePickerDialog() {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: Get.context!,
        builder: (context) => PickFormDialog(
              title: 'txtPickImage'.tr,
              onTapGallery: () => pickImage(ImageSource.gallery),
              onTapCamera: () => pickImage(ImageSource.camera),
            ));
  }

  pickImage(ImageSource source) async {
    Get.back();
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );
    pickedNewFile = pickedFile;
    profileUrl = null;
    update([Constant.idProfilePhoto]);
  }
}
