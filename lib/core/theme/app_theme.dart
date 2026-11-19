import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shuchona/core/localization/app_locale.dart';
import 'package:shuchona/core/theme/app_colors.dart';

/// Builds light and high-contrast Material 3 themes for SHUCHONA with dynamic
/// Noto Sans Bengali (for Bangla) and Plus Jakarta Sans (for English) typography.
abstract final class AppTheme {
  static TextTheme _buildTextTheme(
    TextTheme base,
    AppLocale locale,
    Color primaryText,
    Color secondaryText,
  ) {
    final themed = locale == AppLocale.bn
        ? GoogleFonts.notoSansBengaliTextTheme(base)
        : GoogleFonts.plusJakartaSansTextTheme(base);

    return themed.copyWith(
      displaySmall: themed.displaySmall?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w800,
        height: 1.25,
      ),
      headlineMedium: themed.headlineMedium?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w800,
        fontSize: 24,
        height: 1.3,
      ),
      headlineSmall: themed.headlineSmall?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        height: 1.35,
      ),
      titleLarge: themed.titleLarge?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 18,
        height: 1.35,
      ),
      titleMedium: themed.titleMedium?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 16,
        height: 1.35,
      ),
      titleSmall: themed.titleSmall?.copyWith(
        color: secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      bodyLarge: themed.bodyLarge?.copyWith(
        color: primaryText,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: themed.bodyMedium?.copyWith(
        color: secondaryText,
        fontSize: 15,
        height: 1.5,
      ),
      bodySmall: themed.bodySmall?.copyWith(
        color: secondaryText,
        fontSize: 13,
        height: 1.4,
      ),
      labelLarge: themed.labelLarge?.copyWith(
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }

  static ThemeData light(AppLocale locale) {
    final colorScheme = ColorScheme.light(
      primary: AppColors.primaryTeal,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryTealLight,
      onPrimaryContainer: AppColors.primaryTealDark,
      secondary: AppColors.secondaryEmeraldDark,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryEmeraldLight,
      onSecondaryContainer: AppColors.secondaryEmeraldDark,
      error: AppColors.alertCrimson,
      onError: Colors.white,
      errorContainer: AppColors.alertCrimsonLight,
      onErrorContainer: AppColors.alertCrimsonDark,
      surface: AppColors.lightCard,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightCanvas,
      onSurfaceVariant: AppColors.lightTextSecondary,
      outline: AppColors.lightBorder,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightCanvas,
    );

    final textTheme = _buildTextTheme(
      base.textTheme,
      locale,
      AppColors.lightTextPrimary,
      AppColors.lightTextSecondary,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightCard,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0.5,
        shadowColor: const Color(0x140F172A),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size(56, 56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size(56, 56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryTeal,
          minimumSize: const Size(56, 56),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: const BorderSide(color: AppColors.primaryTeal, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.lightTextMuted,
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.lightBorder,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppColors.lightBorder),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
      ),
    );
  }

  /// High-Contrast Dark Mode: Pitch-Slate #090D16, White text, Electric Blue #38BDF8 accents.
  static ThemeData highContrastDark(AppLocale locale) {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.darkAccentBlue,
      onPrimary: AppColors.darkCanvas,
      primaryContainer: AppColors.darkTealBg,
      onPrimaryContainer: AppColors.darkAccentBlue,
      secondary: AppColors.secondaryEmerald,
      onSecondary: AppColors.darkCanvas,
      secondaryContainer: AppColors.darkEmeraldBg,
      onSecondaryContainer: const Color(0xFF6EE7B7),
      error: const Color(0xFFF87171),
      onError: AppColors.darkCanvas,
      errorContainer: AppColors.darkAlertBg,
      onErrorContainer: const Color(0xFFFECACA),
      surface: AppColors.darkCard,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkCardElevated,
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.darkBorder,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkCanvas,
    );

    final textTheme = _buildTextTheme(
      base.textTheme,
      locale,
      AppColors.darkTextPrimary,
      AppColors.darkTextSecondary,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkCard,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.darkTextMuted, width: 1.5),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkAccentBlue,
          foregroundColor: AppColors.darkCanvas,
          minimumSize: const Size(56, 56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkAccentBlue,
          foregroundColor: AppColors.darkCanvas,
          minimumSize: const Size(56, 56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkAccentBlue,
          minimumSize: const Size(56, 56),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: const BorderSide(color: AppColors.darkAccentBlue, width: 1.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCardElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.darkAccentBlue,
            width: 2,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppColors.darkBorder),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1.2,
      ),
    );
  }
}
