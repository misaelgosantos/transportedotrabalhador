import 'package:flutter/material.dart';

/// Design Tokens do app: valores primitivos, sem dependência de tema.
///
/// Cores que variam entre claro/escuro NÃO ficam aqui: vivem em
/// [AppPalette] e chegam aos widgets via `Theme.of(context).colorScheme`
/// (ou `context.colors`). Aqui ficam só escalas que valem para os dois modos.

/// Escala de espaçamento (grade de 4pt).
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Respiro inferior para o conteúdo não ficar atrás da barra de navegação.
  static const double bottomBarClearance = 128;
}

/// Escala de raios de borda.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlAll = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

/// Tamanhos de ícone.
abstract final class AppIconSize {
  static const double sm = 18;
  static const double md = 24;
  static const double lg = 28;
  static const double xl = 40;
}

/// Durações de animação.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Curve curve = Curves.easeOutCubic;
}

/// Tamanhos de componentes de layout compartilhados.
abstract final class AppSizes {
  static const double navBarHeight = 64;
  static const double navBarVerticalPadding = 12;
  static const double headerIconBox = 48;
}
