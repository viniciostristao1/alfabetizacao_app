import 'package:shared_preferences/shared_preferences.dart';

/// Guarda as contas que o pai/mãe escreveu (ex.: "12 + 7"), para reusar entre
/// sessões. Local (shared_preferences), mesmo padrão de EscreverPalavras.
class ContasEscritas {
  static const _chave = 'contas_escritas_v1';

  static Future<List<String>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_chave) ?? const <String>[];
  }

  static Future<void> salvar(List<String> contas) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_chave, contas);
  }
}
