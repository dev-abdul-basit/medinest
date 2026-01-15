import 'package:flutter/material.dart';
import 'package:medinest/generated/assets.dart';

class Constant {
  static const languageEn = "en";
  static const countryCodeEn = "US";
  static const fontFamilyPoppins = "Poppins";
  static const fontFamilyNunitoSans = "NunitoSans";
  static const fontFamilyRighteous = "Righteous";
  static const fontFamilyLexendDeca = "LexendDeca";
  static const validationTypeEmail = "Email";
  static const validationTypePhone = "Phone";
  static const validationTypePassword = "Password";
  static const validationTypeUserName = "UserName";
  static const validationTypeBirthDate = "BirthDate";
  static const validationTypeEmpty = "Empty";

  static const boolValueTrue = true;
  static const boolValueFalse = false;

  /// Google Ads

  static const interstitialCount = 5;


  static const notificationStartID = 1000;

  static const String idAppointmentTitle = 'idAppointmentTitle';
  static const idDosageSelect = 'idDosageSelect';

  static var idSelectedDosage = 'idSelectedDosage';

  static var idSelectAlertSound = 'idSelectAlertSound';

  static var idListOfSounds = 'idListOfSounds';

  static var idSoundUriArgs = 'idSoundUriArgs';

  static var idSoundTypeArgs = 'idSoundTypeArgs';

  static var idSoundTitleArgs = 'idSoundTitleArgs';

  static var idSelectStartDate = 'idSelectStartDate';

  static var idSelectEndDate = 'idSelectEndDate';

  static var idSelectFrequency = 'idSelectFrequency';

  static var idSelectEveryDay = 'idSelectEveryDay';

  static var idSelectSpecificDay = 'idSelectSpecificDay';

  static var idSelectedTime = 'idSelectedTime';

  static var idHistoryList = 'idHistoryList';

  static var idAccessAllFeaturesButtons = 'idAccessAllFeaturesButtons';

  static var idEmailInput = 'idEmailInput';

  static var idPasswordInput = 'idPasswordInput';

  static var idIsRememberMeCheckBox = 'idIsRememberMeCheckBox';

  static var idConfirmPasswordInput = 'idConfirmPasswordInput';

  static var idUserNameInput = 'idUserNameInput';

  static var idUserBirthDateInput = 'idUserBirthDateInput';

  static var idUserAgeInput = 'idUserAgeInput';

  static var idUserEmail = 'idUserEmail';

  static var idUserPhone = 'idUserPhone';

  static var idUserAddress = 'idUserAddress';

  static var idSelectBloodGroup = 'idSelectBloodGroup';

  static var idSelectGender = 'idSelectGender';

  static var idPageView = 'idPageView';

  static var idMedicineScreenTab = 'idMedicineScreenTab';

  static var idAppointmentScreenTab = 'idAppointmentScreenTab';

  static var idFamilyMemberList = 'idFamilyMemberList';

  static var idDoctorsList = 'idFamilyMember';

  static var idSelectUnit = 'idSelectUnit';

  static var idSelectedShape = 'idSelectedShape';

  static var idShapeList = 'idShapeList';

  static var idColourChooser = 'idColourChooser';

  static var idSelectBeforeOrAfterMeal = 'idSelectBeforeOrAfterMeal';

  static var idNoEndDate = 'idNoEndDate';

  static var idSelectMember = 'idSelectMember';

  static var idSelectDoctor = 'idSelectDoctor';

  static var idSelectMinutesBeforeTime = 'idSelectMinutesBeforeTime';

  static var idUserComment = 'idUserComment';

  static var idMedicineItem = 'idMedicineItem';

  static var addAppointment = 'addAppointment';

  static var notificationAlert = 'notificationAlert';

  static var idMedicineHistory = 'idMedicineHistory';

  static var idDarkThemSwitch = 'idDarkThemSwitch';

  static var idAppointmentHistory = 'idAppointmentHistory';

  static var idChangeLanguage = 'idChangeLanguage';

  static var idColorList= 'idColorList';
  static var idHistoryTimeLine = 'idHistoryTimeLine';

  static var idProfilePhoto ='idProfilePhoto';

  static const appThemeLight = "LIGHT";
  static const appThemeDark = "DARK";

  static const String shareLink = "Add your app url here";

  static const emailPath = 'Add Your Contact Email Address here';

  // static String privacyPolicyURL = "Add your privacy policy link here";
  static String privacyPolicyURL = "Add your privacy policy link here";

  static String aboutUsURL = "Add your About Us Url link here";
  /// Terms & condition URL
  static const termsAndConditionURL = "Add your terms and condition link here";

  static String googlePlayIdentifier = "Add your google Play Identifier here";

  static String appStoreIdentifier = "Add your Apple Apps store Identifier here";

  /// Your monthly Plan ID (Product ID iOS)
  static const String productIdiOS =  "monthly_plan";
//"Enter Your monthly Plan ID (Product ID iOS)";

  /// 'Your yearly Plan ID (Product ID iOS)';
  static const String productIdiOSYearly =  "yearly_plan";
  //"Enter Your yearly Plan ID (Product ID iOS)";

  /// 'Your Plan ID (Product ID Android)';
  static const String productIdAndroid = "pro_version";// "Enter Your Plan ID (Product ID Android)";

  static getAsset() => "assets/";

  static getAssetIcons() => "assets/icons/";
  static getAssetItem() => "assets/item/";

  static getAssetBackground() => "assets/background/";
  static getAssetDrag() => "assets/drag assets/";
  static getAssetDragCategory() => "assets/drag assets/category";
  static getAssetDragImages() => "assets/drag assets/images/";
  static getAssetDragNumbers() => "assets/drag assets/numbers/";

  static getAssetDragCounting() => "assets/drag assets/counting/";

  static getAssetDragAnimation() => "assets/drag assets/animation/";

  static getAssetDragTime() => "assets/drag assets/time/";

  static getAssetDragMonths() => "assets/drag assets/months/";

  static getAssetDragDays() => "assets/drag assets/days/";

  static getAssetSubCategory() => "assets/subcategory/";

  static getAssetImage() => "assets/images/";



  static List<String> soundList = const [
    'Default Tone',
    'Analog Watch',
    'Bells',
    'Cartoon',
    'Clock',
    'Google',
    'iPhone',
    'Kids',
    'Telephone',
    'VIP',
  ];
  static List<String> weekDaysList = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static List<String> dosageDataList = [
    "DROPS",
    "CARTON",
    "CC",
    "GR",
    "IU",
    "PILLS",
    "ML",
    "MCG",
    "MEQ",
    "PIECES",
    "PUFFUS",
    "PATCH",
    "SPRAY",
    "TEA SPOON",
    "TABLE SPOON",
    "UNITS",
    "MG",
  ];

  static List<String> minutesList = ['None','5','15','20','25','30', '60', '90', '120'];

  static List<int> snoozeMinutesList = [5, 10, 15, 30, 60];
  static List<String> beforeOrAfterMeal = [
    "Take After A Meal",
    "Take Before A Meal",
    "Take Any Time"
  ];

  static List<String> genderList = const ['Male', 'Female', 'Other'];
  static List<String> genderIconList = const [Assets.iconsIcUserMale, Assets.iconsIcUserFemale,Assets.iconsIcTransgender];
  static List<String> bloodGroupList = const ['None','A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'Ab-'];

  static Map<int, String> dayData = {1: "Mon", 2: "Tue", 3: "Wed", 4: "Thur", 5: "Fri", 6: "Sat", 7: "Sun"};

  static String txtHowManyObjects = "How Many Objects?";

  static String txtCountTheObjects = "Count the objects";

  /// <<===================>> ****** Widget Id's for refresh in GetX ****** <<===================>>

  static var idProVersionProgress = 'idProVersionProgress';

  static const idSelectedImage = 'idSelectedImage';
  static const idSelectedColor = 'idSelectedColor';
  static const idSettingsTheme = "idSettingsTheme";
  static const idHome = "idHome";
  static const idSetting = "idSetting";
  static const isUserActive = "isUserActive";
  static const isMedicineDetails = "isMedicineDetails";
  static const idDrawerSheet = "idDrawerSheet";
  static const idMedicineList = "idMedicineList";
  static const idAppointmentList = "idAppointmentList";
  static const idAppointmentListItem = "idAppointmentListItem";

  ///Navigation Arguments
  static const idImageArg = 'idImageArg';
  static const idColorArg = 'idColorArg';
  static const idIsEditProfile = 'idIsEditProfile';
  static const idIsFromLogIn = 'idIsFromLogIn';
  static const idIsReSchedule = 'idIsReSchedule';
  static const idAppointmentHistoryTable = 'idAppointmentHistoryTable';
  static const isFromMedicineOrAppointment = 'isFromMedicineOrAppointment';
  static const idMemberId = 'idMemberId';
}

class ColorPicker {
  Color color;
  bool isSelected;
  int indexColor;

  ColorPicker({required this.indexColor,required this.color,required this.isSelected});
}
