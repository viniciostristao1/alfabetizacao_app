/// Como o conteúdo aparece na tela de estudo: **palavra** isolada (o modo
/// antigo) ou **frase** completa construída a partir da palavra (o "Modo
/// Frases" — ex.: `leão` vira `O leão mora na savana`). Escolhido nas
/// Configurações, vale para todas as categorias (ver [ConfigModo]).
enum ModoJogo {
  palavra('Palavra'),
  frase('Frases');

  const ModoJogo(this.rotulo);

  final String rotulo;
}
