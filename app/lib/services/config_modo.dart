import 'package:shared_preferences/shared_preferences.dart';

import '../models/modo_jogo.dart';

/// Guarda o **modo do jogo** (Palavra isolada ou Frases), escolhido nas
/// Configurações. Local (shared_preferences). Padrão = Palavra (o modo antigo).
class ConfigModo {
  static const _chave = 'modo_jogo_v1';

  static Future<ModoJogo> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString(_chave);
    return ModoJogo.values.firstWhere(
      (m) => m.name == nome,
      orElse: () => ModoJogo.palavra,
    );
  }

  static Future<void> salvar(ModoJogo modo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, modo.name);
  }
}
