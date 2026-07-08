import './../globals/config.dart';

const String kAutoSaveTask = 'statuslyAutoSaveTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == kAutoSaveTask) {
      await AutoSaveService.runAutoSave();
    }
    return Future.value(true);
  });
}

class AutoSaveService {
  static const List<String> allPaths = [
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
    '/storage/emulated/0/WhatsApp/Media/.Statuses',
    // ── WhatsApp Business ─────────────────────────────────────────────────
    '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses',
    '/storage/emulated/0/WhatsApp Business/Media/.Statuses',
    // ── GB WhatsApp ───────────────────────────────────────────────────────
    '/storage/emulated/0/Android/media/com.gbwhatsapp/GBWhatsApp/Media/.Statuses',
    '/storage/emulated/0/GBWhatsApp/Media/.Statuses',
    // ── GB WhatsApp Pro ───────────────────────────────────────────────────
    '/storage/emulated/0/Android/media/com.gbwhatsapp.pro/GBWhatsAppPro/Media/.Statuses',
    '/storage/emulated/0/GBWhatsAppPro/Media/.Statuses',
    // ── FM WhatsApp ───────────────────────────────────────────────────────
    '/storage/emulated/0/Android/media/com.fmwhatsapp/FMWhatsApp/Media/.Statuses',
    '/storage/emulated/0/FMWhatsApp/Media/.Statuses',
    // ── OG WhatsApp ───────────────────────────────────────────────────────
    '/storage/emulated/0/Android/media/com.ogwhatsapp/OGWhatsApp/Media/.Statuses',
    '/storage/emulated/0/OGWhatsApp/Media/.Statuses',
    // ── YO WhatsApp ───────────────────────────────────────────────────────
    '/storage/emulated/0/Android/media/com.yowhatsapp/YOWhatsApp/Media/.Statuses',
    '/storage/emulated/0/YOWhatsApp/Media/.Statuses',
    // ── WhatsApp Plus ─────────────────────────────────────────────────────
    '/storage/emulated/0/Android/media/com.whatsapp.plus/WhatsAppPlus/Media/.Statuses',
    '/storage/emulated/0/WhatsAppPlus/Media/.Statuses',
    // ── Aero WhatsApp ─────────────────────────────────────────────────────
    '/storage/emulated/0/Android/media/com.whatsapp.aero/WhatsAppAero/Media/.Statuses',
    '/storage/emulated/0/WhatsAppAero/Media/.Statuses',
    // ── Delta WhatsApp ────────────────────────────────────────────────────
    '/storage/emulated/0/Android/media/com.delta.whatsapp/DeltaWhatsApp/Media/.Statuses',
    '/storage/emulated/0/DeltaWhatsApp/Media/.Statuses',
    // ── Fouad WhatsApp ────────────────────────────────────────────────────
    '/storage/emulated/0/Android/media/com.fouad.whatsapp/FouadWhatsApp/Media/.Statuses',
    '/storage/emulated/0/FouadWhatsApp/Media/.Statuses',
    // ── Prime WhatsApp ────────────────────────────────────────────────────
    '/storage/emulated/0/Android/media/com.prime.whatsapp/PrimeWhatsApp/Media/.Statuses',
  ];

  static bool _isSupportedFile(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.png') ||
        p.endsWith('.webp') ||
        p.endsWith('.gif') ||
        p.endsWith('.mp4') ||
        p.endsWith('.mkv') ||
        p.endsWith('.3gp');
  }

  static Future<void> runAutoSave() async {
    final prefs = await SharedPreferences.getInstance();
    final autoSaveEnabled = prefs.getBool('auto_save_enabled') ?? false;
    if (!autoSaveEnabled) return;

    // Where to save — same folder your app already uses
    const savePath = '/storage/emulated/0/Pictures/Statusly';
    final saveDir = Directory(savePath);
    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }

    // Track already auto-saved files by "name_size" key
    final Set<String> alreadySaved =
        (prefs.getStringList('auto_saved_keys') ?? []).toSet();
    final List<String> newlySavedNames = [];

    for (final path in allPaths) {
      final dir = Directory(path);
      if (!await dir.exists()) continue;

      for (final entity in dir.listSync()) {
        if (entity is! File) continue;
        if (!_isSupportedFile(entity.path)) continue;

        final fileName = entity.path.split('/').last;
        final fileSize = entity.lengthSync();
        final key = '${fileName}_$fileSize';

        if (alreadySaved.contains(key)) continue;

        // Build unique save filename
        final ext = fileName.split('.').last.toLowerCase();
        final ts = DateTime.now();
        final stamp =
            '${ts.year}${ts.month.toString().padLeft(2, '0')}${ts.day.toString().padLeft(2, '0')}'
            '_${ts.hour.toString().padLeft(2, '0')}${ts.minute.toString().padLeft(2, '0')}${ts.second.toString().padLeft(2, '0')}';
        final newName = 'statusly_auto_$stamp.$ext';
        final newPath = '$savePath/$newName';

        try {
          await entity.copy(newPath);
          await MediaScanner.loadMedia(path: newPath);
          alreadySaved.add(key);
          newlySavedNames.add(newName);
        } catch (_) {}
      }
    }

    if (newlySavedNames.isNotEmpty) {
      await prefs.setStringList('auto_saved_keys', alreadySaved.toList());
      await _sendNotification(newlySavedNames.length);
    }
  }

  static Future<void> _sendNotification(int count) async {
    final plugin = FlutterLocalNotificationsPlugin();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await plugin.initialize(
      settings: const InitializationSettings(android: android),
    );

    await plugin.show(
      id: 101,
      title: 'Statusly',
      body: '$count new status${count > 1 ? 'es' : ''} auto-saved to gallery!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'statusly_autosave',
          'Auto Save',
          channelDescription: 'Background auto-save notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}

class StatusSaver extends StatefulWidget {
  const StatusSaver({super.key});

  @override
  State<StatusSaver> createState() => _StatusSaverState();
}

class _StatusSaverState extends State<StatusSaver> {
  AppColors colorInst = AppColors.instance;
  List<FileSystemEntity> statuses = [];
  String? savePath;
  bool isLoading = true;
  Set<String> viewedStatuses = {};

  // ── NEW: auto-save state ──────────────────────────────────────────────────
  bool _autoSaveEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadViewedStatuses();
    _loadAutoSaveSetting(); // NEW
    _initializeSavePath();
    _requestPermissionsAndLoad();
    calculateTotalStatuses();
  }

  // ── NEW: load persisted toggle value ─────────────────────────────────────
  Future<void> _loadAutoSaveSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoSaveEnabled = prefs.getBool('auto_save_enabled') ?? false;
    });
  }

  // ── NEW: toggle auto-save on/off ─────────────────────────────────────────
  Future<void> _toggleAutoSave(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_save_enabled', value);

    if (value) {
      // Register background periodic task (minimum 15 min — Android limit)
      await Workmanager().registerPeriodicTask(
        kAutoSaveTask,
        kAutoSaveTask,
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        constraints: Constraints(networkType: NetworkType.notRequired),
      );
      if (mounted) {
        Get.showSnackbar(
          GetSnackBar(
            message: '✅ Auto-save ON — runs every 15 min in background',
            snackStyle: SnackStyle.FLOATING,
            snackPosition: SnackPosition.TOP,
          ),
        );
      }
    } else {
      await Workmanager().cancelByUniqueName(kAutoSaveTask);
      if (mounted) {
        Get.showSnackbar(
          GetSnackBar(
            message: 'Auto-save disabled',
            snackStyle: SnackStyle.FLOATING,
            snackPosition: SnackPosition.TOP,
          ),
        );
      }
    }

    setState(() => _autoSaveEnabled = value);
  }

  // ── NEW: manual trigger (runs immediately, same logic as background) ──────
  Future<void> _runManualAutoSave() async {
    Get.showSnackbar(
      const GetSnackBar(
        message: 'Checking for new statuses...',
        snackStyle: SnackStyle.FLOATING,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      ),
    );
    await AutoSaveService.runAutoSave();
  }

  // ════════ ALL YOUR EXISTING METHODS REMAIN UNCHANGED BELOW ════════════════

  Future<void> _loadViewedStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    final viewed = prefs.getStringList('viewed_statuses') ?? [];
    setState(() {
      viewedStatuses = viewed.toSet();
    });
  }

  Future<void> _saveViewedStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('viewed_statuses', viewedStatuses.toList());
  }

  Future<void> _toggleViewStatus(String filePath) async {
    setState(() {
      if (viewedStatuses.contains(filePath)) {
        viewedStatuses.remove(filePath);
      } else {
        viewedStatuses.add(filePath);
      }
    });
    await _saveViewedStatuses();
  }

  bool _isViewed(String filePath) => viewedStatuses.contains(filePath);

  Future<void> _initializeSavePath() async {
    savePath = '/storage/emulated/0/Pictures/Statusly';
    final saveDir = Directory(savePath!);
    if (!await saveDir.exists()) await saveDir.create(recursive: true);
    final noMediaFile = File('$savePath/.nomedia');
    if (await noMediaFile.exists()) await noMediaFile.delete();
  }

  Future<void> _requestPermissionsAndLoad() async {
    if (await Permission.manageExternalStorage.isGranted) {
      await _loadStatuses();
    } else if (await Permission.manageExternalStorage.request().isGranted) {
      await _loadStatuses();
    } else if (await Permission.storage.request().isGranted) {
      await _loadStatuses();
    } else {
      setState(() => isLoading = false);
      if (mounted) {
        Get.showSnackbar(
          GetSnackBar(
            message: 'Storage permission is required to access statuses',
            snackStyle: SnackStyle.GROUNDED,
          ),
        );
      }
    }
  }

  bool _isSupportedFile(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.png') ||
        p.endsWith('.webp') ||
        p.endsWith('.gif') ||
        p.endsWith('.mp4') ||
        p.endsWith('.mkv') ||
        p.endsWith('.3gp');
  }

  bool _isVideoFile(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.mp4') || p.endsWith('.mkv') || p.endsWith('.3gp');
  }

  // ── Uses AutoSaveService.allPaths so no duplication ───────────────────────
  Future<void> _loadStatuses() async {
    setState(() => isLoading = true);
    try {
      List<FileSystemEntity> allFiles = [];
      Set<String> seenKeys = {};

      for (final path in AutoSaveService.allPaths) {
        final dir = Directory(path);
        if (!await dir.exists()) continue;
        debugPrint('✅ Found statuses at: $path');

        for (final file in dir.listSync().where(
          (e) => _isSupportedFile(e.path),
        )) {
          final fileName = file.path.split('/').last;
          final fileSize = File(file.path).lengthSync();
          final key = '${fileName}_$fileSize';
          if (!seenKeys.contains(key)) {
            seenKeys.add(key);
            allFiles.add(file);
          }
        }
      }

      allFiles.sort(
        (a, b) => File(
          b.path,
        ).lastModifiedSync().compareTo(File(a.path).lastModifiedSync()),
      );

      setState(() {
        statuses = allFiles;
        isLoading = false;
      });
      calculateTotalStatuses();
    } catch (e) {
      debugPrint('❌ Error loading statuses: $e');
      setState(() {
        statuses = [];
        isLoading = false;
      });
    }
  }

  Future<void> saveStatus(File file) async {
    try {
      if (savePath == null) await _initializeSavePath();
      final extension = file.path.split('.').last.toLowerCase();
      final timestamp = DateTime.now();
      final formattedDate =
          '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}';
      final fileName = 'statusly_$formattedDate.$extension';
      final newPath = '$savePath/$fileName';
      var finalPath = newPath;
      var counter = 1;
      while (await File(finalPath).exists()) {
        finalPath = '$savePath/statusly_${formattedDate}_$counter.$extension';
        counter++;
        if (counter > 99) break;
      }
      await file.copy(finalPath);
      await MediaScanner.loadMedia(path: finalPath);
      if (mounted) {
        Get.showSnackbar(
          GetSnackBar(
            message: 'Saved to your gallery',
            snackStyle: SnackStyle.FLOATING,
            snackPosition: SnackPosition.TOP,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving status: $e');
      if (mounted) {
        Get.showSnackbar(
          GetSnackBar(
            message: 'Failed to save: $e',
            snackStyle: SnackStyle.FLOATING,
            snackPosition: SnackPosition.TOP,
          ),
        );
      }
    }
  }

  void shareStatus(File file) async {
    try {
      final s = SharePlus.instance;
      s.share(
        ShareParams(files: [XFile(file.path)], text: 'Check out this status'),
      );
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          textStyle: const TextStyle(fontFamily: 'Mooli'),
          message: 'Failed to share: $e',
          backgroundColor: colorInst.redColor,
        );
      }
    }
  }

  void _openFullView(File file, bool isVideo) {
    if (!_isViewed(file.path)) _toggleViewStatus(file.path);
    Get.to(
      FullScreenViewer(
        file: file,
        isVideo: isVideo,
        onSave: () => saveStatus(file),
        onShare: () => shareStatus(file),
      ),
    );
  }

  final c1 = Get.put(StatusHandlerController());
  int calculateTotalStatuses() {
    c1.countStatuses.value = statuses.length;
    return c1.getTotalStatuses(statuses.length);
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ThemeController>();
    final selectedTheme = c.isDarkMode.value
        ? colorInst.whiteColor
        : colorInst.greyColor;

    return Scaffold(
      drawer: MyDrawer(),
      appBar: MyAppBar(
        'Statusly',
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
            child: Row(
              children: [
                // ── NEW: Auto-save toggle in AppBar ─────────────────────
                Tooltip(
                  message: _autoSaveEnabled ? 'Auto-save ON' : 'Auto-save OFF',
                  child: GestureDetector(
                    onLongPress: _runManualAutoSave, // long-press = save now
                    child: Switch(
                      value: _autoSaveEnabled,
                      onChanged: _toggleAutoSave,
                      activeColor: colorInst.whiteColor,
                      activeTrackColor: Colors.green.shade400,
                      inactiveThumbColor: colorInst.whiteColor,
                      inactiveTrackColor: Colors.white24,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(AppIcons.refreshIcon, color: colorInst.whiteColor),
                  onPressed: _loadStatuses,
                  tooltip: 'Refresh',
                ),
                IconButton(
                  icon: Icon(AppIcons.infoIcon, color: colorInst.whiteColor),
                  onPressed: () {
                    context.showSnackBar(
                      textStyle: const TextStyle(fontFamily: 'Mooli'),
                      message: 'snack'.tr,
                      duration: const Duration(seconds: 4),
                    );
                  },
                  tooltip: 'Save Location',
                ),
              ],
            ),
          ),
        ],
      ),
      // ── NEW: Auto-save banner shown below AppBar when enabled ─────────────
      body: Column(
        children: [
          if (_autoSaveEnabled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade400],
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_done_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: UIHelper.text(
                      'Auto-save active — new statuses saved every 15 min even without opening app',
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                  // Manual trigger button
                  GestureDetector(
                    onTap: _runManualAutoSave,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: UIHelper.text(
                        'Save Now',
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── YOUR EXISTING BODY CONTENT (unchanged) ───────────────────────
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            color: colorInst.appColor,
                            strokeWidth: 4,
                            backgroundColor: colorInst.appColor.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        UIHelper.text(
                          'Loading statuses...',
                          color: colorInst.greyColor,
                          fontSize: 16,
                        ),
                        const SizedBox(height: 8),
                        UIHelper.text(
                          'Checking all WhatsApp variants...',
                          color: colorInst.greyColor.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ],
                    ),
                  )
                : statuses.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: c.isDarkMode.value
                                    ? [
                                        colorInst.appColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        colorInst.appColor.withValues(
                                          alpha: 0.05,
                                        ),
                                      ]
                                    : [
                                        colorInst.whiteColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        colorInst.whiteColor.withValues(
                                          alpha: 0.05,
                                        ),
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: c.isDarkMode.value
                                    ? colorInst.whiteColor
                                    : colorInst.appColor.withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              AppIcons.folderIcon,
                              size: 70,
                              color: c.isDarkMode.value
                                  ? colorInst.whiteColor
                                  : colorInst.appColor,
                            ),
                          ),
                          const SizedBox(height: 32),
                          UIHelper.text(
                            'no_statuses'.tr,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: c.isDarkMode.value
                                ? colorInst.whiteColor
                                : colorInst.appColor,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: UIHelper.text(
                              'about_whatsapp'.tr,
                              color: colorInst.greyColor,
                              textAlign: TextAlign.center,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _requestPermissionsAndLoad,
                            icon: Icon(AppIcons.refreshIcon, size: 20),
                            label: UIHelper.text(
                              'refresh'.tr,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: c.isDarkMode.value
                                  ? colorInst.whiteColor
                                  : colorInst.appColor,
                              foregroundColor: c.isDarkMode.value
                                  ? colorInst.appColor
                                  : colorInst.whiteColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorInst.appColor.withValues(alpha: 0.08),
                              colorInst.appColor.withValues(alpha: 0.03),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: colorInst.greyColor.withValues(
                                alpha: 0.15,
                              ),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: c.isDarkMode.value
                                    ? colorInst.whiteColor.withValues(
                                        alpha: 0.1,
                                      )
                                    : colorInst.appColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                AppIcons.photolibIcon,
                                size: 22,
                                color: c.isDarkMode.value
                                    ? colorInst.whiteColor
                                    : colorInst.appColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  UIHelper.text(
                                    '${statuses.length} Available Status${statuses.length != 1 ? 'es' : ''}',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: selectedTheme,
                                  ),
                                  const SizedBox(height: 4),
                                  UIHelper.text(
                                    'Tap to view, save or share',
                                    fontSize: 12,
                                    color: selectedTheme,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorInst.whiteColor,
                                colorInst.greyColor.shade50,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: statuses.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.72,
                                ),
                            itemBuilder: (_, i) {
                              final file = File(statuses[i].path);
                              final isVideo = _isVideoFile(file.path);
                              final isViewed = _isViewed(file.path);
                              return StatusCard(
                                file: file,
                                isVideo: isVideo,
                                isViewed: isViewed,
                                onTap: () => _openFullView(file, isVideo),
                                onSave: () => saveStatus(file),
                                onShare: () => shareStatus(file),
                                onToggleView: () =>
                                    _toggleViewStatus(file.path),
                                isDarkmode: false,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
