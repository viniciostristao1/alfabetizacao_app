/// Como as palavras são mostradas na tela de estudo (nível de dificuldade da
/// leitura). Por ora: **MAIÚSCULAS** (caixa alta, padrão) e **minúsculas**
/// (palavra completa em minúsculas). Um 3º modo — "completar a sílaba que falta"
/// (múltipla escolha, em MAIÚSCULAS) — entra depois como tela própria.
enum ModoLeitura {
  maiuscula('MAIÚSCULAS'),
  minuscula('minúsculas');

  const ModoLeitura(this.rotulo);

  final String rotulo;

  /// Aplica o caixa da palavra conforme o modo.
  String aplicar(String texto) => switch (this) {
        ModoLeitura.maiuscula => texto.toUpperCase(),
        ModoLeitura.minuscula => texto.toLowerCase(),
      };
}
