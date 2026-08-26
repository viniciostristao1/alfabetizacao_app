import 'package:flutter/material.dart';

enum AlimentosTema {
  hortifruti('hortifruti', 'Hortifruti', '🍎', Color(0xFF54C08A), '🍕', 'Pizza'),
  padaria('padaria', 'Padaria', '🍞', Color(0xFF5B9CFF), '🍣', 'Sushi'),
  laticinios('laticinios', 'Laticínios', '🥛', Color(0xFFF5A524), '🍔', 'Hambúrguer'),
  acougue('acougue', 'Açougue', '🥩', Color(0xFFFF8A5B), '🍝', 'Macarrão'),
  mercado('mercado', 'Mercado', '🏪', Color(0xFFF5A524), '🍕', 'Pizza'),
  pomar('pomar', 'Pomar', '🍎', Color(0xFF54C08A), '🍣', 'Sushi'),
  horta('horta', 'Horta', '🥬', Color(0xFF5B9CFF), '🍔', 'Hambúrguer'),
  roca('roca', 'Roça', '🌾', Color(0xFFFF8A5B), '🍝', 'Macarrão'),
  arrozal('arrozal', 'Arrozal', '🍚', Color(0xFF2DD4BF), '🍦', 'Iogurte');

  const AlimentosTema(this.chave, this.rotulo, this.emoji, this.cor, this.premioEmoji, this.premioNome);

  final String chave;
  final String rotulo;
  final String emoji;
  final Color cor;
  final String premioEmoji;
  final String premioNome;

  static AlimentosTema? porChave(String chave) {
    for (final t in AlimentosTema.values) {
      if (t.chave == chave) return t;
    }
    return null;
  }
}

const double kAlimentosTemasFotoAspect = 1536 / 1024;
