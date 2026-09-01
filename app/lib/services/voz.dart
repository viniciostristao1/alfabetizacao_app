import 'dart:async';

import 'package:speech_to_text/speech_to_text.dart';

/// Entrada de voz (STT) — **ouve a criança falar** a palavra (Modo Microfone).
///
/// Espelha o padrão do [Fala] (`fala.dart`): instância única, tudo em
/// `try/catch` e **silencioso/seguro** se o microfone não estiver disponível
/// (emulador, sem permissão, aparelho sem reconhecedor). O reconhecedor é o do
/// próprio Android/Google — pode pedir internet.
///
/// A regra de "acertou ou não" NÃO mora aqui — fica em `reconhecimento.dart`
/// (lógica pura, testável). Aqui só capturamos o que foi dito.
///
/// **Contrato:** cada `ouvir()` chama `onResultado` **exatamente uma vez** com a
/// melhor transcrição (lista possivelmente **vazia** = não entendeu) e depois
/// `onFim` (sempre) para a tela reabilitar o botão.
class Voz {
  Voz._();

  static final Voz _instancia = Voz._();

  /// A instância única (use `Voz.instance.ouvir(...)`).
  static Voz get instance => _instancia;

  final SpeechToText _stt = SpeechToText();
  bool _initFeito = false;
  bool _disponivelCache = false;

  /// Locale pt detectado no aparelho (ex.: 'pt_BR'); `null` = usa o padrão do
  /// aparelho (evita recusar tudo se o id 'pt_BR' não bater no reconhecedor).
  String? _localeId;

  void Function(List<String> ditas)? _onResultado;
  void Function()? _onFim;
  List<String> _melhor = const [];
  bool _entregou = false;
  Timer? _timeout;

  bool get ouvindo => _stt.isListening;

  Future<bool> _init() async {
    if (_initFeito) return _disponivelCache;
    try {
      _disponivelCache = await _stt.initialize(
        onStatus: _aoStatus,
        onError: (_) => _concluir(), // no_match / timeout / rede → conclui
      );
      if (_disponivelCache) {
        _localeId = await _acharLocalePt();
      }
    } catch (_) {
      _disponivelCache = false;
    }
    _initFeito = true;
    return _disponivelCache;
  }

  /// Procura um locale de português no aparelho (prefere pt-BR). Devolve o id
  /// exato que o reconhecedor conhece, ou `null` para usar o padrão do aparelho.
  Future<String?> _acharLocalePt() async {
    try {
      final locales = await _stt.locales();
      String? fallbackPt;
      for (final l in locales) {
        final id = l.localeId.toLowerCase().replaceAll('-', '_');
        if (id == 'pt_br') return l.localeId; // melhor caso
        fallbackPt ??= id.startsWith('pt') ? l.localeId : null;
      }
      return fallbackPt;
    } catch (_) {
      return null;
    }
  }

  void _aoStatus(String status) {
    // IMPORTANTE: só concluir no 'done' — o 'notListening' dispara ANTES de o
    // texto chegar (o mic parou, mas o reconhecedor ainda vai transcrever).
    if (status == SpeechToText.doneStatus) _concluir();
  }

  /// Entrega o resultado (uma única vez) e avisa o fim. Chamado no resultado
  /// final, no status 'done', em erro e no timeout de segurança.
  void _concluir() {
    _timeout?.cancel();
    _timeout = null;
    if (!_entregou) {
      _entregou = true;
      _onResultado?.call(_melhor);
    }
    final fim = _onFim;
    _onFim = null;
    _onResultado = null;
    fim?.call();
  }

  /// Inicializa (pede permissão de microfone na 1ª vez) e diz se dá pra ouvir.
  Future<bool> disponivel() => _init();

  /// Começa a ouvir. Ao concluir, chama [onResultado] com as transcrições
  /// (principal + alternativas do motor; **vazia** se não entendeu) e depois
  /// [onFim].
  /// Converte o nível de som do reconhecedor (Android ≈ dB, ~-2..10) para 0..1,
  /// pra tela mostrar uma barrinha de "estou te ouvindo".
  double _normalizarNivel(double level) => ((level + 2) / 12).clamp(0.0, 1.0);

  Future<void> ouvir({
    required void Function(List<String> ditas) onResultado,
    required void Function() onFim,
    void Function(double nivel)? onNivel,
  }) async {
    if (!await _init()) {
      onResultado(const []);
      onFim();
      return;
    }
    _onResultado = onResultado;
    _onFim = onFim;
    _melhor = const [];
    _entregou = false;
    try {
      await _stt.listen(
        onResult: (resultado) {
          final ditas = <String>[
            resultado.recognizedWords,
            for (final alt in resultado.alternates) alt.recognizedWords,
          ]..removeWhere((s) => s.trim().isEmpty);
          if (ditas.isNotEmpty) _melhor = ditas; // guarda a melhor até agora
          if (resultado.finalResult) _concluir();
        },
        onSoundLevelChange:
            onNivel == null ? null : (l) => onNivel(_normalizarNivel(l)),
        listenOptions: SpeechListenOptions(
          localeId: _localeId,
          partialResults: true, // mais robusto no Android que 'false'
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
          listenFor: const Duration(seconds: 12), // janela maior (fala devagar)
          pauseFor: const Duration(seconds: 4), // mais paciente com o silêncio
        ),
      );
      // rede de segurança: se nenhum evento concluir, encerra sozinho.
      _timeout?.cancel();
      _timeout = Timer(const Duration(seconds: 18), _concluir);
    } catch (_) {
      _concluir();
    }
  }

  /// Para de ouvir agora (ex.: a criança saiu da tela).
  Future<void> parar() async {
    _timeout?.cancel();
    _timeout = null;
    try {
      await _stt.stop();
    } catch (_) {
      // já parado / indisponível — segue seguro.
    }
  }
}
