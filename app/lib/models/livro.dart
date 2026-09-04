import 'package:flutter/material.dart';

enum FonteHistorinha {
  maiuscula('MAIÚSCULA'),
  normal('Aa - Maiúscula e minúscula');

  const FonteHistorinha(this.rotulo);
  final String rotulo;

  String aplicar(String texto) => switch (this) {
        FonteHistorinha.maiuscula => texto.toUpperCase(),
        FonteHistorinha.normal => texto,
      };
}

class Livro {
  const Livro({
    required this.chave,
    required this.titulo,
    required this.emoji,
    required this.cor,
    required this.paginas,
  });

  final String chave;
  final String titulo;
  final String emoji;
  final Color cor;
  final List<String> paginas;

  int get totalPaginas => paginas.length;
}
