import 'package:speech_to_text/speech_to_text.dart';

/// Entrada de voz (STT) — **ouve a criança falar** a palavra (Modo Microfone).
///
/// Espelha o padrão do [Fala] (`fala.dart`): instância única, tudo em
/// `try/catch` e **silencioso/seguro** se o microfone não estiver disponível
/// (emulador, sem permissão, aparelho sem reconhecedor). O reconhecedor é o do
/// próprio Android/Google (pt-BR) — pode pedir internet.
///
/// A regra de "acertou ou não" NÃO mora aqui — fica em `reconhecimento.dart`
/// (lógica pura, testável). Aqui só capturamos o que foi dito.
class Voz {
  Voz._();

  static final Voz _instancia = Voz._();

  /// A instância única (use `Voz.instance.ouvir(...)`).
  static Voz get instance => _instancia;

  final SpeechToText _stt = SpeechToText();
  bool _initFeito = false;
  bool _disponivelCache = false;

  /// Chamado quando o reconhecedor para de ouvir (silêncio, timeout ou erro) —
  /// a tela usa para reabilitar o botão e, se nada veio, mostrar "não entendi".
  void Function()? _onFim;

  bool get ouvindo => _stt.isListening;

  Future<bool> _init() async {
    if (_initFeito) return _disponivelCache;
    try {
      _disponivelCache = await _stt.initialize(
        onStatus: (status) {
          if (status == SpeechToText.doneStatus ||
              status == SpeechToText.notListeningStatus) {
            _dispararFim();
          }
        },
        onError: (_) => _dispararFim(),
      );
    } catch (_) {
      _disponivelCache = false;
    }
    _initFeito = true;
    return _disponivelCache;
  }

  void _dispararFim() {
    final cb = _onFim;
    _onFim = null;
    cb?.call();
  }

  /// Inicializa (pede permissão de microfone na 1ª vez) e diz se dá pra ouvir.
  Future<bool> disponivel() => _init();

  /// Começa a ouvir. Ao ter um resultado final, chama [onResultado] com as
  /// transcrições (a principal + as alternativas do motor). Ao parar de ouvir,
  /// chama [onFim] (sempre — mesmo sem entender nada).
  Future<void> ouvir({
    required void Function(List<String> ditas) onResultado,
    required void Function() onFim,
  }) async {
    if (!await _init()) {
      onFim();
      return;
    }
    _onFim = onFim;
    try {
      await _stt.listen(
        listenOptions: SpeechListenOptions(
          localeId: 'pt_BR',
          partialResults: false,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
          listenFor: const Duration(seconds: 6),
          pauseFor: const Duration(seconds: 3),
        ),
        onResult: (resultado) {
          if (!resultado.finalResult) return;
          onResultado([
            resultado.recognizedWords,
            for (final alt in resultado.alternates) alt.recognizedWords,
          ]);
        },
      );
    } catch (_) {
      _dispararFim();
    }
  }

  /// Para de ouvir agora (ex.: a criança saiu da tela).
  Future<void> parar() async {
    try {
      await _stt.stop();
    } catch (_) {
      // já parado / indisponível — segue seguro.
    }
  }
}
