import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

Widget buildTestApp(Widget home) {
  const theme = SketchThemeCatalog.graphiteLight;
  return SketchTheme(
    data: theme,
    child: WidgetsApp(
      color: theme.background,
      textStyle: theme.bodyText,
      pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
      ),
      home: DefaultTextStyle(style: theme.bodyText, child: home),
    ),
  );
}
