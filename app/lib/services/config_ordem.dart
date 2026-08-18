import 'package:shared_preferences/shared_preferences.dart';

import '../models/habitat.dart';

/// Ordem (configurável pelo usuário) em que as **fases/categorias de animais**
/// aparecem no mapa-múndi. Local (shared_preferences). Guarda a lista de
/// `Habitat.chave` na ordem escolhida; cai na ordem padrão (`Habitat.fases`).
class ConfigOrdem {
  static const _chave = 'ordem_fases_v1';

  static List<String> get _padrao =>
      Habitat.fases.map((h) => h.chave).toList();

  /// Ordem atual (chaves). **Sanitiza:** descarta chaves inválidas e acrescenta
  /// no fim habitats que ainda não estejam salvos (ex.: Fazenda entrou depois) —
  /// assim nunca some uma fase pra quem já tinha uma ordem salva.
  static Future<List<String>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final salvo = prefs.getStringList(_chave);
    if (salvo == null) return _padrao;
    final validas = Habitat.values.map((h) => h.chave).toSet();
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

  /// As fases (Habitat) já na ordem configurada.
  static Future<List<Habitat>> fases() async {
    final chaves = await carregar();
    return [
      for (final c in chaves) ?Habitat.porChave(c),
    ];
  }
}
