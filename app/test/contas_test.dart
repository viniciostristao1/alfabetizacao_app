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

  group('gerarMultiplicacaoFacil (2 à 7 • fácil)', () {
    test('36 operações ordenadas, fatores 2-7, produto 4-49, +1 ponto', () {
      final contas = gerarMultiplicacaoFacil(rng: Random(7));
      expect(contas.length, 36);
      final pares = <String>{};
      for (final c in contas) {
        expect(c.vezes, isTrue);
        expect(c.a >= 2 && c.a <= 7, isTrue, reason: 'fator a: ${c.a}');
        expect(c.b >= 2 && c.b <= 7, isTrue, reason: 'fator b: ${c.b}');
        expect(c.resultado, c.a * c.b);
        expect(c.resultado >= 4 && c.resultado <= 49, isTrue);
        expect(c.pontos, 1);
        expect(c.sinal, '×');
        expect(c.enunciado, '${c.a} × ${c.b}');
        pares.add('${c.a}x${c.b}');
      }
      // Conjunto fechado: 6×6 = 36, sem repetir antes de esgotar.
      expect(pares.length, 36);
      expect(pares, containsAll(['6x7', '7x6', '2x2', '7x7']));
    });

    test('fatia respeita a ordem embaralhada, sem repetir', () {
      final contas = gerarMultiplicacaoFacil(quantidade: 10, rng: Random(3));
      expect(contas.length, 10);
      final pares = contas.map((c) => '${c.a}x${c.b}').toSet();
      expect(pares.length, 10);
      final cheias = gerarMultiplicacaoFacil(rng: Random(3));
      expect(
          contas.map((c) => '${c.a}x${c.b}').toList(),
          cheias.take(10).map((c) => '${c.a}x${c.b}').toList());
    });

    test('mesma semente, mesma ordem (determinístico)', () {
      final a = gerarMultiplicacaoFacil(rng: Random(11)).map((c) => '${c.a}x${c.b}');
      final b = gerarMultiplicacaoFacil(rng: Random(11)).map((c) => '${c.a}x${c.b}');
      expect(a.toList(), b.toList());
    });
  });

  group('gerarMultiplicacaoMedio (8 a 15 • Médio)', () {
    test('64 operações ordenadas, fatores 8-15, produto 64-225, +2 pontos', () {
      final contas = gerarMultiplicacaoMedio(rng: Random(7));
      expect(contas.length, 64);
      final pares = <String>{};
      for (final c in contas) {
        expect(c.vezes, isTrue);
        expect(c.a >= 8 && c.a <= 15, isTrue, reason: 'fator a: ${c.a}');
        expect(c.b >= 8 && c.b <= 15, isTrue, reason: 'fator b: ${c.b}');
        expect(c.resultado, c.a * c.b);
        expect(c.resultado >= 64 && c.resultado <= 225, isTrue);
        expect(c.pontos, 2);
        expect(c.sinal, '×');
        pares.add('${c.a}x${c.b}');
      }
      // Conjunto fechado: 8×8 = 64, sem repetir antes de esgotar.
      expect(pares.length, 64);
      expect(pares, containsAll(['14x15', '15x14', '8x8', '15x15']));
    });

    test('prioridade: 36 sem 8/9 primeiro, 28 com 8/9 depois', () {
      final contas = gerarMultiplicacaoMedio(rng: Random(7));
      final blocoA = contas.take(36);
      final blocoB = contas.skip(36);
      for (final c in blocoA) {
        expect(c.a >= 10 && c.a <= 15, isTrue, reason: 'bloco A, a: ${c.a}');
        expect(c.b >= 10 && c.b <= 15, isTrue, reason: 'bloco A, b: ${c.b}');
      }
      expect(blocoA.map((c) => '${c.a}x${c.b}').toSet().length, 36);
      expect(blocoB.length, 28);
      for (final c in blocoB) {
        expect(c.a == 8 || c.a == 9 || c.b == 8 || c.b == 9, isTrue,
            reason: 'bloco B sem 8/9: ${c.a}x${c.b}');
      }
      // Blocos completos e disjuntos: A ∪ B = 64 pares distintos.
      final todos =
          contas.map((c) => '${c.a}x${c.b}').toSet();
      expect(todos.length, 64);
    });

    test('fatia de 10 fica toda no bloco prioritário (sem 8/9)', () {
      final contas = gerarMultiplicacaoMedio(quantidade: 10, rng: Random(3));
      expect(contas.length, 10);
      for (final c in contas) {
        expect(c.a >= 10 && c.a <= 15, isTrue);
        expect(c.b >= 10 && c.b <= 15, isTrue);
      }
    });

    test('Conta manual: 14 × 15 = 210', () {
      const c = Conta(14, 15, true, 2, true);
      expect(c.vezes, isTrue);
      expect(c.resultado, 210);
      expect(c.sinal, '×');
      expect(c.enunciado, '14 × 15');
    });
  });

  group('multiplicacao base', () {
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
