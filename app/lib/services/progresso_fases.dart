import 'progresso_lista_concluidas.dart';

/// Guarda quais **fases (habitats)** a criança já concluiu — usado pelo mapa-múndi
/// para acender o círculo e o caminho até a próxima fase. Local (shared_preferences),
/// sem nuvem. Guarda como **lista ordenada** pela ordem em que foram concluídas,
/// para o botão "Voltar habitat" desfazer a ÚLTIMA. Chaves = `Habitat.chave`.
class ProgressoFases {
  static const _loja = ProgressoListaConcluidas('fases_concluidas_v1');

  /// Fases concluídas, **na ordem em que foram concluídas** (a última é o fim).
  static Future<List<String>> carregar() => _loja.carregar();

  /// Marca um habitat como concluído (idempotente; mantém a ordem de conclusão).
  static Future<void> marcarConcluido(String habitatChave) =>
      _loja.marcarConcluido(habitatChave);

  /// Desfaz a ÚLTIMA fase concluída ("Voltar habitat") — devolve a lista restante.
  static Future<List<String>> voltarUltima() => _loja.voltarUltima();

  /// Zera o progresso — "Reiniciar aventura": as luzes das fases voltam a apagar.
  static Future<void> reiniciar() => _loja.reiniciar();
}
