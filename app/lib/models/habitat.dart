import 'package:flutter/material.dart';

/// Habitats do jogo de ANIMAIS.
///
/// - `col`/`row`: posição na grade 3×2 da imagem `mapa_animais.jpg` (a tela de
///   seleção de habitats). A 6ª célula (col 2, linha 1) = mapa-múndi.
/// - `ordem`/`fx`/`fy`: para o **mapa-múndi de fases** (`mapa_mundi.jpg`). `ordem`
///   é a sequência das fases (1→5); `fx`/`fy` são a posição do círculo da fase
///   sobre o mapa-múndi, como fração 0..1 (x=coluna, y=linha).
enum Habitat {
  // fx/fy = posição do círculo sobre a arte `mapa_mundi.jpg` (1376×768), cada
  // bicho no seu continente/região. ordem = caminho das fases (flui pelo mapa).
  artico('artico', 'Ártico', '❄️', 0, 0, 1, 0.44, 0.15), //   gelo/urso polar (topo)
  aves('aves', 'Aves', '🦅', 1, 1, 2, 0.85, 0.15), //          aves voando (dir. sup.)
  savana('savana', 'Savana', '🦁', 1, 0, 3, 0.59, 0.60), //    África (leão)
  selva('selva', 'Selva', '🌴', 2, 0, 4, 0.34, 0.72), //       Am. do Sul (onça)
  aquatico('aquatico', 'Aquático', '🐠', 0, 1, 5, 0.12, 0.66); // mar (baleias, à esq.)

  const Habitat(
    this.chave,
    this.rotulo,
    this.emoji,
    this.col,
    this.row,
    this.ordem,
    this.fx,
    this.fy,
  );

  final String chave;
  final String rotulo;
  final String emoji;
  final int col;
  final int row;
  final int ordem;
  final double fx;
  final double fy;

  /// As fases na ordem do jogo (1→5).
  static List<Habitat> get fases =>
      Habitat.values.toList()..sort((a, b) => a.ordem.compareTo(b.ordem));
}

/// Grade da imagem de habitats (mapa_animais.jpg).
const int kHabitatColunas = 3;
const int kHabitatLinhas = 2;

/// Aspecto das imagens: `mapa_animais.jpg` = 1536×1024 (3:2); `mapa_mundi.jpg`
/// = 1376×768 (≈16:9). Exibição usa `kMapaDisplayAspect` (esticado p/ tela cheia).
const double kMapaAnimaisAspect = 1536 / 1024;
const double kMapaMundiAspect = 1376 / 768;

/// Aspecto de EXIBIÇÃO dos mapas em paisagem — um pouco mais largo que o nativo,
/// pra imagem **encostar nas laterais** (não ficar "quadrada"). A imagem enche a
/// largura da tela (esticada de leve, `BoxFit.fill`, sem cortar) e a sobra em
/// cima/embaixo vira água (`kAgua`). Em telas bem largas ela toma a tela inteira.
const double kMapaDisplayAspect = 2.0;

/// Azul do oceano — usado para "inventar água" ao redor da imagem, preenchendo a
/// tela sem cortar nada (a imagem aparece inteira, na proporção certa).
const Color kAgua = Color(0xFF013A66);
