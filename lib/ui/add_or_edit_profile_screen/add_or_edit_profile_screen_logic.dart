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

  /// The self "Me" FamilyMemberTable row — the real owner of the user's own
  /// medicines. This screen is the single editor for it (shared with the
  /// Family tab's "You" card). UserTable is kept only as an account mirror.
  int? selfMemberId;

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
    if (!formKey.currentState!.validate()) return;

    // SQLite is the source of truth — the profile always saves offline. Only a
    // *new photo upload* needs connectivity; everything else (presets, text,
    // cloud sync) degrades gracefully.
    final bool online =
        await InternetConnectivity.isInternetConnect(Get.context!);
    if (pickedNewFile != null && !online) {
      Utils.showToast(null, "txtCheckYourInternetConnectivity".tr);
      return;
    }

    try {
      isShowProgress = true;
      update([Constant.idProVersionProgress]);

      // Keep the existing avatar unless a new photo was picked.
      String? finalImage = profileUrl;
      if (pickedNewFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child(
            'member_images/${userEmailController.text.trim().isEmpty ? 'self' : userEmailController.text.trim()}.jpg');
        final uploadTask = storageRef.putFile(File(pickedNewFile!.path));
        finalImage = await (await uploadTask).ref.getDownloadURL();
      }

      final String email = userEmailController.text.trim();

      // Resolve the single self row that owns the user's medicines, then write
      // the profile to it (source of truth).
      selfMemberId ??= await DataBaseHelper.instance
          .ensureSelfMember(selfName: 'txtSelfProfileName'.tr);
      final FamilyMemberTable selfMember = FamilyMemberTable(
        fId: selfMemberId,
        email: email,
        name: userNameController.text,
        gender: selectedGender,
        birthDate: userBirthDateController.text,
        age: userAgeController.text,
        bloodGroup: selectedBloodGroup,
        phoneNumber: userPhoneController.text,
        profileImage: finalImage,
        mIsDeleted: 0,
        mIsSynced: 0,
      );
      await DataBaseHelper.instance
          .updateFamilyMember(selfMemberId!, selfMember);

      // Mirror to UserTable (account / cloud identity). Upsert by existing uId.
      final UserTable userTable = UserTable(
        uId: userData?.uId,
        email: email,
        name: userNameController.text,
        fcmToken: Utils.getFcmToken(),
        gender: selectedGender,
        birthDate: userBirthDateController.text,
        age: userAgeController.text,
        bloodGroup: selectedBloodGroup,
        phoneNumber: userPhoneController.text,
        profileImage: finalImage,
        address: addressController.text,
      );
      if (userData?.uId != null) {
        await DataBaseHelper.instance.updateUser(userTable);
      } else {
        final int newUid = await DataBaseHelper.instance.insertUser(userTable);
        userTable.uId = newUid;
      }
      userData = userTable;
      Preference.shared.setProfileAdded(true);

      // Refresh local UI FIRST — the medicine tab's member chips only update via
      // this in-memory reload (unlike the family tab / this screen, which re-read
      // the DB on open). Do it before any network so a slow/failed cloud sync can
      // never leave the home screen showing the stale name. Awaited so the
      // reload completes before we navigate away.
      await _refreshDependentScreens();

      isShowProgress = false;
      update([Constant.idProVersionProgress]);
      Utils.showToast(
        Get.context!,
        isEdit
            ? 'txtProfileIsUpdatedSuccessfully'.tr
            : 'txtProfileIsAddedSuccessfully'.tr,
      );

      // Cloud sync — best effort, isolated so a failure never blocks the UI or
      // navigation. Only when signed in & online.
      if (Preference.shared.getIsUserLogin() && online) {
        try {
          await FireStoreHelper().addUser(userTable);
          await FireStoreHelper().addOrUpdateFamilyMember(selfMember);
        } catch (e) {
          Debug.printLog("profile cloud sync failed: $e");
        }
      }

      if (isEdit) {
        // Return to the caller (Settings / Family tab), which reloads on resume.
        Get.back();
      } else {
        // First-time profile creation → enter the app.
        Preference.shared.setIsUserLogin(true);
        if (online) {
          try {
            await FireStoreHelper().onSync();
          } catch (e) {
            Debug.printLog("profile onSync failed: $e");
          }
        }
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

  /// Refresh the member dropdowns / home greeting so the updated name & photo
  /// surface immediately. Guarded — these controllers only exist once Home is
  /// in memory (true for every edit entry point; absent during create).
  Future<void> _refreshDependentScreens() async {
    if (Get.isRegistered<MedicineScreenLogic>()) {
      final m = Get.find<MedicineScreenLogic>();
      // Awaited: the avatar-chip names come straight from this reloaded list.
      await m.getAllFamilyMembers();
      m.update([
        Constant.idHome,
        Constant.idMedicineList,
        Constant.idMedicineScreenTab,
      ]);
    }
    if (Get.isRegistered<JournalScreenLogic>()) {
      final j = Get.find<JournalScreenLogic>();
      await j.getAllFamilyMembers();
      j.update([
        Constant.idHome,
        Constant.idAppointmentList,
        Constant.idAppointmentScreenTab,
      ]);
    }
    if (Get.isRegistered<HomeController>()) {
      final h = Get.find<HomeController>();
      await h.getUserData();
      h.onTabSelected(h.selectedTabIndex);
    }
  }

  Future<void> setDataForEdit() async {
    // Always resolve the self row — it's the profile's source of truth and must
    // exist before save (works offline and for guests with no UserTable yet).
    selfMemberId = await DataBaseHelper.instance
        .ensureSelfMember(selfName: 'txtSelfProfileName'.tr);

    if (isEdit) {
      // UserTable mirror (account identity + address) — may be absent for guests.
      final users = await DataBaseHelper.instance
          .getUserData(Preference.shared.getString(Preference.firebaseEmail));
      userData = users.isNotEmpty ? users.first : null;

      // Self family row — primary source for the medical fields.
      final selfRows =
          await DataBaseHelper.instance.getFamilyMemberData(selfMemberId);
      final FamilyMemberTable? self =
          selfRows.isNotEmpty ? selfRows.first : null;

      final String name = (self?.name ?? userData?.name ?? '');
      // Don't prefill the default "Me" placeholder — let the user type their
      // real name into an empty field.
      userNameController.text = name == 'txtSelfProfileName'.tr ? '' : name;

      final String birth = self?.birthDate ?? userData?.birthDate ?? '';
      userBirthDateController.text = birth;
      if (birth.isNotEmpty) {
        try {
          birthDate = DateFormat('d MMM, yyyy').parse(birth);
        } catch (_) {/* leave default */}
      }
      userAgeController.text = self?.age ?? userData?.age ?? '';
      userPhoneController.text = self?.phoneNumber ?? userData?.phoneNumber ?? '';
      addressController.text = userData?.address ?? '';
      selectedGender = self?.gender ?? userData?.gender;
      selectedBloodGroup = self?.bloodGroup ?? userData?.bloodGroup;
      profileUrl = self?.profileImage ?? userData?.profileImage;

      update([
        Constant.idSelectGender,
        Constant.idSelectBloodGroup,
        Constant.idProfilePhoto,
        Constant.idUserNameInput,
        Constant.idUserBirthDateInput,
        Constant.idUserAgeInput,
        Constant.idUserPhone,
      ]);
    }

    // Email is the account address — read-only, always sourced from Firebase.
    userEmailController.text =
        Preference.shared.getString(Preference.firebaseEmail) ?? '';
    update([Constant.idUserEmail]);
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
