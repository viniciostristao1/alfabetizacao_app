import 'package:shared_preferences/shared_preferences.dart';

import '../models/modo_leitura.dart';

/// Guarda o **modo de leitura** das palavras (MAIÚSCULAS / minúsculas), escolhido
/// nas Configurações. Local (shared_preferences). Padrão = MAIÚSCULAS.
class ConfigLeitura {
  static const _chave = 'modo_leitura_v1';

  static Future<ModoLeitura> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString(_chave);
    return ModoLeitura.values.firstWhere(
      (m) => m.name == nome,
      orElse: () => ModoLeitura.maiuscula,
    );
  }

  static Future<void> salvar(ModoLeitura modo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, modo.name);
  }
}
