import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:framatic/core/utils/constants.dart';
import 'package:framatic/core/utils/db.dart';
import 'package:framatic/features/camera/presentation/camera_provider.dart';
import 'package:framatic/features/camera/presentation/camera_screen.dart';
import 'package:framatic/features/frames_manager/data/frame_service.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:framatic/features/photo_preview/data/photo_service.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_provider.dart';
import 'package:provider/provider.dart';

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
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FrameProvider(FrameService())),
        ChangeNotifierProvider(create: (_) => CameraProvider()),
        ChangeNotifierProvider(create: (_) => PhotoPreviewProvider(PhotoService())),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: ThemeData(brightness: Brightness.dark),
        home: const CameraScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
