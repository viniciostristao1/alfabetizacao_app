import 'dart:math';

import 'package:alfabetizacao/models/categoria.dart';
import 'package:alfabetizacao/models/palavra.dart';
import 'package:alfabetizacao/services/banco_palavras.dart';
import 'package:alfabetizacao/services/ditado.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('embaralharSilabas: mesmo multiconjunto, MAIÚSCULAS', () {
    const p = Palavra(['ca', 'va', 'lo'], Categoria.animais);
    final fichas = embaralharSilabas(p, rng: Random(7));
    expect(fichas.length, 3);
    expect([...fichas]..sort(), ['CA', 'LO', 'VA']);
  });

  test('embaralharSilabas: 1 sílaba vira 1 ficha', () {
    const p = Palavra(['gol'], Categoria.futebol);
    expect(embaralharSilabas(p, rng: Random(1)), ['GOL']);
  });

  test('embaralharSilabas: palavras do banco têm ≥1 sílaba montável', () {
    for (final p in bancoPalavras) {
      final fichas = embaralharSilabas(p, rng: Random(3));
      expect(fichas.length, p.silabas.length, reason: p.texto);
      expect([...fichas]..sort(),
          [for (final s in p.silabas) s.toUpperCase()]..sort(),
          reason: p.texto);
    }
  });

  test('embaralharSilabas: determinístico com seed', () {
    const p = Palavra(['sa', 'pa', 'to'], Categoria.objetos);
    expect(
      embaralharSilabas(p, rng: Random(42)),
      embaralharSilabas(p, rng: Random(42)),
    );
  });
}
