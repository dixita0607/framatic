import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/core/utils/constants.dart';
import 'package:framatic/core/utils/db.dart';
import 'package:framatic/features/camera/data/camera_service.dart';
import 'package:framatic/features/camera/presentation/camera_provider.dart';
import 'package:framatic/features/camera/presentation/camera_screen.dart';
import 'package:framatic/features/frames_manager/data/frame_service.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:framatic/features/photo_preview/data/photo_service.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_provider.dart';
import 'package:provider/provider.dart';

const activeSketchBackground = SketchBackgroundCatalog.isometricDots;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await FramaticDB.instance.open();
  } catch (e) {
    if (kDebugMode) {
      print('Failed to initialize database: $e');
    }
    rethrow;
  }

  PhotoService.cleanupTempFiles().ignore();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final activeSketchTheme = _themeForSystemBrightness();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FrameProvider(FrameService())),
        ChangeNotifierProvider(create: (_) => CameraProvider(CameraService())),
        ChangeNotifierProvider(
          create: (_) => PhotoPreviewProvider(PhotoService()),
        ),
      ],
      child: SketchTheme(
        data: activeSketchTheme,
        background: activeSketchBackground,
        child: WidgetsApp(
          title: AppConstants.appName,
          color: activeSketchTheme.background,
          textStyle: activeSketchTheme.bodyStyle,
          pageRouteBuilder: <T>(settings, builder) =>
              sketchPageRoute<T>(builder, settings: settings),
          home: const CameraScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }

  SketchThemeData _themeForSystemBrightness() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark
        ? SketchThemeCatalog.monochromeDark
        : SketchThemeCatalog.monochromeLight;
  }
}
