import 'progresso_lista_concluidas.dart';

/// Progresso do quiz das posições (Futebol > Temas). Fase única: 'posicoes'.
/// Mesmo molde dos demais progressos de temas (lista de concluídas).
class ProgressoFutebolPosicoes {
  static const _loja =
      ProgressoListaConcluidas('fases_futebol_posicoes_concluidas_v1');

  static const fasePosicoes = 'posicoes';

  static Future<List<String>> carregar() => _loja.carregar();

  static Future<bool> get concluido async =>
      (await _loja.carregar()).contains(fasePosicoes);

  static Future<void> marcarConcluido() =>
      _loja.marcarConcluido(fasePosicoes);

  static Future<void> reiniciar() => _loja.reiniciar();
}
