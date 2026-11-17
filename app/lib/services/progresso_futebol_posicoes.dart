import 'package:shared_preferences/shared_preferences.dart';

/// Progresso do quiz das posições (Futebol > Temas). Fase única: 'posicoes'.
/// Mesmo molde dos demais progressos de temas (lista de concluídas).
class ProgressoFutebolPosicoes {
  static const _chave = 'fases_futebol_posicoes_concluidas_v1';

  static const fasePosicoes = 'posicoes';

  static Future<List<String>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_chave) ?? const <String>[];
  }

  static Future<bool> get concluido async =>
      (await carregar()).contains(fasePosicoes);

  static Future<void> marcarConcluido() async {
    final prefs = await SharedPreferences.getInstance();
    final atuais = prefs.getStringList(_chave) ?? const <String>[];
    if (atuais.contains(fasePosicoes)) return;
    await prefs.setStringList(_chave, [...atuais, fasePosicoes]);
  }

  static Future<void> reiniciar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }
}
