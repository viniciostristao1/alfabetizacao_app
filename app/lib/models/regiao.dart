/// Regiões do **mapa-múndi por CONTINENTE** — as fases do jogo agrupadas por
/// **onde o animal vive no planeta** (não por tipo de habitat). Ensina a criança
/// onde cada bicho sobrevive: leão na África, macaco no Brasil, panda na Ásia…
///
/// - `fx`/`fy`: posição do anel da fase sobre a arte `mapa_mundi.jpg` (fração 0..1).
/// - `ordem`: sequência PADRÃO das fases (o usuário reordena em Configurações →
///   ConfigOrdem). O nome da fase é o do continente + Oceano + Céu.
enum Regiao {
  // ordem/fx/fy dão um caminho horário pelo mapa (o usuário pode reordenar).
  norte('norte', 'América do Norte', '🦌', 1, 0.17, 0.33),
  artico('artico', 'Ártico', '🐻‍❄️', 2, 0.44, 0.14),
  ceu('ceu', 'Céu', '🦅', 3, 0.85, 0.13),
  asia('asia', 'Ásia', '🐼', 4, 0.80, 0.31),
  australia('australia', 'Austrália', '🦘', 5, 0.87, 0.66),
  africa('africa', 'África', '🦁', 6, 0.59, 0.60),
  oceano('oceano', 'Oceano', '🐬', 7, 0.46, 0.47),
  sul('sul', 'América do Sul', '🐒', 8, 0.34, 0.72);

  const Regiao(this.chave, this.rotulo, this.emoji, this.ordem, this.fx, this.fy);

  final String chave;
  final String rotulo;
  final String emoji;
  final int ordem;
  final double fx;
  final double fy;

  /// As regiões na ordem PADRÃO (por `ordem`). O mapa-múndi usa a ordem
  /// configurável (ConfigOrdem), que cai nesta como padrão.
  static List<Regiao> get regioes =>
      Regiao.values.toList()..sort((a, b) => a.ordem.compareTo(b.ordem));

  /// Região pela chave ('africa', 'asia', …) ou null se não existir.
  static Regiao? porChave(String chave) {
    for (final r in Regiao.values) {
      if (r.chave == chave) return r;
    }
    return null;
  }
}
