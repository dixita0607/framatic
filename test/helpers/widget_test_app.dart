import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

Widget sketchTestApp(Widget home) {
  const theme = SketchThemeCatalog.monochromeLight;
  return SketchTheme(
    data: theme,
    child: WidgetsApp(
      color: theme.background,
      textStyle: theme.bodyStyle,
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
      ),
      home: DefaultTextStyle(style: theme.bodyStyle, child: home),
    ),
  );
}
