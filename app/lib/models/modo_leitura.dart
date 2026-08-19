/// Como as palavras são mostradas na tela de estudo (nível de dificuldade da
/// leitura). Por ora: **MAIÚSCULAS** (caixa alta, padrão) e **minúsculas**
/// (palavra completa em minúsculas). Um 3º modo — "completar a sílaba que falta"
/// (múltipla escolha, em MAIÚSCULAS) — entra depois como tela própria.
enum ModoLeitura {
  maiuscula('MAIÚSCULAS'),
  minuscula('minúsculas'),
  incompleta('Completar'); // MAIÚSCULAS com uma sílaba faltando (múltipla escolha)

  const ModoLeitura(this.rotulo);

  final String rotulo;

  /// Aplica o caixa da palavra conforme o modo (no modo "incompleta" a palavra
  /// aparece em MAIÚSCULAS; a montagem do desafio é feita à parte).
  String aplicar(String texto) => switch (this) {
        ModoLeitura.minuscula => texto.toLowerCase(),
        _ => texto.toUpperCase(),
      };
}
