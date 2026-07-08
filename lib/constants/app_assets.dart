class AppAssets {
  AppAssets._();
  static final instance = AppAssets._();
   String bug = assetHandler('bug.svg');
   String contact = assetHandler('contact.svg');
   String language = assetHandler('language.svg');
   String notification = assetHandler('notifications.svg');
}

String assetHandler(String asset) {
  final base = 'assets/';
  return '$base$asset';
}
