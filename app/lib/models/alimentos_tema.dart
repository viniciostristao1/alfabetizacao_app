import 'package:flutter/material.dart';

enum AlimentosTema {
  mercado('mercado', 'Mercado', '🏪', Color(0xFFF5A524)),
  pomar('pomar', 'Pomar', '🍎', Color(0xFF54C08A)),
  horta('horta', 'Horta', '🥬', Color(0xFF5B9CFF)),
  roca('roca', 'Roça', '🌾', Color(0xFFFF8A5B)),
  arrozal('arrozal', 'Arrozal', '🍚', Color(0xFF2DD4BF));

  const AlimentosTema(this.chave, this.rotulo, this.emoji, this.cor);

  final String chave;
  final String rotulo;
  final String emoji;
  final Color cor;

  static AlimentosTema? porChave(String chave) {
    for (final t in AlimentosTema.values) {
      if (t.chave == chave) return t;
    }
    return null;
  }
}

const double kAlimentosTemasFotoAspect = 1376 / 768;
