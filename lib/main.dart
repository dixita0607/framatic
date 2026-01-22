import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:framatic/providers/frame_provider.dart';
import 'package:framatic/screens/camera_screen.dart';
import 'package:framatic/utils/constants.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const CameraScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
