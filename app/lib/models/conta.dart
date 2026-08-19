/// Tipo de operação escolhido no menu de Contas.
enum OperacaoConta { soma, subtracao, mistas }

/// Uma conta de matemática (soma ou subtração). Guardamos os operandos e quantos
/// **pontos** (moedas) o acerto vale: **+1** para contas de 1 dígito, **+2** para
/// contas de 2 dígitos (pedido do usuário).
class Conta {
  const Conta(this.a, this.b, this.soma, this.pontos);

  final int a;
  final int b;
  final bool soma; // true = soma (+), false = subtração (−)
  final int pontos; // moedas ao acertar (1 ou 2)

  int get resultado => soma ? a + b : a - b;
  String get sinal => soma ? '+' : '−';

  /// O enunciado, ex.: "12 + 7" (sem o resultado).
  String get enunciado => '$a $sinal $b';
}
