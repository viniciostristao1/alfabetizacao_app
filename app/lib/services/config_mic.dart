import 'package:shared_preferences/shared_preferences.dart';

import 'reconhecimento.dart' show kTolerancia;

/// Configuração do **Modo Microfone** (escolhida nas Configurações, pelo pai/mãe).
/// Local (shared_preferences).
///
/// - **[ativado]**: mostra ou não o botão 🎤 na tela das palavras. Padrão = LIGADO.
/// - **[tolerancia]**: o "ajuste fino" de quanto o app perdoa a pronúncia
///   (0 = exato, 1 = tolerante, 2 = bem tolerante). Padrão = [kTolerancia] (1).
///   Voz de criança erra mais — dá pra afrouxar aqui sem recompilar.
class ConfigMic {
  static const _chaveAtivado = 'mic_ativado_v1';
  static const _chaveTolerancia = 'mic_tolerancia_v1';

  /// Tolerância máxima aceita no seletor (0..[maxTolerancia]).
  static const maxTolerancia = 2;

  static Future<bool> ativado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_chaveAtivado) ?? true; // padrão LIGADO
  }

  static Future<void> salvarAtivado(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chaveAtivado, valor);
  }

  static Future<int> tolerancia() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_chaveTolerancia) ?? kTolerancia;
    return v.clamp(0, maxTolerancia);
  }

  static Future<void> salvarTolerancia(int valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveTolerancia, valor.clamp(0, maxTolerancia));
  }
}
