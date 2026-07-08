import '../globals/config.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final assetInst = AppAssets.instance;
  AppItems get appItems => AppItems.instance;
  String selectedLang = 'English';
  String languageCode = 'en';
  String countryCode = 'US';
  bool _notificationEnabled = true;
  // ignore: unused_field
  bool _isLoading = true;
  final ThemeController controller = Get.put(ThemeController());
  final StatusHandlerController c1 = Get.put(StatusHandlerController());
  @override
  void initState() {
    super.initState();
    _loadLanguage();
    c1.notificationHandler();
    // _loadNotifications();
  }

  // Future<void> _loadNotifications() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   setState(() {
  //     _notificationEnabled = prefs.getBool('notifications_enabled') ?? true;
  //     _isLoading = false;
  //   });
  // }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('selectedLang') ?? 'English';
    final langCode = prefs.getString('languageCode') ?? 'en';
    final cCode = prefs.getString('countryCode') ?? 'US';
    setState(() {
      selectedLang = lang;
      languageCode = langCode;
      countryCode = cCode;
    });
    Get.updateLocale(Locale(langCode, cCode));
  }

  Future<void> _saveLanguage(String lang, String langCode, String cCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLang', lang);
    await prefs.setString('languageCode', langCode);
    await prefs.setString('countryCode', cCode);
  }

  Widget buildLangDropdown() {
    return DropdownButton<String>(
      value: selectedLang,
      isDense: true,
      underline: const SizedBox(),
      items: appItems.settings.map((s) {
        return DropdownMenuItem<String>(
          value: s['title'],
          child: UIHelper.text(s['title']!),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null && value.isNotEmpty) {
          final selected = appItems.settings.firstWhere(
            (s) => s['title'] == value,
          );
          setState(() {
            selectedLang = value;
            languageCode = selected['lang']!;
            countryCode = selected['code']!;
          });
          Get.updateLocale(Locale(languageCode, countryCode));
          _saveLanguage(value, languageCode, countryCode);
        }
      },
    );
  }

  final TextEditingController reportController = .new();
  Future<void> _launchUrl() async {
    final url = "https://hamzakhan-web.web.app";
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  AppColors get colorInst => AppColors.instance;
  List<Map<String, dynamic>> settingsItems(BuildContext context) => [
    {
      'title': 'lang'.tr,
      'ico': assetInst.language,
      'color': colorInst.pinkColor.shade300,
      'showDropdown': true,
    },
    {
      'title': 'report_bug'.tr,
      'ico': assetInst.bug,
      'onTap': () {
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          anchorPoint: Offset(4, 12),
          builder: (_) {
            return Padding(
              padding: const .all(8.0),
              child: Column(
                children: [
                  5.heightBox,
                  UIHelper.text(
                    "What's happened?",
                    fontWeight: .w800,
                    fontSize: 17,
                  ),
                  5.heightBox,
                  TextField(
                    controller: reportController,
                    decoration: InputDecoration(
                      labelText: 'Enter bug report',
                      border: .none,
                      contentPadding: .all(20),
                    ),
                    maxLines: 3,
                  ),
                  5.heightBox,
                  SizedBox(
                    width: Get.width / 5,
                    child: ActionButton(
                      icon: Icons.send,
                      onPressed: () {
                        if (reportController.text.isEmpty) {
                          Get.back();
                          Get.snackbar(
                            icon: Icon(Icons.umbrella),
                            'Empty message',
                            'Please input bug report',
                          );
                        } else if (reportController.text.length < 10) {
                          return;
                        } else {
                          Get.back();
                          Get.snackbar('Sent', 'Report sent successfully');
                          reportController.clear();
                        }
                      },
                      tooltip: 'Send Report',
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      'color': colorInst.deepOrangeColor.shade300,
      'showDropdown': false,
    },
    {
      'title': 'contact_us'.tr,
      'ico': assetInst.contact,
      'onTap': _launchUrl,
      'color': colorInst.indigoColor.shade300,
      'showDropdown': false,
    },
  ];
  @override
  void dispose() {
    reportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar('settings'.tr),
      body: ListView(
        padding: .all(12),
        children: [
          Obx(
            () => SwitchListTile(
              title: UIHelper.text('theme'.tr),
              subtitle: UIHelper.text(
                controller.isDarkMode.value ? 'dark'.tr : 'light'.tr,
              ),
              value: controller.isDarkMode.value,
              onChanged: (value) {
                controller.isDarkMode.value = value;
                Get.changeTheme(value ? ThemeData.dark() : ThemeData.light());
              },
            ),
          ),

          10.heightBox,
          ...settingsItems(context).map((s) {
            if (s['showDropdown'] == true) {
              return ListTile(
                title: UIHelper.text(
                  s['title'] as String,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                leading: SvgPicture.asset(
                  s['ico'] as String,
                  colorFilter: ColorFilter.mode(s['color'] as Color, .srcATop),
                  height: context.height * 0.035,
                ),
                trailing: buildLangDropdown(),
              );
            } else {
              return ListTile(
                onTap: s['onTap'] as VoidCallback,
                title: UIHelper.text(
                  s['title'] as String,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                leading: SvgPicture.asset(
                  s['ico'] as String,
                  colorFilter: ColorFilter.mode(s['color'] as Color, .srcATop),
                  height: context.height * 0.035,
                ),
              );
            }
          }),
          5.heightBox,
          SwitchListTile(
            secondary: SvgPicture.asset(
              assetInst.notification,
              height: context.height * 0.035,
              colorFilter: ColorFilter.mode(
                const Color.fromARGB(255, 23, 189, 189),
                .srcATop,
              ),
            ),
            title: UIHelper.text(
              'noti'.tr,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            value: _notificationEnabled,
            onChanged: (value) async {
              setState(() {
                _notificationEnabled = value;
              });
              c1.notificationHandler(isToggled: value);
              Get.snackbar(
                icon: Icon(
                  value
                      ? Icons.notifications_on_outlined
                      : Icons.notifications_off_outlined,
                ),
                "Alert",
                value ? "Notifications enabled" : "Notifications disabled",
              );
              if (value) {
                // await NotificationService.showNotificationForce();
              }
            },
          ),
        ],
      ),
    );
  }
}
