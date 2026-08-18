/// Habitats do jogo de ANIMAIS. A imagem `assets/habitats/mapa_animais.jpg` é
/// uma grade **3 colunas × 2 linhas** (6 cenas); cada habitat ocupa uma célula
/// dessa grade — por isso `col`/`row` são a posição do botão sobre a imagem.
///
/// A 6ª célula (col 2, linha 1) é o **mapa-múndi** — reservado, sem habitat/botão
/// ativo por enquanto (decisão do usuário).
enum Habitat {
  artico('artico', 'Ártico', '❄️', 0, 0),
  savana('savana', 'Savana', '🦁', 1, 0),
  selva('selva', 'Selva', '🌴', 2, 0),
  aquatico('aquatico', 'Aquático', '🐠', 0, 1),
  aves('aves', 'Aves', '🦅', 1, 1);

  const Habitat(this.chave, this.rotulo, this.emoji, this.col, this.row);

  /// Valor guardado em `Palavra.habitat`.
  final String chave;
  final String rotulo;
  final String emoji;

  /// Posição na grade da imagem: coluna 0..2, linha 0..1.
  final int col;
  final int row;
}

/// Grade da imagem de habitats.
const int kHabitatColunas = 3;
const int kHabitatLinhas = 2;

/// Aspecto da imagem (1536×1024 = 3:2) — usado para alinhar os botões à imagem.
const double kMapaAnimaisAspect = 1536 / 1024;
