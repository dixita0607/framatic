import 'package:flutter/widgets.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

// ── Change this to switch the active color scheme ──────────────────────────
const activeScheme = AppTheme.graphite;
// ───────────────────────────────────────────────────────────────────────────

enum AppTheme {
  midnightStudy,
  midnightBlue,
  midnightGreen,
  warmParchment,
  goldenHour,
  dustyRose,
  citrusAndOcean,
  mintAndCoral,
  lavenderAndAmber,
  graphite,
}

({SketchyThemeData light, SketchyThemeData dark}) resolveTheme(AppTheme scheme) {
  return switch (scheme) {
    AppTheme.midnightStudy   => _midnightStudy,
    AppTheme.midnightBlue    => _midnightBlue,
    AppTheme.midnightGreen   => _midnightGreen,
    AppTheme.warmParchment   => _warmParchment,
    AppTheme.goldenHour      => _goldenHour,
    AppTheme.dustyRose       => _dustyRose,
    AppTheme.citrusAndOcean  => _citrusAndOcean,
    AppTheme.mintAndCoral    => _mintAndCoral,
    AppTheme.lavenderAndAmber => _lavenderAndAmber,
    AppTheme.graphite          => _graphite,
  };
}

// ── Midnight family ────────────────────────────────────────────────────────

// Blues + purples + green — like annotated graph paper
final _midnightStudy = (
  light: SketchyThemeData(
    inkColor:       const Color(0xFF1A1828),
    paperColor:     const Color(0xFFD4D8E8),
    primaryColor:   const Color(0xFF5040A0),
    secondaryColor: const Color(0xFF9890C0),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
  dark: SketchyThemeData(
    inkColor:       const Color(0xFFD8D4F0),
    paperColor:     const Color(0xFF141220),
    primaryColor:   const Color(0xFF8878D8),
    secondaryColor: const Color(0xFF302848),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
);

// Royal blue dominant — cooler and more focused than midnightStudy
final _midnightBlue = (
  light: SketchyThemeData(
    inkColor:       const Color(0xFF0E1828),
    paperColor:     const Color(0xFFD0D8EC),
    primaryColor:   const Color(0xFF1E5FA0),
    secondaryColor: const Color(0xFF7090C0),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
  dark: SketchyThemeData(
    inkColor:       const Color(0xFFC8D8F0),
    paperColor:     const Color(0xFF0C1220),
    primaryColor:   const Color(0xFF5090D8),
    secondaryColor: const Color(0xFF1A2C48),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
);

// Forest green dominant — like nature field notes
final _midnightGreen = (
  light: SketchyThemeData(
    inkColor:       const Color(0xFF0A1C12),
    paperColor:     const Color(0xFFC8D8CC),
    primaryColor:   const Color(0xFF1A6B40),
    secondaryColor: const Color(0xFF70A880),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
  dark: SketchyThemeData(
    inkColor:       const Color(0xFFC0E0CC),
    paperColor:     const Color(0xFF0C1810),
    primaryColor:   const Color(0xFF4AB878),
    secondaryColor: const Color(0xFF143020),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
);

// ── Warm family ────────────────────────────────────────────────────────────

// Aged journal — ink is dark warm brown, not black
final _warmParchment = (
  light: SketchyThemeData(
    inkColor:       const Color(0xFF3C2010),
    paperColor:     const Color(0xFFEDE0C8),
    primaryColor:   const Color(0xFF8B5E3C),
    secondaryColor: const Color(0xFFC8AD88),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
  dark: SketchyThemeData(
    inkColor:       const Color(0xFFF0DCC0),
    paperColor:     const Color(0xFF201808),
    primaryColor:   const Color(0xFFD08050),
    secondaryColor: const Color(0xFF3C2810),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
);

// Warm yellow parchment — sunlit notebook, amber primary
final _goldenHour = (
  light: SketchyThemeData(
    inkColor:       const Color(0xFF2C1C00),
    paperColor:     const Color(0xFFF0E4B0),
    primaryColor:   const Color(0xFFB87800),
    secondaryColor: const Color(0xFFD4C060),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
  dark: SketchyThemeData(
    inkColor:       const Color(0xFFF8E8A0),
    paperColor:     const Color(0xFF1C1400),
    primaryColor:   const Color(0xFFE8A020),
    secondaryColor: const Color(0xFF3C2C00),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
);

// Blush paper — ink is dark burgundy, not black
final _dustyRose = (
  light: SketchyThemeData(
    inkColor:       const Color(0xFF2C1018),
    paperColor:     const Color(0xFFE8D8D8),
    primaryColor:   const Color(0xFFA04060),
    secondaryColor: const Color(0xFFC0A0A8),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
  dark: SketchyThemeData(
    inkColor:       const Color(0xFFF0D8DC),
    paperColor:     const Color(0xFF1C0C10),
    primaryColor:   const Color(0xFFD86088),
    secondaryColor: const Color(0xFF3C1828),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
);

// ── Complementary pairs ────────────────────────────────────────────────────

// Peach/orange paper × deep ocean blue — warm meets cool
final _citrusAndOcean = (
  light: SketchyThemeData(
    inkColor:       const Color(0xFF1A0C00),
    paperColor:     const Color(0xFFF0D8C0),
    primaryColor:   const Color(0xFF1E5888),
    secondaryColor: const Color(0xFFD0A878),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
  dark: SketchyThemeData(
    inkColor:       const Color(0xFFF4D8B8),
    paperColor:     const Color(0xFF200E04),
    primaryColor:   const Color(0xFF4A90C8),
    secondaryColor: const Color(0xFF3C2010),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
);

// Mint paper × deep coral — fresh and warm in tension
final _mintAndCoral = (
  light: SketchyThemeData(
    inkColor:       const Color(0xFF0A1E1C),
    paperColor:     const Color(0xFFC8E8E0),
    primaryColor:   const Color(0xFFC04840),
    secondaryColor: const Color(0xFF90C8C0),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
  dark: SketchyThemeData(
    inkColor:       const Color(0xFFC0E8E0),
    paperColor:     const Color(0xFF081614),
    primaryColor:   const Color(0xFFE87060),
    secondaryColor: const Color(0xFF102820),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
);

// Soft lavender paper × warm amber — dreamy with golden accents
final _lavenderAndAmber = (
  light: SketchyThemeData(
    inkColor:       const Color(0xFF180C28),
    paperColor:     const Color(0xFFE0D4F0),
    primaryColor:   const Color(0xFFC07810),
    secondaryColor: const Color(0xFFB8A8D8),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
  dark: SketchyThemeData(
    inkColor:       const Color(0xFFE4D8F8),
    paperColor:     const Color(0xFF120820),
    primaryColor:   const Color(0xFFE8A040),
    secondaryColor: const Color(0xFF281840),
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
);

// ── Monochrome ─────────────────────────────────────────────────────────────

// Copic cool grey palette — pure dark paper, near-white ink.
// Dark is the intended default; light is the inverse for system light mode.
final _graphite = (
  light: SketchyThemeData(
    inkColor:       const Color(0xFF141414), // C-10 near-black
    paperColor:     const Color(0xFFF0F0F0), // C-0 near-white
    primaryColor:   const Color(0xFF393939), // C-9 dark grey
    secondaryColor: const Color(0xFFB0B0B0), // C-4 mid grey
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
  dark: SketchyThemeData(
    inkColor:       const Color(0xFFF0F0F0), // C-0 near-white
    paperColor:     const Color(0xFF141414), // C-10 near-black
    primaryColor:   const Color(0xFFD8D8D8), // C-2 light grey
    secondaryColor: const Color(0xFF424242), // C-8/9 dark grey
    roughness: 0.35,
    typography: SketchyTypographyData.comicShanns(),
  ),
);
