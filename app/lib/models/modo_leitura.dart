/// Como as palavras são mostradas na tela de estudo (nível de dificuldade da
/// leitura). Por ora: **MAIÚSCULAS** (caixa alta, padrão) e **minúsculas**
/// (palavra completa em minúsculas). Um 3º modo — "completar a sílaba que falta"
/// (múltipla escolha, em MAIÚSCULAS) — entra depois como tela própria.
enum ModoLeitura {
  maiuscula('MAIÚSCULAS'),
  minuscula('minúsculas'),
  incompleta('Completar'), // MAIÚSCULAS com uma sílaba faltando (múltipla escolha)
  ditado('Ditado'); // o app FALA e a criança monta a palavra com as sílabas

  const ModoLeitura(this.rotulo);

  final String rotulo;

  /// Aplica o caixa da palavra conforme o modo (no modo "incompleta" a palavra
  /// aparece em MAIÚSCULAS; a montagem do desafio é feita à parte).
  String aplicar(String texto) => switch (this) {
        ModoLeitura.minuscula => texto.toLowerCase(),
        _ => texto.toUpperCase(),
      };

  /// Aplica o caixa da FRASE conforme o modo: em minúsculas a frase fica
  /// como no livro — 1ª letra maiúscula e o resto como está (preserva
  /// nomes próprios: "Os anéis de Saturno são lindos", "O Davi sabe ler");
  /// nos demais modos, tudo em MAIÚSCULAS.
  String aplicarFrase(String frase) {
    if (this != ModoLeitura.minuscula) return aplicar(frase);
    if (frase.isEmpty) return frase;
    return frase[0].toUpperCase() + frase.substring(1);
  }
}
