import '../globals/config.dart';

class Languages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': En.en,
    'ur_PK': Ur.ur,
    'hi_IN': HI.hindi,
    'es_ES': SP.spanish,
    'zh_CN': CH.chinese,
  };
}
