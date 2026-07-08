import '../globals/config.dart';

class AppItems {
  AppItems._();
  static final instance = AppItems._();
  final colorInst = AppColors.instance;
  List<Map<String, Object>> drawerItems(BuildContext context) => [
    {
      'title': 'home'.tr,
      'ico': CupertinoIcons.home,
      'onTap': () => Get.back(),
      'color': colorInst.tealColor.shade300,
      'showDropdown': false,
    },
    {
      'title': 'settings'.tr,
      'ico': Icons.settings,
      'onTap': () => Get.toNamed('/settings'),
      'color': colorInst.deepOrangeColor.shade300,
      'showDropdown': false,
    },
    {
      'title': 'exit'.tr,
      'ico': Icons.exit_to_app,
      'onTap': () => SystemNavigator.pop(),
      'color': colorInst.purpleColor.shade300,
      'showDropdown': false,
    },
  ];

  List<Map<String, String>> get settings => [
    {'title': 'English', 'lang': 'en', 'code': 'US'},
    {'title': 'Hindi', 'lang': 'hi', 'code': 'IN'},
    {'title': 'Urdu', 'lang': 'ur', 'code': 'PK'},
    {'title': 'Spanish', 'lang': 'es', 'code': 'ES'},
    {'title': 'Chinese', 'lang': 'zh', 'code': 'CN'},
  ];
}
