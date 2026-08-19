import 'dart:math';

import 'package:alfabetizacao/models/conta.dart';
import 'package:alfabetizacao/services/gerador_contas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('gerarContas', () {
    test('soma 1 dígito: operandos 0-9, resultado certo, +1 ponto', () {
      final contas = gerarContas(
          operacao: OperacaoConta.soma,
          digitos: 1,
          quantidade: 40,
          rng: Random(1));
      expect(contas.length, 40);
      for (final c in contas) {
        expect(c.soma, isTrue);
        expect(c.a >= 0 && c.a <= 9, isTrue);
        expect(c.b >= 0 && c.b <= 9, isTrue);
        expect(c.resultado, c.a + c.b);
        expect(c.pontos, 1);
      }
    });

    test('soma 2 dígitos: resultado ≤ 99 e +2 pontos', () {
      final contas = gerarContas(
          operacao: OperacaoConta.soma,
          digitos: 2,
          quantidade: 40,
          rng: Random(2));
      for (final c in contas) {
        expect(c.a >= 10 && c.a <= 99, isTrue);
        expect(c.b >= 10 && c.b <= 99, isTrue);
        expect(c.resultado <= 99, isTrue, reason: 'fica de 2 dígitos');
        expect(c.pontos, 2);
      }
    });

    test('subtração nunca dá negativo (a ≥ b)', () {
      final contas = gerarContas(
          operacao: OperacaoConta.subtracao,
          digitos: 2,
          quantidade: 60,
          rng: Random(3));
      for (final c in contas) {
        expect(c.soma, isFalse);
        expect(c.a >= c.b, isTrue);
        expect(c.resultado >= 0, isTrue);
      }
    });

    test('mistas: tem soma e subtração', () {
      final contas = gerarContas(
          operacao: OperacaoConta.mistas,
          digitos: 1,
          quantidade: 60,
          rng: Random(4));
      expect(contas.any((c) => c.soma), isTrue);
      expect(contas.any((c) => !c.soma), isTrue);
    });
  });

  group('parseConta', () {
    test('soma válida com 2 dígitos → +2', () {
      final c = parseConta('12 + 7')!;
      expect(c.a, 12);
      expect(c.b, 7);
      expect(c.soma, isTrue);
      expect(c.resultado, 19);
      expect(c.pontos, 2);
    });

    test('subtração válida', () {
      final c = parseConta('20-8')!;
      expect(c.soma, isFalse);
      expect(c.resultado, 12);
    });

    test('1 dígito → +1', () {
      expect(parseConta('3+4')!.pontos, 1);
    });

    test('inválidas retornam null', () {
      expect(parseConta('7 - 12'), isNull); // negativo
      expect(parseConta('abc'), isNull);
      expect(parseConta('3 + 4 + 5'), isNull);
      expect(parseConta('5'), isNull); // sem sinal
    });
  });
}
