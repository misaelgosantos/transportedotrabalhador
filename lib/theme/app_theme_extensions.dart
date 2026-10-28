import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Propriedades do efeito "liquid glass" sutil (header e barra inferior).
/// Centralizadas aqui para ajustar o vidro do app inteiro em um só lugar.
@immutable
class AppGlass extends ThemeExtension<AppGlass> {
  const AppGlass({
    required this.blurSigma,
    required this.tint,
    required this.border,
    required this.highlight,
    required this.shadow,
  });

  /// Intensidade do blur do fundo.
  final double blurSigma;

  /// Cor translúcida do vidro.
  final Color tint;

  /// Borda fina do vidro.
  final Color border;

  /// Brilho superior sutil (reflexo).
  final Color highlight;

  /// Sombra projetada.
  final List<BoxShadow> shadow;

  static const light = AppGlass(
    blurSigma: 16,
    tint: Color(0xB8FFFFFF),
    border: Color(0x1F000000),
    highlight: Color(0x99FFFFFF),
    shadow: [
      BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6)),
    ],
  );

  static const dark = AppGlass(
    blurSigma: 18,
    tint: Color(0xE60D0D0F),
    border: Color(0x26FFFFFF),
    highlight: Color(0x1FFFFFFF),
    shadow: [
      BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 8)),
    ],
  );

  @override
  AppGlass copyWith({
    double? blurSigma,
    Color? tint,
    Color? border,
    Color? highlight,
    List<BoxShadow>? shadow,
  }) =>
      AppGlass(
        blurSigma: blurSigma ?? this.blurSigma,
        tint: tint ?? this.tint,
        border: border ?? this.border,
        highlight: highlight ?? this.highlight,
        shadow: shadow ?? this.shadow,
      );

  @override
  AppGlass lerp(ThemeExtension<AppGlass>? other, double t) {
    if (other is! AppGlass) return this;
    return AppGlass(
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t),
      tint: Color.lerp(tint, other.tint, t)!,
      border: Color.lerp(border, other.border, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      shadow: BoxShadow.lerpList(shadow, other.shadow, t)!,
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Cores semânticas que o [ColorScheme] do Material não cobre.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.info,
  });

  final Color success;
  final Color warning;
  final Color info;

  static const light = AppSemanticColors(
    success: AppPalette.successLight,
    warning: AppPalette.warningLight,
    info: AppPalette.brand,
  );

  static const dark = AppSemanticColors(
    success: AppPalette.successDark,
    warning: AppPalette.warningDark,
    info: AppPalette.brandDark,
  );

  @override
  AppSemanticColors copyWith({Color? success, Color? warning, Color? info}) =>
      AppSemanticColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        info: info ?? this.info,
      );

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

/// Atalhos de acesso ao tema: `context.colors`, `context.text`, etc.
extension AppThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  AppGlass get glass => Theme.of(this).extension<AppGlass>()!;
  AppSemanticColors get semantic =>
      Theme.of(this).extension<AppSemanticColors>()!;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
