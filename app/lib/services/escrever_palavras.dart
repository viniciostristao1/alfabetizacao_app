import 'package:shared_preferences/shared_preferences.dart';

/// Lista de palavras da categoria "Escrever" — digitadas pelo usuário (o pai/
/// mãe). Local (shared_preferences), mesmo padrão de ProgressoFases/ConfigOrdem:
/// a lista fica salva entre sessões, na ordem em que foi montada.
class EscreverPalavras {
  static const _chave = 'escrever_palavras_v1';

  static Future<List<String>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_chave) ?? [];
  }

  static Future<void> salvar(List<String> palavras) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_chave, palavras);
  }
}
