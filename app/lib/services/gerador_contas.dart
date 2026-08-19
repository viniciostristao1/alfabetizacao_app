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
