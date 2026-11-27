import 'package:shared_preferences/shared_preferences.dart';

/// Molde genérico das listas de concluídas (fases, temas, posições): guarda
/// como lista ORDENADA de chaves sob UMA chave do shared_preferences,
/// idempotente, com desfazer-última e reiniciar. As seis classes
/// `progresso_*` viraram fachadas finas sobre esta classe, com as chaves
/// byte a byte iguais às antigas (o progresso salvo do Davi intacto).
class ProgressoListaConcluidas {
  const ProgressoListaConcluidas(this.chave);

  final String chave;

  Future<List<String>> carregar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(chave) ?? const <String>[];
  }

  Future<void> marcarConcluido(String item) async {
    final prefs = await SharedPreferences.getInstance();
    final atuais = prefs.getStringList(chave) ?? const <String>[];
    if (atuais.contains(item)) return;
    await prefs.setStringList(chave, [...atuais, item]);
  }

  Future<List<String>> voltarUltima() async {
    final prefs = await SharedPreferences.getInstance();
    final atuais = prefs.getStringList(chave) ?? const <String>[];
    if (atuais.isEmpty) return const <String>[];
    final restantes = atuais.sublist(0, atuais.length - 1);
    await prefs.setStringList(chave, restantes);
    return restantes;
  }

  Future<void> reiniciar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(chave);
  }
}
