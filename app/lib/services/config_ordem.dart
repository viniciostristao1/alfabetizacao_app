import 'package:shared_preferences/shared_preferences.dart';

import '../models/regiao.dart';

/// Ordem (configurável pelo usuário) em que as **regiões/continentes** aparecem
/// no mapa-múndi. Local (shared_preferences). Guarda a lista de `Regiao.chave` na
/// ordem escolhida; cai na ordem padrão (`Regiao.regioes`).
class ConfigOrdem {
  static const _chave = 'ordem_regioes_v1';

  static List<String> get _padrao =>
      Regiao.regioes.map((r) => r.chave).toList();

  /// Ordem atual (chaves). **Sanitiza:** descarta chaves inválidas e acrescenta
  /// no fim regiões que ainda não estejam salvas — assim nunca some uma fase.
  static Future<List<String>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getStringList(_chave);
    if (salvo == null) return _padrao;
    final validas = Regiao.values.map((r) => r.chave).toSet();
    final ordem = salvo.where(validas.contains).toList();
    for (final chave in _padrao) {
      if (!ordem.contains(chave)) ordem.add(chave);
    }
    return ordem;
  }

  /// Salva a nova ordem (lista de chaves).
  static Future<void> salvar(List<String> chaves) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_chave, chaves);
  }

  /// As regiões já na ordem configurada.
  static Future<List<Regiao>> fases() async {
    final chaves = await carregar();
    return [
      for (final c in chaves) ?Regiao.porChave(c),
    ];
  }
}
