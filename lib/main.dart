import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:framatic/core/utils/app_themes.dart';
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
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FrameProvider(FrameService())),
        ChangeNotifierProvider(create: (_) => CameraProvider(CameraService())),
        ChangeNotifierProvider(
          create: (_) => PhotoPreviewProvider(PhotoService()),
        ),
      ],
      child: SketchyApp(
        title: AppConstants.appName,
        theme: resolveTheme(activeScheme).light,
        darkTheme: resolveTheme(activeScheme).dark,
        themeMode: SketchyThemeMode.system,
        home: const CameraScreen(),
      ),
    );
  }
}
