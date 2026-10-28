import 'package:flutter/material.dart';

/// Tokens de tipografia. A cor NÃO é definida aqui: vem do tema
/// (`apply(bodyColor/displayColor)` em [AppTypography.textTheme]).
abstract final class AppTypography {
  static const String fontFamily = 'Roboto';

  static TextTheme textTheme(ColorScheme scheme) {
    const base = TextTheme(
      displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.8),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
      headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.3),
    );
    return base.apply(
      fontFamily: fontFamily,
      displayColor: scheme.onSurface,
      bodyColor: scheme.onSurface,
    );
  }
}
