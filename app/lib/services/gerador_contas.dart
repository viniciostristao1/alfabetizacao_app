import 'dart:math';

import '../models/conta.dart';

/// Gera contas aleatórias de soma/subtração com [digitos] = 1 (0–9) ou 2 (10–99).
/// Subtração nunca dá resultado negativo (garante a ≥ b). Na soma de 2 dígitos o
/// resultado é mantido ≤ 99 (continua "de 2 dígitos"). Pontos = [digitos] (1 ou 2).
List<Conta> gerarContas({
  required OperacaoConta operacao,
  required int digitos,
  int quantidade = 10,
  Random? rng,
}) {
  final r = rng ?? Random();
  final min = digitos == 2 ? 10 : 0;
  final max = digitos == 2 ? 99 : 9;
  final contas = <Conta>[];
  var tentativas = 0;
  while (contas.length < quantidade && tentativas < quantidade * 50) {
    tentativas++;
    final soma = switch (operacao) {
      OperacaoConta.soma => true,
      OperacaoConta.subtracao => false,
      OperacaoConta.mistas => r.nextBool(),
      // Multiplicação e divisão têm geradores próprios
      // (gerarMultiplicacaoFacil/Medio, gerarDivisaoFacil/Dificil) e NUNCA
      // entram em Mistas — gerarContas não gera × nem ÷.
      OperacaoConta.multiplicacao => throw ArgumentError(
          'Use gerarMultiplicacaoFacil()/gerarMultiplicacaoMedio()'),
      OperacaoConta.divisao => throw ArgumentError(
          'Use gerarDivisaoFacil()/gerarDivisaoDificil()'),
    };
    var a = min + r.nextInt(max - min + 1);
    var b = min + r.nextInt(max - min + 1);
    if (soma) {
      if (digitos == 2 && a + b > 99) continue; // mantém resultado 2 dígitos
    } else {
      if (a < b) {
        final t = a;
        a = b;
        b = t;
      }
    }
    contas.add(Conta(a, b, soma, digitos));
  }
  return contas;
}

/// Gera contas de MULTIPLICAÇÃO "2 à 7 • fácil": todos os pares ordenados de
/// fatores **2 a 7** (6×6 = **36** — `6×7` e `7×6` contam separado),
/// embaralhados. Produto de 4 a 49 (máx `7×7`). Pontos por conta = 1.
/// Por padrão retorna o conjunto cheio (36); [quantidade] fatia da frente
/// (mantém a ordem embaralhada, sem repetir dentro da sessão).
List<Conta> gerarMultiplicacaoFacil({int? quantidade, Random? rng}) {
  final r = rng ?? Random();
  final pares = <(int, int)>[
    for (var a = 2; a <= 7; a++)
      for (var b = 2; b <= 7; b++) (a, b),
  ]..shuffle(r);
  var q = quantidade ?? pares.length;
  if (q < 0) q = 0;
  if (q > pares.length) q = pares.length;
  return [for (final (a, b) in pares.take(q)) Conta(a, b, true, 1, true)];
}

/// Gera contas de MULTIPLICAÇÃO "8 a 15 • Médio": todos os pares ordenados de
/// fatores **8 a 15** (8×8 = **64**), em escala pelo maior fator, em níveis
/// crescentes: **8–9** (4 pares: 8×8, 8×9, 9×8, 9×9), depois **N = 10..15**
/// com pelo menos um fator N (5, 7, 9, 11, 13 e 15 pares). Dentro de cada
/// nível a ordem é embaralhada. Produto de 64 a 225 (máx `15×15`). Pontos
/// por conta = 2. Por padrão retorna o conjunto cheio (64); [quantidade]
/// fatia da frente (escala respeitada, sem repetir).
List<Conta> gerarMultiplicacaoMedio({int? quantidade, Random? rng}) {
  final r = rng ?? Random();
  final niveis = <List<(int, int)>>[
    [(8, 8), (8, 9), (9, 8), (9, 9)],
    for (var n = 10; n <= 15; n++)
      [
        for (var a = 8; a <= n; a++)
          for (var b = 8; b <= n; b++)
            if (a == n || b == n) (a, b),
      ],
  ];
  for (final nivel in niveis) {
    nivel.shuffle(r);
  }
  final todos = [for (final nivel in niveis) ...nivel];
  var q = quantidade ?? todos.length;
  if (q < 0) q = 0;
  if (q > todos.length) q = todos.length;
  return [for (final (a, b) in todos.take(q)) Conta(a, b, true, 2, true)];
}

/// Gera contas de DIVISÃO "÷ até 20 • fácil": todos os pares exatos de
/// dividendo **2 a 20** com divisor **2 a d−1** (0, 1 e o próprio número ficam
/// de fora — trivial; primos não têm par e saem sozinhos). São **27**
/// operações, embaralhadas, quocientes 2–10. Pontos por conta = 1.
/// Por padrão retorna o conjunto cheio (27); [quantidade] fatia da frente
/// (sem repetir dentro da sessão).
List<Conta> gerarDivisaoFacil({int? quantidade, Random? rng}) {
  final r = rng ?? Random();
  final pares = <(int, int)>[
    for (var d = 2; d <= 20; d++)
      for (var k = 2; k <= d - 1; k++)
        if (d % k == 0) (d, k),
  ]..shuffle(r);
  var q = quantidade ?? pares.length;
  if (q < 0) q = 0;
  if (q > pares.length) q = pares.length;
  return [for (final (d, k) in pares.take(q)) Conta(d, k, true, 1, false, true)];
}

/// Gera contas de DIVISÃO "÷ até 100 • difícil": todos os pares exatos de
/// dividendo **2 a 100** com divisor **2 a d−1** (283 operações — sessão cheia
/// seria longa demais p/ a criança, por isso a sessão padrão é uma **fatia
/// de 20**, embaralhada do pool cheio). Quocientes 2–50. Pontos por conta = 2.
/// [quantidade] fatia da frente (sem repetir dentro da fatia).
List<Conta> gerarDivisaoDificil({int quantidade = 20, Random? rng}) {
  final r = rng ?? Random();
  final pares = <(int, int)>[
    for (var d = 2; d <= 100; d++)
      for (var k = 2; k <= d - 1; k++)
        if (d % k == 0) (d, k),
  ]..shuffle(r);
  var q = quantidade;
  if (q < 0) q = 0;
  if (q > pares.length) q = pares.length;
  return [for (final (d, k) in pares.take(q)) Conta(d, k, true, 2, false, true)];
}

/// Contas de SOMA com os dois números **até [limite]** (ex.: "até 20": 5+19,
/// 15+15, 7+10…). Pontos por conta = 2 se houver número ≥10, senão 1.
List<Conta> gerarContasAte(int limite, {int quantidade = 10, Random? rng}) {
  final r = rng ?? Random();
  return [
    for (var i = 0; i < quantidade; i++)
      () {
        final a = r.nextInt(limite + 1);
        final b = r.nextInt(limite + 1);
        final pontos = (a >= 10 || b >= 10 || a + b >= 10) ? 2 : 1;
        return Conta(a, b, true, pontos);
      }(),
  ];
}

/// Interpreta uma conta escrita pelo usuário (ex.: "12 + 7", "20-8"). Aceita
/// `+` ou `-`/`−`. Retorna null se for inválida (formato errado, número negativo
/// ou subtração que daria resultado negativo). Pontos = 2 se houver número ≥ 10.
Conta? parseConta(String texto) {
  final t = texto.replaceAll(' ', '').replaceAll('−', '-');
  final soma = t.contains('+');
  final sub = t.contains('-');
  if (soma == sub) return null; // precisa de exatamente um sinal
  final partes = t.split(soma ? '+' : '-');
  if (partes.length != 2) return null;
  final a = int.tryParse(partes[0]);
  final b = int.tryParse(partes[1]);
  if (a == null || b == null || a < 0 || b < 0) return null;
  if (!soma && a < b) return null; // sem resultado negativo
  final resultado = soma ? a + b : a - b;
  final pontos = (a >= 10 || b >= 10 || resultado >= 10) ? 2 : 1;
  return Conta(a, b, soma, pontos);
}
