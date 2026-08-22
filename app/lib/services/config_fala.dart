import 'package:shared_preferences/shared_preferences.dart';

/// Se o app deve **FALAR as palavras** (voz do celular) — escolhido nas
/// Configurações. Local (shared_preferences). Padrão = LIGADO.
class ConfigFala {
  static const _chave = 'falar_palavras_v1';

  static Future<bool> ativado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chave) ?? true;
  }

  static Future<void> salvar(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chave, valor);
  }
}
