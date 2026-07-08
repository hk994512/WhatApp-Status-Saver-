import '../globals/config.dart';

class StatusCard extends StatelessWidget {
  final File file;
  final bool isVideo;
  final bool isViewed;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onToggleView;
  final bool isDarkmode;
  const StatusCard({
    super.key,
    required this.file,
    required this.isVideo,
    required this.isViewed,
    required this.onTap,
    required this.onSave,
    required this.onShare,
    required this.onToggleView,
    required this.isDarkmode,
  });
  AppColors get colorInst => AppColors.instance;
  @override
  Widget build(BuildContext context) {
    final bgColor = !isDarkmode ? colorInst.appColor : colorInst.whiteColor;
    final color = isDarkmode ? colorInst.appColor : colorInst.whiteColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorInst.blackColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              isVideo
                  ? VideoThumbnail(file: file)
                  : Image.file(file, fit: BoxFit.cover),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorInst.transparentColor,
                      colorInst.blackColor.withValues(alpha: 0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),

              if (isVideo)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorInst.whiteColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: colorInst.whiteColor, width: 3),
                    ),
                    child: Icon(
                      AppIcons.playroundedIcon,
                      color: colorInst.whiteColor,
                      size: 32,
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: .symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: .spaceAround,
                    children: [
                      ActionButton(
                        icon: AppIcons.downloadroundedIcon,
                        onPressed: onSave,
                        tooltip: 'Download',
                        bgColor: bgColor,
                        color: color,
                      ),

                      ActionButton(
                        icon: AppIcons.shareroundedIcon,
                        onPressed: onShare,
                        tooltip: 'Share',
                        bgColor: bgColor,
                        color: color,
                      ),
                      ActionButton(
                        icon: isViewed
                            ? AppIcons.visibleIcon
                            : AppIcons.invisibleIcon,
                        onPressed: onToggleView,
                        tooltip: isViewed ? 'Mark Unviewed' : 'Mark Viewed',
                        bgColor: bgColor,
                        color: color,
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorInst.blackColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      Icon(
                        isVideo ? AppIcons.videocamIcon : AppIcons.imageIcon,
                        color: colorInst.whiteColor,
                        size: 14,
                      ),
                      4.widthBox,
                      Text(
                        isVideo ? 'Video' : 'Photo',
                        style: TextStyle(
                          color: colorInst.whiteColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (isViewed)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorInst.greenColor.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: colorInst.whiteColor,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
