import 'dart:math';

import 'package:alfabetizacao/models/categoria.dart';
import 'package:alfabetizacao/models/palavra.dart';
import 'package:alfabetizacao/services/banco_palavras.dart';
import 'package:alfabetizacao/services/caca_palavras.dart';
import 'package:flutter_test/flutter_test.dart';

List<Palavra> _pool(int n) => List<Palavra>.generate(
      n,
      (i) => Palavra(['pa', 'la$i'], Categoria.objetos),
    );

void main() {
  test('montarRodada: 3 alvos + 3 distratores, slots únicos no cenário', () {
    final rodada = montarRodada(_pool(20), rng: Random(7));
    expect(rodada.alvos.length, 3);
    expect(rodada.fichas.length, 6);
    // alvos distintos e todos presentes como ficha-alvo
    expect(rodada.alvos.toSet().length, 3);
    expect(rodada.fichas.where((f) => f.alvo).length, 3);
    // fichas com palavras distintas
    expect(rodada.fichas.map((f) => f.palavra).toSet().length, 6);
    // slots distintos e dentro do cenário
    final slots = rodada.fichas.map((f) => (f.fx, f.fy)).toSet();
    expect(slots.length, 6);
    for (final f in rodada.fichas) {
      expect(f.fx, inInclusiveRange(0.0, 1.0));
      expect(f.fy, inInclusiveRange(0.0, 1.0));
    }
    // separação mínima entre fichas (sem grude)
    for (var i = 0; i < rodada.fichas.length; i++) {
      for (var j = i + 1; j < rodada.fichas.length; j++) {
        final a = rodada.fichas[i];
        final b = rodada.fichas[j];
        expect(
          (a.fx - b.fx).abs() > 0.17 || (a.fy - b.fy).abs() > 0.16,
          isTrue,
          reason: 'fichas $i e $j grudadas',
        );
      }
    }
  });

  test('montarRodada: banco pequeno usa o que houver', () {
    final rodada = montarRodada(_pool(4), rng: Random(1));
    expect(rodada.alvos.length, 3);
    expect(rodada.fichas.length, 4);
  });

  test('montarRodada: separação mínima em várias seeds e bancos reais', () {
    for (var seed = 0; seed < 20; seed++) {
      final rodada = montarRodada(todosOsEspaco(), rng: Random(seed));
      expect(rodada.fichas.length, 6);
      for (var i = 0; i < rodada.fichas.length; i++) {
        for (var j = i + 1; j < rodada.fichas.length; j++) {
          final a = rodada.fichas[i];
          final b = rodada.fichas[j];
          expect(
            (a.fx - b.fx).abs() > 0.17 || (a.fy - b.fy).abs() > 0.16,
            isTrue,
            reason: 'seed $seed, fichas $i e $j grudadas',
          );
        }
      }
    }
  });

  test('montarRodada: determinística com seed', () {
    final a = montarRodada(_pool(20), rng: Random(42));
    final b = montarRodada(_pool(20), rng: Random(42));
    expect(
      a.fichas.map((f) => f.palavra.texto).toList(),
      b.fichas.map((f) => f.palavra.texto).toList(),
    );
  });

  test('montarRodada: funciona com o banco real de cada categoria', () {
    for (final pool in [
      todosOsAnimais(),
      todosOsAlimentos(),
      todosOsObjetos(),
      todosOsNomes(),
      todosOsEspaco(),
      todosOsFutebol(),
    ]) {
      expect(pool.length, greaterThanOrEqualTo(6));
      final rodada = montarRodada(pool, rng: Random(5));
      expect(rodada.alvos.length, 3);
      expect(rodada.fichas.length, 6);
    }
  });
}
