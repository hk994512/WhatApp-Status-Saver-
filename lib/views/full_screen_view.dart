import '../globals/config.dart';

class FullScreenViewer extends StatefulWidget {
  final File file;
  final bool isVideo;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const FullScreenViewer({
    super.key,
    required this.file,
    required this.isVideo,
    required this.onSave,
    required this.onShare,
  });

  @override
  State<FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<FullScreenViewer> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.file(widget.file);
    await _controller!.initialize();
    _controller!.setLooping(true);
    if (mounted) {
      setState(() {});
    }
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  AppColors get colorInst => AppColors.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorInst.blackColor,
      appBar: AppBar(
        backgroundColor: colorInst.transparentColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorInst.blackColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(AppIcons.backArrowIcon, color: colorInst.whiteColor),
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorInst.blackColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                AppIcons.downloadroundedIcon,
                color: colorInst.whiteColor,
              ),
            ),
            onPressed: () {
              widget.onSave();
              Get.back();
            },
            tooltip: 'Save to Gallery',
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorInst.blackColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(AppIcons.shareIcon, color: colorInst.whiteColor),
            ),
            onPressed: widget.onShare,
            tooltip: 'Share',
          ),
        ],
      ),
      body: Center(
        child: widget.isVideo
            ? _controller != null && _controller!.value.isInitialized
                  ? GestureDetector(
                      onTap: _togglePlayPause,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                          if (!_isPlaying)
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: 0.9,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: colorInst.blackColor.withValues(
                                    alpha: 0.5,
                                  ),
                                  shape: .circle,
                                  border: .all(
                                    color: colorInst.whiteColor,
                                    width: 4,
                                  ),
                                ),
                                child: Icon(
                                  AppIcons.playroundedIcon,
                                  color: colorInst.whiteColor,
                                  size: 56,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        color: colorInst.whiteColor,
                        strokeWidth: 3,
                      ),
                    )
            : InteractiveViewer(
                maxScale: 5.0,
                child: Image.file(widget.file, fit: .contain),
              ),
      ),
    );
  }
}
