import 'package:get/get.dart';
import 'package:medinest/localization/languages/language_ar.dart';
import 'package:medinest/localization/languages/language_az.dart';
import 'package:medinest/localization/languages/language_be.dart';
import 'package:medinest/localization/languages/language_bg.dart';
import 'package:medinest/localization/languages/language_bn.dart';
import 'package:medinest/localization/languages/language_cs.dart';
import 'package:medinest/localization/languages/language_de.dart';
import 'package:medinest/localization/languages/language_el.dart';
import 'package:medinest/localization/languages/language_es.dart';
import 'package:medinest/localization/languages/language_fa.dart';
import 'package:medinest/localization/languages/language_fill.dart';
import 'package:medinest/localization/languages/language_fr.dart';
import 'package:medinest/localization/languages/language_gu.dart';
import 'package:medinest/localization/languages/language_ha.dart';
import 'package:medinest/localization/languages/language_hi.dart';
import 'package:medinest/localization/languages/language_hr.dart';
import 'package:medinest/localization/languages/language_hu.dart';
import 'package:medinest/localization/languages/language_id.dart';
import 'package:medinest/localization/languages/language_it.dart';
import 'package:medinest/localization/languages/language_ja.dart';
import 'package:medinest/localization/languages/language_jv.dart';
import 'package:medinest/localization/languages/language_kn.dart';
import 'package:medinest/localization/languages/language_ko.dart';
import 'package:medinest/localization/languages/language_la.dart';
import 'package:medinest/localization/languages/language_ml.dart';
import 'package:medinest/localization/languages/language_mn.dart';
import 'package:medinest/localization/languages/language_mr.dart';
import 'package:medinest/localization/languages/language_my.dart';
import 'package:medinest/localization/languages/language_my_my.dart';
import 'package:medinest/localization/languages/language_nb.dart';
import 'package:medinest/localization/languages/language_nl.dart';
import 'package:medinest/localization/languages/language_or.dart';
import 'package:medinest/localization/languages/language_pa.dart';
import 'package:medinest/localization/languages/language_pl.dart';
import 'package:medinest/localization/languages/language_pt.dart';
import 'package:medinest/localization/languages/language_ro.dart';
import 'package:medinest/localization/languages/language_ru.dart';
import 'package:medinest/localization/languages/language_sq.dart';
import 'package:medinest/localization/languages/language_su.dart';
import 'package:medinest/localization/languages/language_sv.dart';
import 'package:medinest/localization/languages/language_ta.dart';
import 'package:medinest/localization/languages/language_te.dart';
import 'package:medinest/localization/languages/language_th.dart';
import 'package:medinest/localization/languages/language_tr.dart';
import 'package:medinest/localization/languages/language_uk.dart';
import 'package:medinest/localization/languages/language_ur.dart';
import 'package:medinest/localization/languages/language_vi.dart';
import 'package:medinest/localization/languages/language_yo.dart';
import 'package:medinest/localization/languages/language_zh.dart';
import 'package:medinest/localization/languages/language_zhtw.dart';
import 'package:medinest/localization/languages/language_zu.dart';

import 'languages/language_en.dart';


class AppLanguages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    "en_US": enUS,
    "zh_CN": zhCN,
    "ar_SA": arSA,
    "fr_FR": frFR,
    "de_DE": deDE,
    "hi_IN": hiIN,
    "ja_JP": jaJP,
    "pt_PT": ptPT,
    "ru_RU": ruRU,
    "es_ES": esES,
    "ur_PK": urPK,
    "vi_VN": viVN,
    "id_ID": idID,
    "bn_IN": bnIN,
    "ta_IN": taIN,
    "te_IN": teIN,
    "tr_TR": trTR,
    "ko_KR": koKR,
    "pa_IN": paIN,
    "it_IT": itIT,
    "zh_TW": zhTW,
    "uk_UA": ukUA,
    "th_TH": thTH,
    "sq_AL": sqAL,
    "sv_SE": svSE,
    "ro_RO": roRO,
    "pl_PL": plPL,
    "or_IN": orIN,
    "nl_NL": nlNL,
    "nb_NO": nbNO,
    "my_MM": myMM,
    "mr_IN": mrIN,
    "ml_IN": mlIN,
    "kn_IN": knIN,
    "hu_HU": huHU,
    "hr_HR": hrHR,
    "gu_IN": guIN,
    "fa_IR": faIR,
    "el_GR": elGR,
    "cs_CZ": csCZ,
    "az_AZ": azAZ,
    "ha_NG": haNG,
    "jv_ID": jvID,
    "la_FR": laFR,
    "su_ID": suID,
    "yo_NG": yoNG,
    "be_Be": beBE,
    'bg_BUL':bgBUL,
    'fil_FIL':filFIL,
    'zu_ZK':zuZK,
    'mn_MN':mnMN,
    'my_MY':myMY,//Add your new language here
  };
}

final List<LanguageModel> languages = [

  LanguageModel("🇦🇱", "Albanian (shqiptare)", 'sq', 'AL'),
  LanguageModel("🇸🇦", "(عربى) Arabic", 'ar', 'SA'),
  LanguageModel("🇦🇿", "Azerbaijani (Azərbaycan)", 'az', 'AF'),
  LanguageModel("🇧🇾", "Belarus (беларускі)", 'be', 'BE'),
  LanguageModel("🇮🇳", "Bengali (বাংলা)", 'bn', 'IN'),
  LanguageModel("🇧🇬", "Bulgarian (български)", 'bg', 'BUL'),
  LanguageModel("🇲🇲", "Burmese (မြန်မာ)", 'my', 'MM'),
  LanguageModel("🇨🇳", "Chinese Simplified (中国人)", 'zh', 'CN'),
  LanguageModel("🇹🇼", "Chinese Traditional (中國人)", 'zh', 'TW'),
  LanguageModel("🇭🇷", "Croatian (Hrvatski)", 'hr', 'HR'),
  LanguageModel("🇨🇿", "Czech (čeština)", 'cs', 'CZ'),
  LanguageModel("🇳🇱", "Dutch (Nederlands)", 'nl', 'NL'),
  LanguageModel("🇺🇸", "English (English)", 'en', 'US'),
  LanguageModel("🇫🇷", "French (français)", 'fr', 'FR'),
  LanguageModel("🇩🇪", "German (Deutsche)", 'de', 'DE'),
  LanguageModel("🇬🇷", "Greek (Ελληνικά)", 'el', 'GR'),
  LanguageModel("🇮🇳", "Gujarati (ગુજરાતી)", 'gu', 'IN'),
  LanguageModel("🇳🇬", "Hausa (Hausa)", 'ha', 'NG'),
  LanguageModel("🇮🇳", "Hindi (हिंदी)", 'hi', 'IN'),
  LanguageModel("🇭🇺", "Hungarian (Magyar)", 'hu', 'HU'),
  LanguageModel("🇮🇩", "Indonesian (bahasa indo)", 'id', 'ID'),
  LanguageModel("🇮🇹", "Italian (italiana)", 'it', 'IT'),
  LanguageModel("🇯🇵", "Japanese (日本)", 'ja', 'JP'),
  LanguageModel("🇮🇩", "Javanese (basa jawa)", 'jv', 'ID'),
  LanguageModel("🇮🇳", "Kannada (ಕನ್ನಡ)", 'kn', 'IN'),
  LanguageModel("🇰🇵", "Korean (한국인)", 'ko', 'KR'),
  LanguageModel("🇫🇷", "Latin (Latinus)", 'la', 'FR'),
  LanguageModel("🇮🇳", "Malayalam (മലയാളം)", 'ml', 'IN'),
  LanguageModel("🇮🇳", "Marathi (मराठी)", 'mr', 'IN'),
  LanguageModel("🇲🇳", "Mongolian (Монгол)", 'mn', 'MN'),
  LanguageModel("🇲🇲", "Myanmar (မြန်မာ)", 'my', 'MY'),
  LanguageModel("🇳🇴", "Norwegian (norsk)", 'nb', 'NO'),
  LanguageModel("🇮🇳", "Odia (ଓଡିଆ)", 'or', 'IN'),
  LanguageModel("🇮🇷", "Persian (فارسی)", 'fa', 'IR'),
  LanguageModel("🇵🇭", "Philippines (Filipino)", 'fil', 'FIL'),
  LanguageModel("🇵🇱", "Polish (Polski)", 'pl', 'PL'),
  LanguageModel("🇵🇹", "Portuguese (português)", 'pt', 'PT'),
  LanguageModel("🇮🇳", "Punjabi (ਪੰਜਾਬੀ)", 'pa', 'IN'),
  LanguageModel("🇷🇴", "Romanian (Română)", 'ro', 'RO'),
  LanguageModel("🇷🇺", "Russian (русский)", 'ru', 'RU'),
  LanguageModel("🇪🇸", "Spanish (Español)", 'es', 'ES'),
  LanguageModel("🇮🇩", "Sundanese (basa Sunda)", 'su', 'ID'),
  LanguageModel("🇸🇪", "Swedish (svenska)", 'sv', 'SE'),
  LanguageModel("🇮🇳", "Tamil (தமிழ்)", 'ta', 'IN'),
  LanguageModel("🇮🇳", "Telugu (తెలుగు)", 'te', 'IN'),
  LanguageModel("🇹🇭", "Thai (แบบไทย)", 'th', 'TH'),
  LanguageModel("🇹🇷", "Turkish (Türk)", 'tr', 'TR'),
  LanguageModel("🇺🇦", "Ukrainian (українська)", 'uk', 'UA'),
  LanguageModel("🇵🇰", "(اردو) Urdu", 'ur', 'PK'),
  LanguageModel("🇻🇳", "Vietnamese (Tiếng Việt)", 'vi', 'VN'),
  LanguageModel("🇳🇬", "Yoruba (Yoruba)", 'yo', 'NG'),
  LanguageModel("🇱🇹", "Zulu (Zulu)", 'zu', 'ZK'),//Add your new language here
];

class LanguageModel {
  LanguageModel(
    this.symbol,
    this.language,
    this.languageCode,
    this.countryCode,
  );

  String language;
  String symbol;
  String countryCode;
  String languageCode;
}
