import 'dart:math';

import 'package:alfabetizacao/models/categoria.dart';
import 'package:alfabetizacao/models/palavra.dart';
import 'package:alfabetizacao/services/completar_silaba.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('montarDesafio (completar a sílaba)', () {
    test('nunca falta a 1ª sílaba; 4 opções únicas incluindo a certa', () {
      const p = Palavra(['gi', 'ra', 'fa'], Categoria.animais);
      for (var seed = 0; seed < 30; seed++) {
        final d = montarDesafio(p, rng: Random(seed))!;
        expect(d.blankIndex, greaterThanOrEqualTo(1), reason: 'nunca a 1ª');
        expect(d.blankIndex, lessThan(p.silabas.length));
        expect(d.correta, p.silabas[d.blankIndex].toUpperCase());
        expect(d.opcoes.length, 4);
        expect(d.opcoes.toSet().length, 4, reason: 'sem opção repetida');
        expect(d.opcoes.contains(d.correta), isTrue);
        // todas em MAIÚSCULAS
        for (final o in d.opcoes) {
          expect(o, o.toUpperCase());
        }
      }
    });

    test('palavra de 2 sílabas: só a 2ª pode faltar', () {
      const p = Palavra(['pin', 'guim'], Categoria.animais);
      final d = montarDesafio(p, rng: Random(1))!;
      expect(d.blankIndex, 1);
      expect(d.correta, 'GUIM');
    });

    test('palavra de 1 "sílaba" (escrever) → sem desafio (null)', () {
      const p = Palavra(['casa'], Categoria.escrever);
      expect(montarDesafio(p), isNull);
    });
  });
}
