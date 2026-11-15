import 'package:flutter/material.dart';

enum EspacoTema {
  planetas('planetas', 'Planetas', '🪐', Color(0xFF54C08A), '🪐', 'Anel de Saturno'),
  naves('naves', 'Naves', '🚀', Color(0xFF5B9CFF), '🚀', 'Foguete'),
  astros('astros', 'Astros', '⭐', Color(0xFFF5A524), '⭐', 'Estrela'),
  missao('missao', 'Missão', '🛰️', Color(0xFFB98BFF), '👨‍🚀', 'Astronauta');

  const EspacoTema(this.chave, this.rotulo, this.emoji, this.cor, this.premioEmoji, this.premioNome);

  final String chave;
  final String rotulo;
  final String emoji;
  final Color cor;
  final String premioEmoji;
  final String premioNome;

  static EspacoTema? porChave(String chave) {
    for (final t in EspacoTema.values) {
      if (t.chave == chave) return t;
    }
    return null;
  }
}

const double kEspacoTemasFotoAspect = 1672 / 941;
