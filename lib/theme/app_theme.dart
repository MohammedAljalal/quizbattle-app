import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// QuizBattle Design System
/// Palette: Deep indigo canvas · Electric violet primary · Coral accent
/// Typeface: IBM Plex Sans Arabic for UI · Sora for numerics/scores
/// Signature: Frosted glass cards with colored left-border "signal strip"
class AppTheme {

  // ── Palette ────────────────────────────────────────────────────────────────
  // Canvas: true black-blue, not generic dark grey
  static const Color canvas       = Color(0xFF080811);
  static const Color canvasRaised = Color(0xFF0F0F1E);
  static const Color canvasCard   = Color(0xFF141428);
  static const Color canvasBorder = Color(0xFF1E1E3A);
  static const Color canvasMuted  = Color(0xFF272748);

  // Primary: electric indigo — unique, not generic purple
  static const Color primary      = Color(0xFF6B4EFF);
  static const Color primaryHover = Color(0xFF8670FF);
  static const Color primaryDim   = Color(0xFF3D2E99);
  static const Color primaryGlow  = Color(0x336B4EFF);

  // Accent: energetic coral — warm counterpoint to cool indigo
  static const Color coral        = Color(0xFFFF5A5A);
  static const Color coralDim     = Color(0x33FF5A5A);

  // Signal colors — pure, unmixed
  static const Color signalGreen  = Color(0xFF00D48B);
  static const Color signalAmber  = Color(0xFFFFB020);
  static const Color signalRed    = Color(0xFFFF4757);
  static const Color signalBlue   = Color(0xFF3B9EFF);

  // Gold for leaderboard
  static const Color gold         = Color(0xFFFFCC00);
  static const Color silver       = Color(0xFFC0C8D0);
  static const Color bronze       = Color(0xFFE8915A);

  // Text
  static const Color ink          = Color(0xFFF2F2FF);
  static const Color inkSecondary = Color(0xFF8888BB);
  static const Color inkMuted     = Color(0xFF44445A);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF6B4EFF), Color(0xFFFF5A5A)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const LinearGradient deepGradient = LinearGradient(
    colors: [Color(0xFF080811), Color(0xFF0F0F1E)],
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00D48B), Color(0xFF00A86B)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFCC00), Color(0xFFFF9900)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  static const LinearGradient coralGradient = LinearGradient(
    colors: [Color(0xFFFF5A5A), Color(0xFFFF8A00)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  // ── Shadows ────────────────────────────────────────────────────────────────
  static List<BoxShadow> get primaryShadow => [
    BoxShadow(color: primary.withOpacity(0.35),
        blurRadius: 24, spreadRadius: -6, offset: const Offset(0, 8)),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: Colors.black.withOpacity(0.4),
        blurRadius: 16, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> get coralShadow => [
    BoxShadow(color: coral.withOpacity(0.35),
        blurRadius: 24, spreadRadius: -6, offset: const Offset(0, 8)),
  ];

  // ── Radii ──────────────────────────────────────────────────────────────────
  static const double radiusXs  = 8;
  static const double radiusSm  = 12;
  static const double radiusMd  = 16;
  static const double radiusLg  = 20;
  static const double radiusXl  = 28;
  static const double radiusFull = 999;

  // ── Typography ─────────────────────────────────────────────────────────────
  // IBM Plex Sans Arabic: purposeful, legible, not "pretty-Arabic"
  // Sora: geometric, confident — for scores and large numerics
  static TextStyle display(double size, {FontWeight w = FontWeight.w900, Color? color}) =>
      GoogleFonts.sora(fontSize: size, fontWeight: w,
          color: color ?? ink, letterSpacing: -0.5, height: 1.1);

  static TextStyle body(double size, {FontWeight w = FontWeight.w400, Color? color}) =>
      GoogleFonts.ibmPlexSansArabic(fontSize: size, fontWeight: w,
          color: color ?? inkSecondary, height: 1.5);

  static TextStyle label(double size, {FontWeight w = FontWeight.w600, Color? color}) =>
      GoogleFonts.ibmPlexSansArabic(fontSize: size, fontWeight: w,
          color: color ?? inkSecondary, letterSpacing: 0.2);

  // ── Theme ──────────────────────────────────────────────────────────────────
  static ThemeData get theme {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: canvas,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary, secondary: coral,
        surface: canvasCard, error: signalRed,
        onPrimary: Colors.white, onSurface: ink,
      ),
      textTheme: GoogleFonts.ibmPlexSansArabicTextTheme().copyWith(
        displayLarge: display(40),
        displayMedium: display(32),
        headlineLarge: display(26),
        headlineMedium: body(20, w: FontWeight.w700, color: ink),
        headlineSmall: body(17, w: FontWeight.w600, color: ink),
        titleLarge: body(16, w: FontWeight.w600, color: ink),
        titleMedium: body(14, w: FontWeight.w500, color: ink),
        bodyLarge: body(15, color: inkSecondary),
        bodyMedium: body(13, color: inkSecondary),
        bodySmall: body(11, color: inkMuted),
        labelLarge: label(14),
        labelMedium: label(12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          textStyle: GoogleFonts.ibmPlexSansArabic(
              fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd)),
          textStyle: GoogleFonts.ibmPlexSansArabic(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: canvasRaised,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: canvasBorder, width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: signalRed, width: 1)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: signalRed, width: 2)),
        labelStyle: body(14, color: inkSecondary),
        hintStyle: body(14, color: inkMuted),
        prefixIconColor: inkMuted,
        suffixIconColor: inkMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardTheme(
        color: canvasCard, elevation: 0, margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, elevation: 0,
        scrolledUnderElevation: 0, centerTitle: true,
        titleTextStyle: GoogleFonts.ibmPlexSansArabic(
            color: ink, fontSize: 17, fontWeight: FontWeight.w700),
        iconTheme: const IconThemeData(color: ink),
        actionsIconTheme: const IconThemeData(color: ink),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: canvasMuted,
        contentTextStyle: body(13, color: ink),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd)),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        insetPadding: const EdgeInsets.all(16),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: canvasCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXl)),
        titleTextStyle: GoogleFonts.ibmPlexSansArabic(
            color: ink, fontSize: 18, fontWeight: FontWeight.w700),
        contentTextStyle: body(14, color: inkSecondary),
        elevation: 24,
      ),
      dividerTheme: const DividerThemeData(color: canvasBorder, thickness: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : inkMuted),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : canvasMuted),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primary, thumbColor: primary,
        inactiveTrackColor: canvasMuted,
        overlayColor: primaryGlow,
      ),
    );
  }

  // ── Backward-compat aliases (v2 screens compile unchanged) ───────────────
  static const Color bg            = canvas;
  static const Color bgCard        = canvasCard;
  static const Color bgSurface     = canvasRaised;
  static const Color bgElevated    = canvasMuted;
  static const Color surface       = canvasCard;
  static const Color cardColor     = canvasCard;
  static const Color textPrimary   = ink;
  static const Color textSecondary = inkSecondary;
  static const Color textMuted     = inkMuted;
  static const Color primaryLight  = primaryHover;
  static const Color primaryGlow2  = primaryGlow;
  static const Color success       = signalGreen;
  static const Color error         = signalRed;
  static const Color warning       = signalAmber;
  static const Color info          = signalBlue;
  static const Color accent        = coral;
  static const Color secondary     = gold;

  static const LinearGradient primaryGradient = heroGradient;
  static List<BoxShadow> get primaryShadow => [
    BoxShadow(color: primary.withOpacity(0.35),
        blurRadius: 24, spreadRadius: -6, offset: const Offset(0, 8)),
  ];

}
