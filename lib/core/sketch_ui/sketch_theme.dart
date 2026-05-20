import 'package:flutter/widgets.dart';

class SketchThemeData {
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

  static const dark = SketchThemeCatalog.monochromeDark;
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

  static const monochromeDark = SketchThemeData(
    background: Color(0xFF050505),
    panel: Color(0xFF151515),
    panelStrong: Color(0xFF202020),
    ink: Color(0xFFF2F2EE),
    mutedInk: Color(0xFFB8B8B0),
    paper: Color(0xFFEDEDE6),
    paperInk: Color(0xFF111111),
    accent: Color(0xFFFFFFFF),
    primaryInk: Color(0xFF111111),
    danger: Color(0xFFE06767),
    disabled: Color(0xFF696969),
    hachure: Color(0x334F4F4F),
    strokeWidth: 1.8,
    roughness: 1.35,
    bodyStyle: TextStyle(color: Color(0xFFF2F2EE), fontSize: 16, height: 1.25),
    labelStyle: TextStyle(
      color: Color(0xFFB8B8B0),
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w600,
    ),
    titleStyle: TextStyle(
      color: Color(0xFFF2F2EE),
      fontSize: 20,
      height: 1.2,
      fontWeight: FontWeight.w700,
    ),
  );

  static const monochromeLight = SketchThemeData(
    background: Color(0xFFF7F7F2),
    panel: Color(0xFFEDEDE6),
    panelStrong: Color(0xFFE1E1D8),
    ink: Color(0xFF111111),
    mutedInk: Color(0xFF5E5E59),
    paper: Color(0xFFFFFFFF),
    paperInk: Color(0xFF111111),
    accent: Color(0xFF111111),
    primaryInk: Color(0xFFFFFFFF),
    danger: Color(0xFFB83C3C),
    disabled: Color(0xFFAAA99F),
    hachure: Color(0x26242424),
    strokeWidth: 1.8,
    roughness: 1.35,
    bodyStyle: TextStyle(color: Color(0xFF111111), fontSize: 16, height: 1.25),
    labelStyle: TextStyle(
      color: Color(0xFF5E5E59),
      fontSize: 13,
      height: 1.2,
      fontWeight: FontWeight.w600,
    ),
    titleStyle: TextStyle(
      color: Color(0xFF111111),
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
