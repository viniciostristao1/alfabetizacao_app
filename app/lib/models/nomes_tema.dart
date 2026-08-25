import 'package:flutter/material.dart';

enum NomesTema {
  curtos('curtos', 'Curtos', '👶', Color(0xFF54C08A), '🧸', 'Brinquedo'),
  medios('medios', 'Médios', '🧒', Color(0xFF5B9CFF), '🎮', 'Videogame'),
  longos('longos', 'Longos', '🧑', Color(0xFFF5A524), '🎒', 'Mochila'),
  compostos('compostos', 'Compostos', '👨‍👩‍👧', Color(0xFFB98BFF), '🚲', 'Bicicleta');

  const NomesTema(this.chave, this.rotulo, this.emoji, this.cor, this.premioEmoji, this.premioNome);

  final String chave;
  final String rotulo;
  final String emoji;
  final Color cor;
  final String premioEmoji;
  final String premioNome;

  static NomesTema? porChave(String chave) {
    for (final t in NomesTema.values) {
      if (t.chave == chave) return t;
    }
    return null;
  }
}

const double kNomesTemasFotoAspect = 1536 / 1024;
