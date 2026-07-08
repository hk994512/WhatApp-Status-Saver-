

import './globals/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(
    callbackDispatcher, // from auto_save_worker.dart
    // ignore: deprecated_member_use
    isInDebugMode: false,
  );
  await NotificationService.initNotification();
  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('languageCode') ?? 'en';
  final cCode = prefs.getString('countryCode') ?? 'US';
  Get.put(ThemeController());
  runApp(MyApp(locale: Locale(langCode, cCode)));
}

class MyApp extends StatelessWidget {
  final Locale locale;
  const MyApp({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: locale,
      fallbackLocale: Locale('en', 'US'),
      defaultTransition: .native,
      translations: Languages(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => StatusSaver()),
        GetPage(name: '/settings', page: () => Settings()),
      ],
      theme: .light(),
      darkTheme: .dark(),
      themeMode: .light,
    );
  }
}
