import '../globals/config.dart';

AppColors get colorInst => AppColors.instance;

class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color color;
  final Color bgColor;

  const ActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color = Colors.white,
    this.bgColor = Colors.black,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        type: .canvas,
        textStyle: TextStyle(fontFamily: 'Mooli'),
        color: colorInst.transparentColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.9),
              borderRadius: .circular(20),
              border: Border.all(
                color: colorInst.whiteColor.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorInst.blackColor.withValues(alpha: 0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 16),
          ),
        ),
      ),
    );
  }
}
