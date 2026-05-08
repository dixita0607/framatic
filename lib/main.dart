import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        theme: SketchyThemeData(
          inkColor: const Color(0xFF1A1A14),
          paperColor: const Color(0xFFC8D0B8),
          primaryColor: const Color(0xFF2E7D68),
          secondaryColor: const Color(0xFFB0BCA0),
          roughness: 0.45,
          typography: SketchyTypographyData.comicShanns(),
        ),
        darkTheme: SketchyThemeData(
          inkColor: const Color(0xFFE4ECD8),
          paperColor: const Color(0xFF151912),
          primaryColor: const Color(0xFF3EA88A),
          secondaryColor: const Color(0xFF1E2418),
          roughness: 0.45,
          typography: SketchyTypographyData.comicShanns(),
        ),
        themeMode: SketchyThemeMode.system,
        home: const CameraScreen(),
      ),
    );
  }
}
