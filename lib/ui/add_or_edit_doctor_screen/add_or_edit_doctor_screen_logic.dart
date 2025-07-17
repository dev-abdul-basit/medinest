import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medinest/Widgets/add_success_dialoge.dart';
import 'package:medinest/Widgets/pick_form_dialog.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/helper/firestore_helper.dart';
import 'package:medinest/database/tables/doctors_table.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/utils.dart';

class AddOrEditDoctorScreenLogic extends GetxController {
  TextEditingController doctorNameController = TextEditingController();
  TextEditingController doctorExpController = TextEditingController();
  TextEditingController doctorEmailController = TextEditingController();
  TextEditingController doctorPhoneController = TextEditingController();
  TextEditingController hospitalNameController = TextEditingController();
  TextEditingController hospitalAddressController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String? selectedGender;

  DateTime? birthDate = DateTime.now();

  bool isShowProgress = false;
  bool isEdit = false;
  var data = Get.parameters;
  DoctorsTable? doctor;
  int? doctorId;

  final ImagePicker _picker = ImagePicker();
  XFile? pickedNewFile;
  String? profileUrl;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    isEdit = data[Constant.idIsEditProfile] == 'true';
    setDataForEdit();
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
      doctorExpController.text = daysBetween(birthDate!);
      update([Constant.idUserBirthDateInput, Constant.idUserAgeInput]);
    }
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

  String daysBetween(DateTime from) {
    DateTime birthdate = DateTime(from.year, from.month, from.day);
    Duration difference = DateTime.now().difference(birthdate);

    int years = difference.inDays ~/ 365;
    int months = (difference.inDays % 365) ~/ 30;
    return '$years years and $months months';
  }

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
            .child('member_images/${doctorNameController.text}.jpg');
        UploadTask uploadTask;
        String? downloadUrl;
        if (pickedNewFile != null) {
          uploadTask = storageRef.putFile(File(pickedNewFile!.path));
          downloadUrl = await (await uploadTask).ref.getDownloadURL();
        }
        DoctorsTable doctorTable = DoctorsTable(
          dId: isEdit ? doctor?.dId : null,
          name: doctorNameController.text.trim(),
          gender: selectedGender,
          experience: doctorExpController.text,
          email: doctorEmailController.text,
          phoneNumber: doctorPhoneController.text,
          hospitalName: hospitalNameController.text,
          hospitalAddress: hospitalAddressController.text,
          profileImage: downloadUrl,
          mIsSynced: 0,
          mIsDeleted: 0,
        );
        if (isEdit) {
          await DataBaseHelper.instance
              .updateDoctor(doctorTable.dId!, doctorTable);

          if (await InternetConnectivity.isInternetConnect(Get.context!)) {
            bool? isSuccess = await FireStoreHelper().addOrUpdateDoctor(doctorTable);

            if (isSuccess != null && isSuccess) {
              AddSuccessDialog(
                      successDescription: 'txtSuccessfullyEditedDoctor'.tr,
                      buttonText: 'txtBackToDoctors'.tr,
                      isMemberOrDoctor: true)
                  .scaleDialog(Get.context!);
              clearData();
            }
          } else {
            AddSuccessDialog(
                    successDescription: 'txtSuccessfullyEditedDoctor'.tr,
                    buttonText: 'txtBackToDoctors'.tr,
                    isMemberOrDoctor: true)
                .scaleDialog(Get.context!);
            clearData();
          }

          isShowProgress = false;
          update([Constant.idProVersionProgress]);
        } else {
          int userId = await DataBaseHelper.instance.insertDoctor(doctorTable);
          doctorTable.dId = userId;

          if (await InternetConnectivity.isInternetConnect(Get.context!)) {
            bool? isSuccess = await FireStoreHelper().addOrUpdateDoctor(doctorTable);
            Debug.printLog("Add Doctor Table $isSuccess");
            if (isSuccess != null && isSuccess) {
              AddSuccessDialog(
                      successDescription: 'txtSuccessfullyAddedDoctor'.tr,
                      buttonText: 'txtBackToDoctors'.tr,
                      isMemberOrDoctor: true)
                  .scaleDialog(Get.context!);
              clearData();
            }
          } else {
            AddSuccessDialog(
                    successDescription: 'txtSuccessfullyAddedDoctor'.tr,
                    buttonText: 'txtBackToDoctors'.tr,
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
      doctorId = int.parse(data[Constant.idMemberId]!);
      await DataBaseHelper.instance
          .getDoctorsData(result: doctorId)
          .then((value) {
        if (value.isEmpty) return;
        doctor = value.first;
        doctorNameController.text = doctor!.name!;
        selectedGender = doctor!.gender;
        doctorExpController.text = doctor!.experience!;
        doctorEmailController.text = doctor!.email!;
        doctorPhoneController.text = doctor!.phoneNumber!;
        hospitalNameController.text = doctor!.hospitalName!;
        profileUrl = doctor!.profileImage;
        hospitalAddressController.text = doctor!.hospitalAddress!;
        Debug.printLog(":::::${selectedGender.toString()}");
        update([
          Constant.idSelectGender,
          Constant.idSelectBloodGroup,
          Constant.idProfilePhoto
        ]);
      });
    }
  }

  void clearData() {
    doctorNameController.text = '';
    selectedGender = Constant.genderList[0];
    doctorExpController.text = '';
    doctorEmailController.text = '';
    doctorPhoneController.text = '';
    hospitalNameController.text = '';
    hospitalAddressController.text = '';
    pickedNewFile = null;
    profileUrl = null;
    update([Constant.idSelectGender, Constant.idProfilePhoto]);
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
