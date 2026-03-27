import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg          = Color(0xFF0A0A0A);
  static const bg2         = Color(0xFF111111);
  static const bg3         = Color(0xFF111111);
  static const bg4         = Color(0xFF151515);
  static const border      = Color(0xFF1E1E1E);
  static const border2     = Color(0xFF272727);
  static const textPrimary = Color(0xFFF5F5F5);
  static const textMuted   = Color(0xFFAAAAAA);
  static const textHint    = Color(0xFF787878);
  static const green       = Color(0xFF00E676);
  static const greenDark   = Color(0xFF00BFA5);
  static const cyan        = Color(0xFF00E5FF);
  static const purple      = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFB39DFF);
  static const blue        = Color(0xFF3B82F6);
  static const red         = Color(0xFFFF5252);
}

class AppShadows {
  static const glowGreen = BoxShadow(color: Color(0x00000000), blurRadius: 0, spreadRadius: 0);
  static const glowCyan = BoxShadow(color: Color(0x00000000), blurRadius: 0, spreadRadius: 0);
  static const glowPurple = BoxShadow(color: Color(0x00000000), blurRadius: 0, spreadRadius: 0);
  static const card = BoxShadow(color: Color(0x00000000), blurRadius: 0, offset: Offset(0, 0));
  static const activeCard = BoxShadow(color: Color(0x00000000), blurRadius: 0, spreadRadius: 0);
  static const elevated = BoxShadow(color: Color(0x00000000), blurRadius: 0, offset: Offset(0, 0));
}

class AppDecorations {
  static BoxDecoration glassCard = BoxDecoration(
    color: AppColors.bg2,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.border, width: 1),
  );

  static BoxDecoration elevatedCard({Color? accentColor}) => BoxDecoration(
    color: AppColors.bg2,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: accentColor ?? AppColors.border),
  );

  static InputDecoration inputDecor({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textHint,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(icon, color: AppColors.textHint, size: 18),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.bg2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.green, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
        errorStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.red),
      );
}

class AppText {
  static TextStyle displayXl = GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.2,
  );
  static TextStyle displayLg = GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.2,
  );
  static TextStyle displayMd = GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.2,
  );
  static TextStyle displaySm = GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.2,
  );
  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.4,
  );
  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textMuted, height: 1.5,
  );
  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.textHint, height: 1.4,
  );
  static TextStyle bodyXs = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.textHint, height: 1.4,
  );
  static TextStyle labelGreen = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.green,
  );
  static TextStyle labelMuted = GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.textMuted, letterSpacing: 0.5,
  );
}

// ─── API ──────────────────────────────────────────────────────────────────────
const String baseUrl = "http://172.20.139.163:5000/api";
const String socketUrl = "http://172.20.139.163:5000";

const List<String> kSkillCategories = [
  'Technology', 'Creative', 'Language', 'Business',
];

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    primaryColor: AppColors.green,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.green,
      secondary: AppColors.purple,
      surface: AppColors.bg2,
      error: AppColors.red,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.displaySm,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.bg3,
      contentTextStyle: AppText.bodyMd,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}