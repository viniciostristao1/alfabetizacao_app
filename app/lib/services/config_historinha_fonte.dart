import 'package:shared_preferences/shared_preferences.dart';

import '../models/livro.dart';

class ConfigHistorinhaFonte {
  static const _chave = 'fonte_historinha_v1';

  static Future<FonteHistorinha> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString(_chave);
    return FonteHistorinha.values.firstWhere(
      (f) => f.name == nome,
      orElse: () => FonteHistorinha.maiuscula,
    );
  }

  static Future<void> salvar(FonteHistorinha fonte) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, fonte.name);
  }
}
