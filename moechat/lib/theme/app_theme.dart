import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Centralized design token constants for the MoeChat application.
///
/// All colors, border radii, shadows, font families, and animation durations
/// are defined here to ensure visual consistency across the app.
class AppTheme {
  AppTheme._();

  // ─── Colors ───────────────────────────────────────────────

  /// Overall app background
  static const Color background = Color(0xFFF0F2F5);

  /// Sidebar
  static const Color sidebarBg = Color(0xFF1E1E2E);
  static const Color sidebarText = Color(0xFFCDD6F4);
  static const Color sidebarActive = Color(0xFF313244);
  static const Color sidebarHover = Color(0xFF2A2A3C);

  /// Chat / Panel backgrounds
  static const Color chatBg = Colors.white;
  static const Color panelBg = Colors.white;

  /// Text
  static const Color text = Color(0xFF1E1E2E);
  static const Color textSecondary = Color(0xFF6C7086);

  /// Border
  static const Color border = Color(0xFFE0E0E0);

  /// Primary palette
  static const Color primary = Color(0xFF7C5CFC);
  static const Color primaryHover = Color(0xFF6A4DE0);
  static const Color primaryLight = Color(0xFFEDE8FF);

  /// Danger / Success
  static const Color danger = Color(0xFFE64553);
  static const Color dangerGradientEnd = Color(0xFFFF8FA3);
  static const Color success = Color(0xFF40A02B);

  /// Message bubbles
  static const Color bubbleBot = Color(0xFFE8E0FF);
  static const Color bubbleUser = Color(0xFF7C5CFC);
  static const Color bubbleUserText = Colors.white;

  /// Gradient stops (used in title, cover, etc.)
  static const Color gradientStart = Color(0xFF7C5CFC);
  static const Color gradientMid = Color(0xFFB4A0FF);
  static const Color gradientEnd = Color(0xFFE8DEFF);

  /// Toggle badge colors
  static const Color toggleOnBg = Color(0xFFDCFCE7);
  static const Color toggleOnText = Color(0xFF16A34A);
  static const Color toggleOffBg = Color(0xFFFEF2F2);
  static const Color toggleOffText = Color(0xFFDC2626);

  // ─── Gradients ────────────────────────────────────────────

  /// 135° gradient used for app title and detail cover
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMid, gradientEnd],
  );

  /// Title gradient (two-stop variant)
  static const LinearGradient titleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMid],
  );

  /// Love / affinity bar gradient
  static const LinearGradient loveGradient = LinearGradient(
    colors: [danger, dangerGradientEnd],
  );

  /// Detail cover overlay (bottom-to-top)
  static const LinearGradient coverOverlay = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      Color(0xD91E1E2E), // rgba(30,30,46,0.85)
      Color(0x261E1E2E), // rgba(30,30,46,0.15)
      Colors.transparent,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ─── Border Radius ────────────────────────────────────────

  /// Large radius – 12px
  static const double radiusLarge = 12.0;

  /// Small radius – 8px
  static const double radiusSmall = 8.0;

  static final BorderRadius borderRadiusLarge = BorderRadius.circular(
    radiusLarge,
  );
  static final BorderRadius borderRadiusSmall = BorderRadius.circular(
    radiusSmall,
  );

  // ─── Shadows ──────────────────────────────────────────────

  /// Standard shadow: 0 1px 3px rgba(0,0,0,0.08)
  static const BoxShadow standardShadow = BoxShadow(
    offset: Offset(0, 1),
    blurRadius: 3,
    color: Color(0x14000000), // ~0.08 opacity
  );

  /// Large shadow: 0 8px 32px rgba(0,0,0,0.12)
  static const BoxShadow largeShadow = BoxShadow(
    offset: Offset(0, 8),
    blurRadius: 32,
    color: Color(0x1F000000), // ~0.12 opacity
  );

  /// Stat card hover shadow (purple tint)
  static const BoxShadow statCardHoverShadow = BoxShadow(
    offset: Offset(0, 4),
    blurRadius: 12,
    color: Color(0x1F7C5CFC), // rgba(124,92,252,0.12)
  );

  // ─── Font Family ──────────────────────────────────────────

  /// Primary font: WenYuan Rounded SC variable font (bundled).
  static const String fontFamily = 'WenYuan Rounded SC VF';

  /// System font fallback chain.
  static const List<String> fontFamilyFallback = [
    'Microsoft YaHei UI',
    'Microsoft YaHei',
    'PingFang SC',
    'Segoe UI',
    'sans-serif',
  ];

  static const String fontFamilyMono = 'Cascadia Code';
  static const List<String> fontFamilyMonoFallback = [
    'Fira Code',
    'Consolas',
    'monospace',
  ];

  // ─── Animation Durations ──────────────────────────────────

  /// Standard transition: 0.2s ease
  static const Duration standardDuration = Duration(milliseconds: 200);
  static const Curve standardCurve = Curves.ease;

  /// Detail panel expand/collapse: 0.3s ease
  static const Duration panelDuration = Duration(milliseconds: 300);
  static const Curve panelCurve = Curves.ease;

  /// Typing indicator cycle: 0.8s
  static const Duration typingDuration = Duration(milliseconds: 800);

  /// Call button pulse: 1.5s
  static const Duration callPulseDuration = Duration(milliseconds: 1500);

  /// Tag dot pulse: 1.5s
  static const Duration tagDotPulseDuration = Duration(milliseconds: 1500);

  // ─── Scrollbar ─────────────────────────────────────────────

  /// Default scrollbar width
  static const double scrollbarWidth = 5.0;

  /// Default scrollbar thumb color (light areas)
  static const Color scrollbarThumb = Color(0xFFCCCCCC);

  /// Sidebar scrollbar thumb color (dark areas)
  static const Color scrollbarThumbDark = Color(0xFF555555);

  /// Scrollbar theme for dark backgrounds (sidebar)
  static ScrollbarThemeData scrollbarThemeDark = ScrollbarThemeData(
    thickness: WidgetStateProperty.all(scrollbarWidth),
    thumbColor: WidgetStateProperty.all(scrollbarThumbDark),
    radius: const Radius.circular(4),
    trackColor: WidgetStateProperty.all(Colors.transparent),
    crossAxisMargin: 0,
    mainAxisMargin: 0,
  );

  // ─── Layout Constants ─────────────────────────────────────

  static const double sidebarWidth = 260.0;
  static const double sidebarCollapsedWidth = 60.0;
  static const double detailPanelWidth = 320.0;
  static const double detailCoverHeight = 200.0;

  // ─── ThemeData Builder ────────────────────────────────────

  /// Base [TextStyle] from WenYuan Rounded SC variable font.
  ///
  /// This is a true variable font supporting the `wght` axis (100–900),
  /// so `fontVariations` provides smooth weight interpolation without
  /// faux-bold artifacts on CJK glyphs.
  static TextStyle _baseTextStyle({
    double fontSize = 14,
    double fontWeight = 500,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize,
      fontStyle: fontStyle,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontVariations: [ui.FontVariation('wght', fontWeight)],
    );
  }

  /// Builds the app-wide [ThemeData] using WenYuan Rounded SC variable font.
  static ThemeData buildThemeData() {
    final defaultStyle = _baseTextStyle();

    final baseTextTheme = TextTheme(
      bodyLarge: defaultStyle,
      bodyMedium: defaultStyle,
      bodySmall: defaultStyle.copyWith(fontSize: 12),
      labelLarge: defaultStyle,
      labelMedium: defaultStyle.copyWith(fontSize: 12),
      labelSmall: defaultStyle.copyWith(fontSize: 11),
      titleLarge: _baseTextStyle(fontSize: 22, fontWeight: 500),
      titleMedium: _baseTextStyle(fontSize: 16, fontWeight: 500),
      titleSmall: _baseTextStyle(fontSize: 14, fontWeight: 500),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        surface: background,
      ),
      textTheme: baseTextTheme,
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(scrollbarWidth),
        thumbColor: WidgetStateProperty.all(scrollbarThumb),
        radius: const Radius.circular(4),
        trackColor: WidgetStateProperty.all(Colors.transparent),
        crossAxisMargin: 0,
        mainAxisMargin: 0,
      ),
    );
  }

  /// Creates a [TextStyle] using WenYuan Rounded SC with precise weight control.
  ///
  /// Use this instead of plain `TextStyle(fontWeight: ...)` to get smooth
  /// CJK rendering without faux-bold or stroke inconsistencies.
  ///
  /// [fontWeight] accepts any value from 100 to 900 (e.g. 350, 500).
  static TextStyle cjkStyle({
    double fontSize = 14,
    double fontWeight = 500,
    Color color = text,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return _baseTextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }
}
