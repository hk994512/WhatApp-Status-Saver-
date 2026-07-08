import '../globals/config.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ThemeController>();
    AppColors colorInst = AppColors.instance;
    AppItems appItems = AppItems.instance;
    return Drawer(
      child: Column(
        children: [
          Obx(
            () => DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: c.isDarkMode.value
                      ? [
                          colorInst.darkModeColor,
                          colorInst.darkModeColor.withAlpha(4),
                        ]
                      : [colorInst.appColor, colorInst.appColor],
                ),
              ),
              child: Row(
                mainAxisAlignment: .center, // Fixed
                children: [
                  UIHelper.text(
                    'Status Saver',
                    color: colorInst.whiteColor,
                    fontSize: Get.height * 0.030,
                    fontWeight: FontWeight.w800,
                  ),
                  Icon(
                    AppIcons.downloadIcon,
                    color: colorInst.whiteColor,
                    size: Get.height * 0.045,
                  ),
                ],
              ),
            ),
          ),
          ...appItems.drawerItems(context).map((item) {
            return ListTile(
              onTap: item['onTap'] as VoidCallback?,
              title: UIHelper.text(
                item['title'] as String,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              leading: Icon(
                item['ico'] as IconData,
                color: item['color'] as Color,
              ),
            );
          }),
        ],
      ),
    );
  }
}
