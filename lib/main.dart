import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:framatic/providers/frame_provider.dart';
import 'package:framatic/screens/camera_screen.dart';
import 'package:framatic/utils/constants.dart';
import 'package:framatic/utils/db.dart';
import 'package:framatic/utils/frame_order_preferences.dart';
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

  try {
    await FrameOrderPreferences.initialize();
  } catch (e) {
    if (kDebugMode) {
      print('Failed to initialize FrameOrderPreferences: $e');
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
        ChangeNotifierProvider(
          create: (context) => FrameProvider()..initialize(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
        home: const CameraScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
