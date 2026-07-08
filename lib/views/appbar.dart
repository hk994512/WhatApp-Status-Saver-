import '../globals/config.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar(this.title, {super.key, this.actions});

  final String title;
  final List<Widget>? actions;
  AppColors get colorInst => AppColors.instance;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ThemeController>();
    return Obx(
      () => AppBar(
        iconTheme: IconThemeData(color: colorInst.whiteColor),
        centerTitle: true,
        backgroundColor: c.isDarkMode.value
            ? colorInst.darkModeColor
            : colorInst.appColor,
        actions: actions,
        title: UIHelper.text(
          title,
          fontSize: 20,
          color: colorInst.whiteColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
