import 'package:shared_preferences/shared_preferences.dart';

/// Guarda quais **fases (habitats)** a criança já concluiu — usado pelo mapa-múndi
/// para acender o círculo e o caminho até a próxima fase. Local (shared_preferences),
/// sem nuvem. Chaves = `Habitat.chave` ('artico', 'savana', …).
class ProgressoFases {
  static const _chave = 'fases_concluidas_v1';

  /// Conjunto de habitats concluídos.
  static Future<Set<String>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_chave) ?? const <String>[]).toSet();
  }

  /// Marca um habitat como concluído (idempotente).
  static Future<void> marcarConcluido(String habitatChave) async {
    final prefs = await SharedPreferences.getInstance();
    final atuais = (prefs.getStringList(_chave) ?? const <String>[]).toSet();
    if (atuais.add(habitatChave)) {
      await prefs.setStringList(_chave, atuais.toList());
    }
  }

  /// Zera o progresso — "Reiniciar aventura": as luzes das fases voltam a apagar.
  static Future<void> reiniciar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }
}
