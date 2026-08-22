import 'package:flutter_tts/flutter_tts.dart';

import 'config_fala.dart';

/// Voz do celular (TTS) — fala as palavras em voz alta, em português (pt-BR).
/// Única instância (inicializar o TTS é caro). Silencioso se o TTS não
/// estiver disponível (emulador, aparelho sem voz) ou se o pai/mãe desligou
/// o "Falar a palavra" nas Configurações.
class Fala {
  Fala._();

  static final Fala _instancia = Fala._();

  /// A instância única (use `Fala.instance.falar('gato')`).
  static Fala get instance => _instancia;

  final FlutterTts _tts = FlutterTts();
  bool _pronta = false;

  /// Fala [texto] em voz alta (se ativado e disponível). Não espera terminar.
  Future<void> falar(String texto) async {
    if (!await ConfigFala.ativado()) return;
    try {
      if (!_pronta) {
        await _tts.setLanguage('pt-BR');
        await _tts.setSpeechRate(0.45);
        await _tts.setPitch(1.0);
        await _tts.awaitSpeakCompletion(true);
        _pronta = true;
      }
      await _tts.stop();
      await _tts.speak(texto);
    } catch (_) {
      // TTS indisponível — a criança segue lendo sozinha, sem erro.
    }
  }
}
