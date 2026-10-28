import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_palette.dart';
import 'app_theme_extensions.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Constrói os [ThemeData] claro e escuro a partir dos tokens.
abstract final class AppThemes {
  static final ThemeData light = _build(
    ColorScheme(
      brightness: Brightness.light,
      primary: AppPalette.brand,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFDCEBFF),
      onPrimaryContainer: const Color(0xFF00356E),
      secondary: AppPalette.lightTextMuted,
      onSecondary: Colors.white,
      error: AppPalette.errorLight,
      onError: Colors.white,
      surface: AppPalette.lightSurface,
      onSurface: AppPalette.lightText,
      onSurfaceVariant: AppPalette.lightTextMuted,
      surfaceContainerLowest: AppPalette.lightBackground,
      surfaceContainerLow: AppPalette.lightSurfaceLow,
      surfaceContainer: AppPalette.lightSurface,
      surfaceContainerHigh: AppPalette.lightSurfaceHigh,
      surfaceContainerHighest: AppPalette.lightSurfaceHighest,
      outline: AppPalette.lightOutline,
      outlineVariant: AppPalette.lightOutlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
    ),
    glass: AppGlass.light,
    semantic: AppSemanticColors.light,
  );

  static final ThemeData dark = _build(
    ColorScheme(
      brightness: Brightness.dark,
      primary: AppPalette.brandDark,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF0B3A73),
      onPrimaryContainer: const Color(0xFFD6E8FF),
      secondary: AppPalette.darkTextMuted,
      onSecondary: Colors.black,
      error: AppPalette.errorDark,
      onError: Colors.black,
      surface: AppPalette.darkSurface,
      onSurface: AppPalette.darkText,
      onSurfaceVariant: AppPalette.darkTextMuted,
      surfaceContainerLowest: AppPalette.darkBackground,
      surfaceContainerLow: AppPalette.darkSurfaceLow,
      surfaceContainer: AppPalette.darkSurface,
      surfaceContainerHigh: AppPalette.darkSurfaceHigh,
      surfaceContainerHighest: AppPalette.darkSurfaceHighest,
      outline: AppPalette.darkOutline,
      outlineVariant: AppPalette.darkOutlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
    ),
    glass: AppGlass.dark,
    semantic: AppSemanticColors.dark,
  );

  static ThemeData _build(
    ColorScheme scheme, {
    required AppGlass glass,
    required AppSemanticColors semantic,
  }) {
    final isDark = scheme.brightness == Brightness.dark;
    final text = AppTypography.textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      // Fundo da página: o mais neutro da escala.
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      canvasColor: scheme.surface,
      dividerColor: scheme.outlineVariant,
      fontFamily: AppTypography.fontFamily,
      textTheme: text,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkSparkle.splashFactory,
      extensions: [glass, semantic],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: text.titleLarge,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlAll,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxlAll),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        hintStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.pillAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.pillAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.pillAll,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          textStyle: text.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          shape: const StadiumBorder(),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: text.labelLarge,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.onSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.surface),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}
