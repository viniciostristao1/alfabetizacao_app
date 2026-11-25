/// Tipo de operação escolhido no menu de Contas.
enum OperacaoConta { soma, subtracao, mistas, multiplicacao }

/// Uma conta de matemática (soma, subtração ou multiplicação). Guardamos os
/// operandos e quantos **pontos** (moedas) o acerto vale: **+1** para contas de
/// 1 dígito e para a multiplicação "2 à 7 • fácil" (2–7 × 2–7), **+2** para
/// contas de 2 dígitos e para a multiplicação "8 a 15 • Médio" (8–15 × 8–15).
class Conta {
  const Conta(this.a, this.b, this.soma, this.pontos, [this.vezes = false]);

  final int a;
  final int b;
  final bool soma; // true = soma (+), false = subtração (−); ignorado se vezes
  final int pontos; // moedas ao acertar (1 ou 2)
  final bool vezes; // true = multiplicação (×)

  int get resultado => vezes ? a * b : (soma ? a + b : a - b);
  String get sinal => vezes ? '×' : (soma ? '+' : '−');

  /// O enunciado, ex.: "12 + 7" (sem o resultado).
  String get enunciado => '$a $sinal $b';
}
