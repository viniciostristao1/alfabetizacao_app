import 'dart:math';

import '../models/palavra.dart';

/// Ditado: o app FALA a palavra e a criança a monta tocando as sílabas na
/// ordem certa. As fichas vêm embaralhadas (MAIÚSCULAS); a ordem correta é a
/// de [Palavra.silabas]. Palavras de 1 sílaba viram 1 ficha só (tocar = acertar).
List<String> embaralharSilabas(Palavra p, {Random? rng}) {
  final fichas = [for (final s in p.silabas) s.toUpperCase()];
  fichas.shuffle(rng ?? Random());
  return fichas;
}
