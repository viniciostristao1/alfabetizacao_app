import 'package:shared_preferences/shared_preferences.dart';

import '../models/estudo_opcoes.dart';

/// Fundo da tela de estudo (preto/branco/beges/imagem) — escolhido nas
/// bolinhas ao lado do título. Local (shared_preferences), vale entre
/// sessões e entre categorias. Padrão = PRETO.
class ConfigFundo {
  static const _chave = 'fundo_tela_v1';

  static Future<FundoTela> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString(_chave);
    return FundoTela.values.firstWhere(
      (f) => f.name == nome,
      orElse: () => FundoTela.preto,
    );
  }

  static Future<void> salvar(FundoTela fundo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, fundo.name);
  }
}
