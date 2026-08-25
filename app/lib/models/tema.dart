import 'package:flutter/material.dart';

/// Temas da CIDADE — os lugares que aparecem na foto dos Temas
/// (`assets/objetos/objetos_temas_foto.png`, 1672×941). As 5 palavras da foto
/// ficam centralizadas, uma ao lado da outra, da esquerda para a direita, em 5
/// faixas verticais iguais (quase métricas) — cada faixa abre o estudo das
/// palavras daquele tema (ver [palavrasDoTema]).
enum Tema {
  casa('casa', 'Casa', '🏠', Color(0xFF5B9CFF), '🧸', 'Brinquedo'),
  museu('museu', 'Museu', '🏛️', Color(0xFFB98BFF), '🎮', 'Videogame'),
  escola('escola', 'Escola', '🏫', Color(0xFFFF8A5B), '🎒', 'Mochila'),
  cafeteria('cafeteria', 'Cafeteria', '☕', Color(0xFFF5A524), '⚽', 'Bola'),
  bombeiros('bombeiros', 'Bombeiros', '🚒', Color(0xFFFF6B6B), '🚲', 'Bicicleta');

  const Tema(this.chave, this.rotulo, this.emoji, this.cor, this.premioEmoji, this.premioNome);

  final String chave;
  final String rotulo;
  final String emoji;
  final Color cor;
  final String premioEmoji;
  final String premioNome;

  /// Tema pela chave ('casa', 'museu', …) ou null se não existir.
  static Tema? porChave(String chave) {
    for (final t in Tema.values) {
      if (t.chave == chave) return t;
    }
    return null;
  }
}

/// Aspecto nativo da foto dos Temas (1672×941) — usada para exibir a imagem
/// inteira e manter as faixas clicáveis alinhadas com as palavras dela.
const double kTemasFotoAspect = 1672 / 941;
