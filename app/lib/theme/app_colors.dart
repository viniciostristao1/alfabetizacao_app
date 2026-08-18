import 'package:flutter/material.dart';

/// Paleta do app (tema ESCURO único por enquanto). Ponto único de verdade das
/// cores — nunca use `Color(0x...)` solto nas telas; puxe daqui.
///
/// Um tema claro/escolha de tema pode entrar depois (ver IDEIAS.md); por isso as
/// telas leem SEMPRE por estes tokens.
abstract final class AppColors {
  static const bg = Color(0xFF0E1116); // fundo geral
  static const surface = Color(0xFF171C24); // cartões
  static const surface2 = Color(0xFF20262F); // cartões elevados / botões
  static const line = Color(0x1AFFFFFF); // bordas sutis
  static const lineStrong = Color(0x33FFFFFF);
  static const text = Color(0xFFF2F5FA);
  static const dim = Color(0xFF8A93A3); // texto secundário
  static const dim2 = Color(0xFF5A616E); // texto/ícone bem fraco

  static const accent = Color(0xFF4F8CFF); // ação principal (azul amigável)
  static const onAccent = Color(0xFF06122B);
  static const danger = Color(0xFFFF6B6B);
}
