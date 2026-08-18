import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema do app (ponto único de verdade visual). Escuro, com cantos arredondados
/// e tipografia forte — pensado para ser legível por uma criança.
ThemeData buildAppTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
  final scheme = const ColorScheme.dark().copyWith(
    primary: AppColors.accent,
    onPrimary: AppColors.onAccent,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    error: AppColors.danger,
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: scheme,
    iconTheme: const IconThemeData(color: AppColors.text),
    textTheme: base.textTheme
        .apply(bodyColor: AppColors.text, displayColor: AppColors.text),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    dividerColor: AppColors.line,
  );
}
