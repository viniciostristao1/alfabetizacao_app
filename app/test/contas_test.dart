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

    test('mistas não aceita divisao via gerarContas', () {
      expect(
          () => gerarContas(
              operacao: OperacaoConta.divisao, digitos: 1),
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

    test('escala: 4 (8-9) + 5 + 7 + 9 + 11 + 13 + 15, maior fator crescente',
        () {
      final contas = gerarMultiplicacaoMedio(rng: Random(7));
      expect(contas.length, 64);
      const tamanhos = [4, 5, 7, 9, 11, 13, 15];
      const tetos = [9, 10, 11, 12, 13, 14, 15];
      var i = 0;
      for (var n = 0; n < tamanhos.length; n++) {
        final nivel = contas.skip(i).take(tamanhos[n]).toList();
        expect(nivel.length, tamanhos[n], reason: 'nível $n');
        if (n == 0) {
          // Nível 8–9 primeiro: exatamente 8×8, 8×9, 9×8 e 9×9.
          expect(nivel.map((c) => '${c.a}x${c.b}').toSet(),
              {'8x8', '8x9', '9x8', '9x9'});
        } else {
          // Nível N: todo par tem pelo menos um fator N, nenhum acima de N.
          for (final c in nivel) {
            expect(c.a == tetos[n] || c.b == tetos[n], isTrue,
                reason: 'nível ${tetos[n]} sem $tetos[n]: ${c.a}x${c.b}');
            expect(c.a <= tetos[n] && c.b <= tetos[n], isTrue);
          }
        }
        i += tamanhos[n];
      }
      // Níveis completos e disjuntos: 4+5+7+9+11+13+15 = 64 distintos.
      expect(contas.map((c) => '${c.a}x${c.b}').toSet().length, 64);
    });

    test('fatia respeita a escala do início, sem repetir', () {
      final contas = gerarMultiplicacaoMedio(quantidade: 10, rng: Random(3));
      expect(contas.length, 10);
      expect(contas.map((c) => '${c.a}x${c.b}').toSet().length, 10);
      final cheias = gerarMultiplicacaoMedio(rng: Random(3));
      expect(
          contas.map((c) => '${c.a}x${c.b}').toList(),
          cheias.take(10).map((c) => '${c.a}x${c.b}').toList());
      // Primeiras 10: 4 do nível 8–9 + 5 do nível 10 + 1 do nível 11.
      int maior(Conta c) => c.a > c.b ? c.a : c.b;
      expect(contas.take(9).every((c) => maior(c) <= 10), isTrue);
      expect(maior(contas.last), 11);
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

  group('gerarDivisaoFacil (÷ até 20 • fácil)', () {
    test('27 operações exatas, dividendo 2-20, sem 0/1/próprio, +1 ponto',
        () {
      final contas = gerarDivisaoFacil(rng: Random(7));
      expect(contas.length, 27);
      final pares = <String>{};
      for (final c in contas) {
        expect(c.divisao, isTrue);
        expect(c.a >= 2 && c.a <= 20, isTrue, reason: 'dividendo: ${c.a}');
        expect(c.b >= 2, isTrue, reason: 'sem 0 nem 1: ${c.b}');
        expect(c.b < c.a, isTrue, reason: 'sem o próprio número: ${c.b}');
        expect(c.a % c.b, 0, reason: 'só exata: ${c.a}÷${c.b}');
        expect(c.resultado, c.a ~/ c.b);
        expect(c.pontos, 1);
        expect(c.sinal, '÷');
        expect(c.enunciado, '${c.a} ÷ ${c.b}');
        pares.add('${c.a}÷${c.b}');
      }
      // Conjunto fechado: 27 pares distintos, sem repetir antes de esgotar.
      expect(pares.length, 27);
      expect(pares, containsAll(['12÷3', '6÷2', '20÷10', '4÷2']));
    });

    test('fatia respeita a ordem embaralhada, sem repetir', () {
      final contas = gerarDivisaoFacil(quantidade: 10, rng: Random(3));
      expect(contas.length, 10);
      expect(contas.map((c) => '${c.a}÷${c.b}').toSet().length, 10);
      final cheias = gerarDivisaoFacil(rng: Random(3));
      expect(
          contas.map((c) => '${c.a}÷${c.b}').toList(),
          cheias.take(10).map((c) => '${c.a}÷${c.b}').toList());
    });

    test('mesma semente, mesma ordem (determinístico)', () {
      final a = gerarDivisaoFacil(rng: Random(11)).map((c) => '${c.a}÷${c.b}');
      final b = gerarDivisaoFacil(rng: Random(11)).map((c) => '${c.a}÷${c.b}');
      expect(a.toList(), b.toList());
    });
  });

  group('gerarDivisaoDificil (÷ até 100 • difícil)', () {
    test('pool cheio: 283 operações exatas, dividendo ≤100, +2 pontos', () {
      final contas = gerarDivisaoDificil(quantidade: 500, rng: Random(7));
      expect(contas.length, 283);
      final pares = <String>{};
      for (final c in contas) {
        expect(c.divisao, isTrue);
        expect(c.a >= 2 && c.a <= 100, isTrue, reason: 'dividendo: ${c.a}');
        expect(c.b >= 2, isTrue, reason: 'sem 0 nem 1: ${c.b}');
        expect(c.b < c.a, isTrue, reason: 'sem o próprio número: ${c.b}');
        expect(c.a % c.b, 0, reason: 'só exata: ${c.a}÷${c.b}');
        expect(c.resultado, c.a ~/ c.b);
        expect(c.pontos, 2);
        expect(c.sinal, '÷');
        pares.add('${c.a}÷${c.b}');
      }
      expect(pares.length, 283);
      expect(pares, containsAll(['100÷2', '100÷50', '81÷9', '64÷8']));
    });

    test('fatia padrão de 20, sem repetir, frente do pool', () {
      final contas = gerarDivisaoDificil(rng: Random(3));
      expect(contas.length, 20);
      expect(contas.map((c) => '${c.a}÷${c.b}').toSet().length, 20);
      final cheias = gerarDivisaoDificil(quantidade: 283, rng: Random(3));
      expect(
          contas.map((c) => '${c.a}÷${c.b}').toList(),
          cheias.take(20).map((c) => '${c.a}÷${c.b}').toList());
    });

    test('Conta manual: 12 ÷ 3 = 4', () {
      const c = Conta(12, 3, true, 1, false, true);
      expect(c.divisao, isTrue);
      expect(c.resultado, 4);
      expect(c.sinal, '÷');
      expect(c.enunciado, '12 ÷ 3');
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

    test('multiplicação: ×, x, X, * e espaços', () {
      for (final t in ['3×4', '3x4', '3X4', '3*4', '3 × 4', '  3  ×  4  ']) {
        final c = parseConta(t)!;
        expect(c.vezes, isTrue);
        expect(c.a, 3);
        expect(c.b, 4);
        expect(c.resultado, 12);
        expect(c.sinal, '×');
        expect(c.enunciado, '3 × 4');
      }
    });

    test('divisão: ÷, / e : com espaços opcionais', () {
      for (final t in ['10÷2', '10/2', '10:2', '10 ÷ 2']) {
        final c = parseConta(t)!;
        expect(c.divisao, isTrue);
        expect(c.a, 10);
        expect(c.b, 2);
        expect(c.resultado, 5);
        expect(c.sinal, '÷');
        expect(c.enunciado, '10 ÷ 2');
      }
    });

    test('divisão por zero recusada, com mensagem', () {
      expect(parseConta('10÷0'), isNull);
      expect(interpretarConta('10÷0').erro, 'Divisão por zero não existe');
      expect(interpretarConta('10/0').erro, 'Divisão por zero não existe');
    });

    test('divisão não exata recusada, com mensagem', () {
      expect(parseConta('10÷3'), isNull);
      expect(interpretarConta('10÷3').erro, 'Use uma divisão exata, sem resto');
      expect(parseConta('10:20'), isNull); // vira ÷, dá 0,5
    });

    test('limite 999 para × e ÷, com mensagem', () {
      expect(parseConta('1000×1'), isNull);
      expect(interpretarConta('1000×1').erro, 'Use números e resultado até 999.');
      expect(parseConta('40×25'), isNull); // 1000 > 999
      expect(parseConta('1000÷2'), isNull);
      expect(parseConta('27×37')!.resultado, 999); // limite exato aceita
    });

    test('negativo e formato seguem recusados, soma/sub intactas', () {
      expect(parseConta('2-10'), isNull); // negativo (como antes)
      expect(parseConta('10-2-1'), isNull);
      expect(parseConta('12,5+2'), isNull);
      expect(parseConta('12a+3'), isNull);
      expect(interpretarConta('7 - 12').erro, contains('sem resultado negativo'));
      // soma e subtração antigas, mesmos resultados de sempre:
      final soma = parseConta('12 + 7')!;
      expect(soma.resultado, 19);
      expect(soma.pontos, 2);
      expect(soma.vezes, isFalse);
      expect(soma.divisao, isFalse);
      final sub = parseConta('20-8')!;
      expect(sub.resultado, 12);
      expect(sub.soma, isFalse);
    });

    test('pontos: escrita vale o resultado (difere da categoria fácil)', () {
      // "3×4" escrita dá +2 (resultado 12 tem dois dígitos); na categoria
      // "2 à 7 • fácil" a mesma conta vale +1. Registrado de propósito.
      expect(parseConta('3×4')!.pontos, 2);
      expect(parseConta('2×3')!.pontos, 1);
      expect(parseConta('12÷3')!.pontos, 2);
      expect(parseConta('6÷2')!.pontos, 1);
    });

    test('zero: 0÷5 e 0×7 aceitos, resultado 0', () {
      final d = parseConta('0÷5')!;
      expect(d.resultado, 0);
      expect(d.pontos, 1);
      final m = parseConta('0×7')!;
      expect(m.resultado, 0);
      expect(m.pontos, 1);
    });
  });
}
