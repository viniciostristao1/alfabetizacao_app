import 'progresso_lista_concluidas.dart';

class ProgressoEspacoTemasFases {
  static const _loja =
      ProgressoListaConcluidas('fases_espaco_concluidas_v1');

  static Future<List<String>> carregar() => _loja.carregar();

  static Future<void> marcarConcluido(String chave) =>
      _loja.marcarConcluido(chave);

  static Future<List<String>> voltarUltima() => _loja.voltarUltima();

  static Future<void> reiniciar() => _loja.reiniciar();
}
