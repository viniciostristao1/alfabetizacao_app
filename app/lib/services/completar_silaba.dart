import 'dart:math';

import '../models/palavra.dart';
import 'banco_palavras.dart';

/// Um desafio "completar a sílaba que falta": a palavra fica com UMA sílaba
/// escondida (**nunca a 1ª**) e a criança escolhe a certa entre 4 opções.
class DesafioSilaba {
  const DesafioSilaba({
    required this.blankIndex,
    required this.opcoes,
    required this.correta,
  });

  /// Índice da sílaba que falta (≥ 1 — nunca a primeira).
  final int blankIndex;

  /// 4 opções embaralhadas (a certa + 3 distratores), em MAIÚSCULAS.
  final List<String> opcoes;

  /// A sílaba correta (MAIÚSCULA).
  final String correta;
}

/// Monta o desafio para [p]: sorteia uma sílaba NÃO-primeira pra faltar e 4
/// opções (a certa + 3 distratores tirados do banco). Retorna null se a palavra
/// tem menos de 2 sílabas (não dá pra faltar uma sílaba não-primeira).
DesafioSilaba? montarDesafio(Palavra p, {Random? rng, List<String>? pool}) {
  final n = p.silabas.length;
  if (n < 2) return null;
  final r = rng ?? Random();
  final blank = 1 + r.nextInt(n - 1); // 1..n-1 (nunca 0 = a 1ª sílaba)
  final correta = p.silabas[blank].toUpperCase();
  final daPalavra = {for (final s in p.silabas) s.toUpperCase()};
  final candidatos = (pool ?? poolSilabasMaiusculas())
      .where((s) => s != correta && !daPalavra.contains(s))
      .toList()
    ..shuffle(r);
  final opcoes = [correta, ...candidatos.take(3)]..shuffle(r);
  return DesafioSilaba(blankIndex: blank, opcoes: opcoes, correta: correta);
}
