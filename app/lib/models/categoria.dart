import 'package:flutter/material.dart';

/// As 4 modalidades de palavras da tela principal.
///
/// `emoji`/`cor` são só apoio VISUAL de navegação (a criança ainda não lê, então
/// reconhece a categoria pelo ícone/cor). A palavra em si é mostrada só em texto,
/// sem figura — ver [Palavra] e a EstudoScreen.
enum Categoria {
  animais('Animais', '🐶', Color(0xFF54C08A)),
  objetos('Objetos', '🧸', Color(0xFF5B9CFF)),
  alimentos('Alimentos', '🍎', Color(0xFFFF8A5B)),
  nomes('Nomes', '🔤', Color(0xFFB98BFF));

  const Categoria(this.rotulo, this.emoji, this.cor);

  final String rotulo;
  final String emoji;
  final Color cor;
}

/// Nível = quantidade de sílabas da palavra (o "difícil/fácil" pediido).
/// `silabas` é o número exato usado para filtrar o banco de palavras.
enum Nivel {
  facil('Fácil', '2 sílabas', 2, Color(0xFF54C08A)),
  media('Média', '3 sílabas', 3, Color(0xFFF5A524)),
  dificil('Difícil', '4 sílabas', 4, Color(0xFFFF6B6B));

  const Nivel(this.rotulo, this.descricao, this.silabas, this.cor);

  final String rotulo;
  final String descricao;
  final int silabas;
  final Color cor;
}
