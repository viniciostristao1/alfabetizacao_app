import 'package:shared_preferences/shared_preferences.dart';

class ProgressoAlimentosFases {
  static const _chave = 'fases_alimentos_concluidas_v1';

  static Future<List<String>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_chave) ?? const <String>[];
  }

  static Future<void> marcarConcluido(String chave) async {
    final prefs = await SharedPreferences.getInstance();
    final atuais = prefs.getStringList(_chave) ?? const <String>[];
    if (atuais.contains(chave)) return;
    await prefs.setStringList(_chave, [...atuais, chave]);
  }

  static Future<List<String>> voltarUltima() async {
    final prefs = await SharedPreferences.getInstance();
    final atuais = prefs.getStringList(_chave) ?? const <String>[];
    if (atuais.isEmpty) return const <String>[];
    final restantes = atuais.sublist(0, atuais.length - 1);
    await prefs.setStringList(_chave, restantes);
    return restantes;
  }

  static Future<void> reiniciar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }
}
