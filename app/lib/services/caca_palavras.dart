import 'dart:math';

import '../models/palavra.dart';

/// Uma ficha espalhada no cenário: a palavra + se ela é um dos alvos +
/// a posição relativa (0..1) sobre a imagem (mesma ideia dos marcadores
/// do mapa-múndi: funciona em qualquer tamanho de tela).
class FichaCaca {
  const FichaCaca({
    required this.palavra,
    required this.alvo,
    required this.fx,
    required this.fy,
  });

  final Palavra palavra;
  final bool alvo;
  final double fx;
  final double fy;
}

/// Uma rodada: os alvos (para achar, na ordem) + todas as fichas no cenário.
class RodadaCaca {
  const RodadaCaca({required this.alvos, required this.fichas});

  final List<Palavra> alvos;
  final List<FichaCaca> fichas;
}

/// Posições relativas das fichas sobre o cenário (fx = coluna 0..1 da esquerda
/// para a direita; fy = linha 0..1 de cima para baixo). Longe do topo (título)
/// e da base (botões): espalhadas no miolo da imagem.
const List<(double, double)> kSlotsCaca = [
  (0.11, 0.32),
  (0.36, 0.24),
  (0.62, 0.30),
  (0.87, 0.26),
  (0.84, 0.60),
  (0.61, 0.67),
  (0.38, 0.60),
  (0.14, 0.66),
  (0.50, 0.45),
  (0.24, 0.44),
];

/// Monta uma rodada: sorteia [nAlvos] palavras distintas do banco como alvos
/// e completa com distratores (outras palavras do banco) até [nFichas].
/// Cada ficha cai num slot distinto, embaralhado e com separação mínima
/// (evita fichas grudadas mesmo com palavras longas). Se o banco for
/// pequeno, usa o que houver (mínimo: 1 alvo + 1 distrator).
RodadaCaca montarRodada(
  List<Palavra> pool, {
  Random? rng,
  int nAlvos = 3,
  int nFichas = 6,
}) {
  final r = rng ?? Random();
  final embaralhado = pool.toList()..shuffle(r);
  final alvos = embaralhado.take(nAlvos.clamp(1, pool.length)).toList();
  final resto = embaralhado.skip(alvos.length).toList();
  final nDistratores =
      (nFichas - alvos.length).clamp(0, resto.length);
  final distratores = resto.take(nDistratores).toList();
  final fichas = [
    for (final p in alvos) (p, true),
    for (final p in distratores) (p, false),
  ]..shuffle(r);
  final candidatos = kSlotsCaca.toList()..shuffle(r);
  final escolhidos = <(double, double)>[];
  for (final s in candidatos) {
    if (escolhidos.length >= fichas.length) break;
    final longe = escolhidos.every((e) =>
        (e.$1 - s.$1).abs() > 0.17 || (e.$2 - s.$2).abs() > 0.16);
    if (longe) escolhidos.add(s);
  }
  // Banco/lista apertada: completa com os restantes (sem a separação).
  for (final s in candidatos) {
    if (escolhidos.length >= fichas.length) break;
    if (!escolhidos.contains(s)) escolhidos.add(s);
  }
  return RodadaCaca(
    alvos: alvos,
    fichas: [
      for (var i = 0; i < fichas.length; i++)
        FichaCaca(
          palavra: fichas[i].$1,
          alvo: fichas[i].$2,
          fx: escolhidos[i].$1,
          fy: escolhidos[i].$2,
        ),
    ],
  );
}
