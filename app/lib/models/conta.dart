/// Tipo de operação escolhido no menu de Contas.
enum OperacaoConta { soma, subtracao, mistas, multiplicacao, divisao }

/// Uma conta de matemática (soma, subtração, multiplicação ou divisão exata).
/// Guardamos os operandos e quantos **pontos** (moedas) o acerto vale: **+1**
/// para contas de 1 dígito, para a multiplicação "2 à 7 • fácil" (2–7 × 2–7)
/// e para a divisão "÷ até 20 • fácil", **+2** para contas de 2 dígitos, para
/// a multiplicação "8 a 15 • Médio" (8–15 × 8–15) e para a divisão
/// "÷ até 100 • difícil".
class Conta {
  const Conta(this.a, this.b, this.soma, this.pontos,
      [this.vezes = false, this.divisao = false])
      : assert(!(vezes && divisao), 'vezes e divisao são exclusivos');

  final int a;
  final int b;
  final bool soma; // true = soma (+), false = subtração (−); ignorado se vezes/divisao
  final int pontos; // moedas ao acertar (1 ou 2)
  final bool vezes; // true = multiplicação (×)
  final bool divisao; // true = divisão exata (÷)

  int get resultado => divisao
      ? a ~/ b
      : (vezes ? a * b : (soma ? a + b : a - b));
  String get sinal => divisao ? '÷' : (vezes ? '×' : (soma ? '+' : '−'));

  /// O enunciado, ex.: "12 + 7" (sem o resultado).
  String get enunciado => '$a $sinal $b';
}
