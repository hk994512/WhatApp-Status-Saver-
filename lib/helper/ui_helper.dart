

import '../globals/config.dart';
class UIHelper {
  static Widget text(
    String text, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    double? letterSpacing,
    double? height,
  }) {
    // Check if current locale is Urdu to use appropriate font
    final isUrdu = Get.locale?.languageCode == 'ur';

    return Text(
      textAlign: textAlign,
      text,
      style: TextStyle(
        fontFamily: isUrdu ? null : "Mooli", // Use system font for Urdu
        color: color,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        fontSize: fontSize,
      ),
    );
  }

  static Widget btn({
    required void Function()? onPressed,
    required Widget label,
    IconData? icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      label: label,
      icon: icon == null ? null : Icon(icon),
    );
  }
}
