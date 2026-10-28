import 'package:flutter/material.dart';

/// Única fonte de cores brutas do app. Só `lib/theme/` deve importar isto;
/// o restante do projeto lê cores via `Theme.of(context)` / `context.colors`.
abstract final class AppPalette {
  // Marca (azul moderno do app, elegante e com alto contraste).
  static const Color brand = Color(0xFF0284C7);
  static const Color brandDark = Color(0xFF0284C7); // Azul do sistema unificado

  // Claro: neutros limpos.
  static const Color lightBackground = Color(0xFFF7F7F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceLow = Color(0xFFFAFAFB);
  static const Color lightSurfaceHigh = Color(0xFFF0F1F3);
  static const Color lightSurfaceHighest = Color(0xFFE8EAED);
  static const Color lightText = Color(0xFF111114);
  static const Color lightTextMuted = Color(0xFF6B6F76);
  static const Color lightOutline = Color(0xFFD5D8DD);
  static const Color lightOutlineVariant = Color(0xFFE8EAED);

  // Escuro: quase preto, superfícies elevadas sutis.
  static const Color darkBackground = Color(0xFF0B0B0D);
  static const Color darkSurface = Color(0xFF151518);
  static const Color darkSurfaceLow = Color(0xFF111114);
  static const Color darkSurfaceHigh = Color(0xFF1F1F23);
  static const Color darkSurfaceHighest = Color(0xFF2A2A2F);
  static const Color darkText = Color(0xFFF4F4F6);
  static const Color darkTextMuted = Color(0xFF9A9CA3);
  static const Color darkOutline = Color(0xFF3A3A40);
  static const Color darkOutlineVariant = Color(0xFF26262B);

  // Semânticas (ajustadas por modo em [AppSemanticColors]).
  static const Color successLight = Color(0xFF1E9E5A);
  static const Color successDark = Color(0xFF4CD08A);
  static const Color warningLight = Color(0xFFE08A00);
  static const Color warningDark = Color(0xFFFFB84D);
  static const Color errorLight = Color(0xFFD93025);
  static const Color errorDark = Color(0xFFFF6B60);
}
