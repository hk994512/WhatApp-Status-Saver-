import '../globals/config.dart';

class VideoThumbnail extends StatefulWidget {
  final File file;

  const VideoThumbnail({super.key, required this.file});

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.file(widget.file);
    await _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  AppColors get colorInst => AppColors.instance;
  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorInst.greyColor.shade300,
              colorInst.greyColor.shade200,
            ],
            begin: .topLeft,
            end: .bottomRight,
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: colorInst.appColor,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return VideoPlayer(_controller!);
  }
}
