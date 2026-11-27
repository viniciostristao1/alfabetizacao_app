import 'progresso_lista_concluidas.dart';

class ProgressoAlimentosFases {
  static const _loja =
      ProgressoListaConcluidas('fases_alimentos_concluidas_v1');

  static Future<List<String>> carregar() => _loja.carregar();

  static Future<void> marcarConcluido(String chave) =>
      _loja.marcarConcluido(chave);

  static Future<List<String>> voltarUltima() => _loja.voltarUltima();

  static Future<void> reiniciar() => _loja.reiniciar();
}
