import 'package:shared_preferences/shared_preferences.dart';

/// Guarda quais **fases (habitats)** a criança já concluiu — usado pelo mapa-múndi
/// para acender o círculo e o caminho até a próxima fase. Local (shared_preferences),
/// sem nuvem. Guarda como **lista ordenada** pela ordem em que foram concluídas,
/// para o botão "Voltar habitat" desfazer a ÚLTIMA. Chaves = `Habitat.chave`.
class ProgressoFases {
  static const _chave = 'fases_concluidas_v1';

  /// Fases concluídas, **na ordem em que foram concluídas** (a última é o fim).
  static Future<List<String>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_chave) ?? const <String>[];
  }

  /// Marca um habitat como concluído (idempotente; mantém a ordem de conclusão).
  static Future<void> marcarConcluido(String habitatChave) async {
    final prefs = await SharedPreferences.getInstance();
    final atuais = prefs.getStringList(_chave) ?? const <String>[];
    if (atuais.contains(habitatChave)) return;
    await prefs.setStringList(_chave, [...atuais, habitatChave]);
  }

  /// Desfaz a ÚLTIMA fase concluída ("Voltar habitat") — devolve a lista restante.
  static Future<List<String>> voltarUltima() async {
    final prefs = await SharedPreferences.getInstance();
    final atuais = prefs.getStringList(_chave) ?? const <String>[];
    if (atuais.isEmpty) return const <String>[];
    final restantes = atuais.sublist(0, atuais.length - 1);
    await prefs.setStringList(_chave, restantes);
    return restantes;
  }

  /// Zera o progresso — "Reiniciar aventura": as luzes das fases voltam a apagar.
  static Future<void> reiniciar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }
}
