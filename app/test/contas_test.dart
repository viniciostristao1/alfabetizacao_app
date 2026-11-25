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
      // Mistas NUNCA inclui multiplicação (regra do usuário).
      expect(contas.any((c) => c.vezes), isFalse);
    });

    test('mistas não aceita multiplicacao via gerarContas', () {
      expect(
          () => gerarContas(
              operacao: OperacaoConta.multiplicacao, digitos: 1),
          throwsArgumentError);
    });

    test('até 20: soma com os dois números ≤ 20', () {
      final contas = gerarContasAte(20, quantidade: 80, rng: Random(5));
      expect(contas.length, 80);
      for (final c in contas) {
        expect(c.soma, isTrue);
        expect(c.a >= 0 && c.a <= 20, isTrue);
        expect(c.b >= 0 && c.b <= 20, isTrue);
        expect(c.resultado, c.a + c.b);
      }
    });
  });

  group('gerarMultiplicacao', () {
    test('fatores 1-9, produto certo, +1 ponto, sinal ×', () {
      final contas = gerarMultiplicacao(quantidade: 200, rng: Random(7));
      expect(contas.length, 200);
      for (final c in contas) {
        expect(c.vezes, isTrue);
        expect(c.a >= 1 && c.a <= 9, isTrue, reason: 'fator a fora de 1-9: ${c.a}');
        expect(c.b >= 1 && c.b <= 9, isTrue, reason: 'fator b fora de 1-9: ${c.b}');
        expect(c.resultado, c.a * c.b);
        expect(c.resultado >= 1 && c.resultado <= 81, isTrue);
        expect(c.pontos, 1);
        expect(c.sinal, '×');
        expect(c.enunciado, '${c.a} × ${c.b}');
      }
    });

    test('nunca gera fator 0', () {
      for (var seed = 0; seed < 20; seed++) {
        final contas = gerarMultiplicacao(quantidade: 50, rng: Random(seed));
        expect(contas.any((c) => c.a == 0 || c.b == 0), isFalse);
      }
    });

    test('cobre os extremos 1×1 e 9×9 ao longo de muitas sementes', () {
      final todas = <String>{};
      for (var seed = 0; seed < 30; seed++) {
        todas.addAll(
            gerarMultiplicacao(quantidade: 30, rng: Random(seed))
                .map((c) => '${c.a}x${c.b}'));
      }
      // Com 900 sorteios em 81 combinações, é praticamente impossível não
      // ver fatores 1 e 9 algumas vezes.
      expect(todas.any((s) => s.startsWith('1x') || s.endsWith('x1')), isTrue);
      expect(todas.any((s) => s.startsWith('9x') || s.endsWith('x9')), isTrue);
    });

    test('Conta manual: 3 × 4 = 12', () {
      const c = Conta(3, 4, true, 1, true);
      expect(c.vezes, isTrue);
      expect(c.resultado, 12);
      expect(c.sinal, '×');
      expect(c.enunciado, '3 × 4');
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
