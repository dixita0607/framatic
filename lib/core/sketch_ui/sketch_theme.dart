import 'package:flutter/widgets.dart';

class SketchThemeData {
  final Color success;
  final Color background;
  final Color panel;
  final Color panelStrong;
  final Color ink;
  final Color mutedInk;
  final Color paper;
  final Color paperInk;
  final Color accent;
  final Color primary;
  final Color primaryInk;
  final Color danger;
  final Color disabled;
  final Color hachure;
  final double strokeWidth;
  final double roughness;
  final TextStyle bodyStyle;
  final TextStyle labelStyle;
  final TextStyle titleStyle;

  const SketchThemeData({
    required this.success,
    required this.background,
    required this.panel,
    required this.panelStrong,
    required this.ink,
    required this.mutedInk,
    required this.paper,
    required this.paperInk,
    required this.accent,
    Color? primary,
    Color? primaryInk,
    required this.danger,
    required this.disabled,
    required this.hachure,
    required this.strokeWidth,
    required this.roughness,
    required this.bodyStyle,
    required this.labelStyle,
    required this.titleStyle,
  }) : primary = primary ?? accent,
       primaryInk = primaryInk ?? paperInk;

  static const dark = SketchThemeCatalog.graphiteDark;
}

enum SketchBackgroundKind { isometricDots }

class SketchBackgroundData {
  final SketchBackgroundKind kind;
  final double spacing;
  final double secondarySpacing;
  final double opacity;
  final double strokeWidth;

  const SketchBackgroundData({
    required this.kind,
    required this.spacing,
    this.secondarySpacing = 0,
    this.opacity = 0.16,
    this.strokeWidth = 1,
  });
}

class SketchBackgroundCatalog {
  const SketchBackgroundCatalog._();

  static const isometricDots = SketchBackgroundData(
    kind: SketchBackgroundKind.isometricDots,
    spacing: 22,
    secondarySpacing: 19,
    opacity: 0.18,
  );
}

class SketchThemeCatalog {
  const SketchThemeCatalog._();

  static const _darkInk = Color(0xFFF0F0F0);
  static const _darkPaper = Color(0xFF252525);
  static const _darkPrimary = Color(0xFFD8D8D8);
  static const _darkSecondary = Color(0xFFA8A8A8);
  static const _darkError = Color(0xFFE06767);
  static const _darkSuccess = Color(0xFF8DBF93);

  static const _lightInk = Color(0xFF141414);
  static const _lightPaper = Color(0xFFF0F0F0);
  static const _lightPrimary = Color(0xFF393939);
  static const _lightSecondary = Color(0xFF787878);
  static const _lightError = Color(0xFFB95B5B);
  static const _lightSuccess = Color(0xFF357A45);

  static const graphiteDark = SketchThemeData(
    success: _darkSuccess,
    background: _darkPaper,
    panel: _darkPaper,
    panelStrong: _darkPaper,
    ink: _darkInk,
    mutedInk: _darkSecondary,
    paper: _darkPaper,
    paperInk: _darkInk,
    accent: _darkPrimary,
    primary: _darkPrimary,
    primaryInk: _darkPaper,
    danger: _darkError,
    disabled: _darkSecondary,
    hachure: Color(0x33F0F0F0),
    strokeWidth: 1.8,
    roughness: 1.35,
    bodyStyle: TextStyle(color: _darkInk, fontSize: 16, height: 1.25),
    labelStyle: TextStyle(
      color: _darkSecondary,
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w600,
    ),
    titleStyle: TextStyle(
      color: _darkInk,
      fontSize: 20,
      height: 1.2,
      fontWeight: FontWeight.w700,
    ),
  );

  static const graphiteLight = SketchThemeData(
    success: _lightSuccess,
    background: _lightPaper,
    panel: _lightPaper,
    panelStrong: _lightPaper,
    ink: _lightInk,
    mutedInk: _lightSecondary,
    paper: _lightPaper,
    paperInk: _lightInk,
    accent: _lightPrimary,
    primary: _lightPrimary,
    primaryInk: _lightPaper,
    danger: _lightError,
    disabled: _lightSecondary,
    hachure: Color(0x26141414),
    strokeWidth: 1.8,
    roughness: 1.35,
    bodyStyle: TextStyle(color: _lightInk, fontSize: 16, height: 1.25),
    labelStyle: TextStyle(
      color: _lightSecondary,
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w600,
    ),
    titleStyle: TextStyle(
      color: _lightInk,
      fontSize: 20,
      height: 1.2,
      fontWeight: FontWeight.w700,
    ),
  );
}

class SketchTheme extends InheritedWidget {
  final SketchThemeData data;
  final SketchBackgroundData background;

  const SketchTheme({
    super.key,
    required this.data,
    this.background = SketchBackgroundCatalog.isometricDots,
    required super.child,
  });

  static SketchThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<SketchTheme>();
    return theme?.data ?? SketchThemeData.dark;
  }

  static SketchBackgroundData backgroundOf(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<SketchTheme>();
    return theme?.background ?? SketchBackgroundCatalog.isometricDots;
  }

  @override
  bool updateShouldNotify(SketchTheme oldWidget) =>
      data != oldWidget.data || background != oldWidget.background;
}
