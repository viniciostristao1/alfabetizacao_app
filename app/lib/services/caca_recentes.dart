import 'package:shared_preferences/shared_preferences.dart';

import '../models/categoria.dart';
import '../models/palavra.dart';

/// Memória das palavras usadas nas últimas rodadas do caça-palavras, por
/// tema e nível — a "Nova caçada" evita repetir as recém-usadas enquanto o
/// banco permite (se faltar palavra, libera as mais antigas primeiro).
///
/// Chave NOVA (`caca_recentes_v1`): nenhuma chave existente muda. Guarda uma
/// StringList `tema|nivel|texto`, mais recentes primeiro, com teto.
class CacaRecentes {
  static const chave = 'caca_recentes_v1';

  /// Teto de entradas guardadas (folga para 18 combos x 2 rodadas).
  static const teto = 120;

  static String _chaveItem(Categoria tema, Nivel nivel, String texto) =>
      '${tema.name}|${nivel.name}|$texto';

  /// Recentes de um combo (textos, mais recentes primeiro, sem repetir).
  static Future<List<String>> carregar(Categoria tema, Nivel nivel) async {
    final prefs = await SharedPreferences.getInstance();
    final todas = prefs.getStringList(chave) ?? const <String>[];
    final prefixo = '${tema.name}|${nivel.name}|';
    final vistos = <String>{};
    return [
      for (final item in todas)
        if (item.startsWith(prefixo) &&
            vistos.add(item.substring(prefixo.length)))
          item.substring(prefixo.length),
    ];
  }

  /// Guarda as palavras da rodada na frente das recentes do combo (as
  /// antigas do mesmo combo saem; os outros combos ficam intactos).
  static Future<void> guardar(
      Categoria tema, Nivel nivel, List<String> textos) async {
    final prefs = await SharedPreferences.getInstance();
    final todas = prefs.getStringList(chave) ?? <String>[];
    final prefixo = '${tema.name}|${nivel.name}|';
    final unicos = <String>[];
    for (final t in textos) {
      final item = _chaveItem(tema, nivel, t);
      if (!unicos.contains(item)) unicos.add(item);
    }
    final novas = [
      ...unicos,
      ...todas.where((item) => !item.startsWith(prefixo)),
    ];
    await prefs.setStringList(chave, novas.take(teto).toList());
  }
}

/// Filtra as candidatas tirando as recentes; se sobrar menos que [n], libera
/// as mais antigas primeiro até completar [n] (ou acabarem as candidatas).
/// Função pura (testável sem SharedPreferences).
List<Palavra> aplicarRecentes(
    List<Palavra> candidatas, List<String> recentes, int n) {
  final recentesSet = recentes.toSet();
  final novas = candidatas.where((p) => !recentesSet.contains(p.texto));
  if (novas.length >= n) return novas.toList();
  // Libera as mais antigas primeiro (recentes está em ordem: fim = antiga).
  final liberadas = <Palavra>[...novas];
  for (var i = recentes.length - 1;
      i >= 0 && liberadas.length < n;
      i--) {
    final texto = recentes[i];
    if (liberadas.any((p) => p.texto == texto)) continue;
    for (final p in candidatas) {
      if (p.texto == texto) {
        liberadas.add(p);
        break;
      }
    }
  }
  return liberadas;
}
