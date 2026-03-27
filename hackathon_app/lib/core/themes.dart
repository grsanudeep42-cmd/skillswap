import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── ThemeExtension ───────────────────────────────────────────────────────────

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color bg;
  final Color surface1;
  final Color surface2;
  final Color surface3;
  final Color border;
  final Color borderStrong;
  final Color textPrimary;
  final Color textMuted;
  final Color textHint;
  final Color green;
  final Color cyan;
  final Color purple;
  final Color red;

  const AppColorsExtension({
    required this.bg,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textMuted,
    required this.textHint,
    required this.green,
    required this.cyan,
    required this.purple,
    required this.red,
  });

  static const dark = AppColorsExtension(
    bg:           Color(0xFF0A0A0A),
    surface1:     Color(0xFF111111),
    surface2:     Color(0xFF151515),
    surface3:     Color(0xFF1A1A1A),
    border:       Color(0xFF1E1E1E),
    borderStrong: Color(0xFF2A2A2A),
    textPrimary:  Color(0xFFF5F5F5),
    textMuted:    Color(0xFFAAAAAA),
    textHint:     Color(0xFF787878),
    green:        Color(0xFF00E676),
    cyan:         Color(0xFF00E5FF),
    purple:       Color(0xFF7C3AED),
    red:          Color(0xFFFF5252),
  );

  static const light = AppColorsExtension(
    bg:           Color(0xFFF7F7FA),
    surface1:     Color(0xFFFFFFFF),
    surface2:     Color(0xFFF2F2F7),
    surface3:     Color(0xFFE8E8EF),
    border:       Color(0xFFDCDCE4),
    borderStrong: Color(0xFFC8C8D4),
    textPrimary:  Color(0xFF0A0A0F),
    textMuted:    Color(0xFF6B6B7A),
    textHint:     Color(0xFF9A9AAA),
    green:        Color(0xFF00C853),
    cyan:         Color(0xFF0099BB),
    purple:       Color(0xFF7C3AED),
    red:          Color(0xFFFF5252),
  );

  @override
  AppColorsExtension copyWith({
    Color? bg, Color? surface1, Color? surface2, Color? surface3,
    Color? border, Color? borderStrong, Color? textPrimary,
    Color? textMuted, Color? textHint, Color? green, Color? cyan,
    Color? purple, Color? red,
  }) => AppColorsExtension(
    bg: bg ?? this.bg, surface1: surface1 ?? this.surface1,
    surface2: surface2 ?? this.surface2, surface3: surface3 ?? this.surface3,
    border: border ?? this.border, borderStrong: borderStrong ?? this.borderStrong,
    textPrimary: textPrimary ?? this.textPrimary, textMuted: textMuted ?? this.textMuted,
    textHint: textHint ?? this.textHint, green: green ?? this.green,
    cyan: cyan ?? this.cyan, purple: purple ?? this.purple, red: red ?? this.red,
  );

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other == null) return this;
    return AppColorsExtension(
      bg: Color.lerp(bg, other.bg, t)!,
      surface1: Color.lerp(surface1, other.surface1, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      green: Color.lerp(green, other.green, t)!,
      cyan: Color.lerp(cyan, other.cyan, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      red: Color.lerp(red, other.red, t)!,
    );
  }
}

/// Shortcut: Theme.of(context).ext<AppColorsExtension>()!
extension ThemeColors on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}

// ─── AppThemes ────────────────────────────────────────────────────────────────

class AppThemes {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF111111),
      primary: Color(0xFF00E676),
      secondary: Color(0xFF7C3AED),
      error: Color(0xFFFF5252),
    ),
    extensions: const [AppColorsExtension.dark],
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0A0A0A),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFFF5F5F5)),
      iconTheme: const IconThemeData(color: Color(0xFFF5F5F5)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF111111),
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFF5F5F5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF7F7FA),
    colorScheme: const ColorScheme.light(
      surface: Color(0xFFFFFFFF),
      primary: Color(0xFF00C853),
      secondary: Color(0xFF7C3AED),
      error: Color(0xFFFF5252),
    ),
    extensions: const [AppColorsExtension.light],
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF7F7FA),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF0A0A0F)),
      iconTheme: const IconThemeData(color: Color(0xFF0A0A0F)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFFFFFFFF),
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0A0A0F)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
