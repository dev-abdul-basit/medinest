import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medinest/Widgets/pick_form_dialog.dart';
import 'package:medinest/connectivity_manager/connectivity_manager.dart';
import 'package:medinest/database/helper/database_helper.dart';
import 'package:medinest/database/helper/firestore_helper.dart';
import 'package:medinest/database/tables/family_member_table.dart';
import 'package:medinest/database/tables/user_table.dart';
import 'package:medinest/routes/app_routes.dart';
import 'package:medinest/ui/appointment_screen/journal_screen_logic.dart';
import 'package:medinest/ui/home/home_binding.dart';
import 'package:medinest/ui/home/home_controller.dart';
import 'package:medinest/ui/medicine_screen/medicine_screen_logic.dart';
import 'package:medinest/utils/constant.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/preference.dart';
import 'package:medinest/utils/utils.dart';

class AddOrEditProfileScreenLogic extends GetxController {
  TextEditingController userNameController = TextEditingController();
  TextEditingController userBirthDateController = TextEditingController();
  TextEditingController userAgeController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPhoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // String? selectedGender = Constant.genderList[0];
  String? selectedGender;

  String? selectedBloodGroup;
  DateTime? birthDate = DateTime.now();

  bool isShowProgress = false;
  bool isEdit = false;
  var data = Get.parameters;
  UserTable? userData;

  final ImagePicker _picker = ImagePicker();
  XFile? pickedNewFile;
  String? profileUrl;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    isEdit = data[Constant.idIsEditProfile] == 'true';
    await setDataForEdit();
    update();
  }

  // @override
  // Future<void> onReady() async {
  //   // TODO: implement onReady
  //   super.onReady();
  //
  // }

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
            .child('member_images/${userEmailController.text.trim()}.jpg');
        UploadTask uploadTask;
        String? downloadUrl;
        if (pickedNewFile != null) {
          uploadTask = storageRef.putFile(File(pickedNewFile!.path));
          downloadUrl = await (await uploadTask).ref.getDownloadURL();
        }
        UserTable userTable = UserTable(
          uId: isEdit ? userData!.uId : null,
          email: userEmailController.text.trim(),
          name: userNameController.text,
          fcmToken: Utils.getFcmToken(),
          gender: selectedGender,
          birthDate: userBirthDateController.text,
          age: userAgeController.text,
          bloodGroup: selectedBloodGroup,
          phoneNumber: userPhoneController.text,
          profileImage: downloadUrl,
          address: addressController.text,
        );
        FamilyMemberTable familyMemberTable = FamilyMemberTable(
            fId: isEdit ? userData?.uId : null,
            email: userEmailController.text.trim(),
            name: userNameController.text,
            gender: selectedGender,
            birthDate: userBirthDateController.text,
            age: userAgeController.text,
            bloodGroup: selectedBloodGroup,
            profileImage: downloadUrl,
            phoneNumber: userPhoneController.text,
            mIsSynced: 0);
        if (isEdit) {
          DataBaseHelper.instance.updateUser(userTable);

          if (await InternetConnectivity.isInternetConnect(Get.context!)) {
            await FireStoreHelper().addUser(userTable);
          }

          await DataBaseHelper.instance
              .updateFamilyMember(familyMemberTable.fId!, familyMemberTable);

          if (await InternetConnectivity.isInternetConnect(Get.context!)) {
            await FireStoreHelper().addOrUpdateFamilyMember(familyMemberTable);
          }

          isShowProgress = false;
          update([Constant.idProVersionProgress]);
          Preference.shared.setProfileAdded(true);
          Utils.showToast(Get.context!, 'txtProfileIsUpdatedSuccessfully'.tr);
          Get.find<MedicineScreenLogic>().getAllFamilyMembers();
          Get.find<JournalScreenLogic>().getAllFamilyMembers();
          Get.find<HomeController>().getUserData();
          Get.find<HomeController>()
              .onTabSelected(Get.find<HomeController>().selectedTabIndex);
          Get.find<JournalScreenLogic>().update([
            Constant.idHome,
            Constant.idAppointmentList,
            Constant.idAppointmentScreenTab
          ]);
          Get.find<MedicineScreenLogic>().update([
            Constant.idHome,
            Constant.idMedicineList,
            Constant.idMedicineScreenTab
          ]);
          Get.forceAppUpdate();
          Get.offNamedUntil(
              AppRoutes.home, ModalRoute.withName(AppRoutes.home));
        } else {
          int userId = await DataBaseHelper.instance.insertUser(userTable);
          userTable.uId = userId;

          if (await InternetConnectivity.isInternetConnect(Get.context!)) {
            await FireStoreHelper().addUser(userTable);
          }

          int familyMemberId = await DataBaseHelper.instance
              .insertFamilyMember(familyMemberTable);
          familyMemberTable.fId = familyMemberId;

          if (await InternetConnectivity.isInternetConnect(Get.context!)) {
            await FireStoreHelper().addOrUpdateFamilyMember(familyMemberTable);
            await FireStoreHelper().onSync();
          }

          isShowProgress = false;
          update([Constant.idProVersionProgress]);
          Preference.shared.setIsUserLogin(true);
          Preference.shared.setProfileAdded(true);
          Utils.showToast(Get.context!, 'txtProfileIsAddedSuccessfully'.tr);
          HomeBinding().dependencies();
          Get.find<HomeController>().onTabSelected(0);
          Get.offAllNamed(AppRoutes.home,
              parameters: {Constant.idIsFromLogIn: "true"});
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
      await DataBaseHelper.instance
          .getUserData(Preference.shared.getString(Preference.firebaseEmail))
          .then((value) {
        if (value.isEmpty) return;
        userData = value.first;
        userNameController.text = userData!.name!;
        userBirthDateController.text = userData!.birthDate ?? '';
        if (userData!.birthDate != null && userData!.birthDate!.isNotEmpty) {
          birthDate = DateFormat('d MMM, yyyy').parse(userData!.birthDate!);
        }
        userAgeController.text = userData!.age ?? '';
        userPhoneController.text = userData!.phoneNumber ?? '';
        addressController.text = userData!.address ?? '';
        selectedGender = userData!.gender;
        selectedBloodGroup = userData!.bloodGroup;
        profileUrl = userData!.profileImage;
        userEmailController.text =
            Preference.shared.getString(Preference.firebaseEmail) ?? '';
        Debug.printLog(":::::${selectedGender.toString()}");
        Debug.printLog(":::::${selectedBloodGroup.toString()}");
        update([
          Constant.idSelectGender,
          Constant.idSelectBloodGroup,
          Constant.idProfilePhoto
        ]);
      });
    }
    userEmailController.text =
        Preference.shared.getString(Preference.firebaseEmail) ?? '';
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
