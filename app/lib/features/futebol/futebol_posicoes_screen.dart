import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/futebol_posicao.dart';
import '../../services/fala.dart';
import '../../services/progresso_futebol_posicoes.dart';
import '../../services/progresso_repository.dart';
import '../../theme/app_colors.dart';
import '../estudo/confete.dart';

/// Quiz das posições (jogo do Davi — Futebol > Temas, PAISAGEM): a foto do
/// vestiário com a lousa tática aparece INTEIRA (contain, sem corte — o
/// `cover` cortava o topo e escondia o pino do atacante) e a criança TOCA o
/// ponto certo do campo.
///
/// - Topo (faixa compacta, fora da foto): pergunta gigante "ONDE FICA O …?" +
///   🔊 (o app também FALA a pergunta, pois a criança ainda está aprendendo
///   a ler). O retorno ("Muito bem! 🎉" / "Tenta de novo! 💪") aparece nessa
///   mesma faixa — nunca em cima dos pinos.
/// - Acerto: confete + moeda(s) + o app fala a palavra; erro nunca tira
///   moeda e nunca trava — com 3 erros o ponto certo pisca dourado (dica).
/// - Fim: bônus de fase (baú) + troféu "🏆 Time do Davi".
///
/// Força paisagem ao abrir e restaura retrato ao sair (molde da EstudoScreen).
class FutebolPosicoesScreen extends StatefulWidget {
  const FutebolPosicoesScreen({super.key});

  @override
  State<FutebolPosicoesScreen> createState() => _FutebolPosicoesScreenState();
}

class _FutebolPosicoesScreenState extends State<FutebolPosicoesScreen> {
  static const _assetCampo = 'assets/futebol/futebol_campo.png';

  /// Erros antes de o ponto certo piscar dourado (dica).
  static const _maxErrosSemDica = 3;

  int _idx = 0;
  int _errosNoItem = 0;
  int _dePrimeira = 0;
  int _moedas = 0;
  int _xp = 0;
  int _confeteSeq = 0;
  int _geracao = 0;

  int? _pinoCerto; // índice em kPinosCampo (fica verde até avançar)
  int? _pinoErrado; // índice em kPinosCampo (pisca vermelho ~600ms)
  bool _dicaAtiva = false;
  bool _travado = false;
  bool _fim = false;
  String? _feedback; // "Muito bem! 🎉" / "Tenta de novo! 💪" / null

  String get _atual => kOrdemPosicoes[_idx];

  String _emojiDe(String palavra) => switch (palavra) {
        'goleiro' => '🧤',
        'zagueiro' => '🧱',
        'lateral' => '🏃',
        'volante' => '🛡️',
        'meia' => '🎯',
        'atacante' => '⚽',
        _ => '⚽',
      };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _carregarPontuacao();
    WidgetsBinding.instance.addPostFrameCallback((_) => _falarPergunta());
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _carregarPontuacao() async {
    final moedas = await ProgressoRepository.moedas();
    final xp = await ProgressoRepository.xp();
    if (mounted) {
      setState(() {
        _moedas = moedas;
        _xp = xp;
      });
    }
  }

  Future<void> _falarPergunta() async {
    if (!mounted || _fim) return;
    await Fala.instance.falar('Onde fica o $_atual? Toca lá no campo!');
  }

  Future<void> _tocarPino(int i) async {
    if (_travado || _fim || _pinoCerto != null) return;
    final pino = kPinosCampo[i];
    if (pino.palavra == _atual) {
      final geracao = _geracao;
      final dePrimeira = _errosNoItem == 0 && !_dicaAtiva;
      final pontos = _dicaAtiva ? 0 : (dePrimeira ? 2 : 1);
      setState(() {
        _travado = true;
        _pinoCerto = i;
        _pinoErrado = null;
        _feedback = 'Muito bem! 🎉';
        _confeteSeq++;
        if (dePrimeira) _dePrimeira++;
      });
      if (pontos > 0) await ProgressoRepository.registrarAcerto(pontos);
      await _carregarPontuacao();
      await Fala.instance.falar('Muito bem! $_atual!');
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted || geracao != _geracao || _fim) return;
      _proximo();
    } else {
      final geracao = _geracao;
      setState(() {
        _errosNoItem++;
        _pinoErrado = i;
        _feedback = 'Tenta de novo! 💪';
      });
      final chegouNaDica = _errosNoItem >= _maxErrosSemDica && !_dicaAtiva;
      if (chegouNaDica) {
        setState(() => _dicaAtiva = true);
        await Fala.instance
            .falar('Olha o ponto dourado! É o $_atual! Toca nele!');
      }
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted || geracao != _geracao || _fim) return;
      setState(() {
        _pinoErrado = null;
        if (!chegouNaDica) _feedback = null;
      });
    }
  }

  void _proximo() {
    if (_idx + 1 >= kOrdemPosicoes.length) {
      _concluir();
      return;
    }
    setState(() {
      _idx++;
      _errosNoItem = 0;
      _pinoCerto = null;
      _pinoErrado = null;
      _dicaAtiva = false;
      _travado = false;
      _feedback = null;
    });
    _falarPergunta();
  }

  Future<void> _concluir() async {
    setState(() {
      _fim = true;
      _travado = false;
      _feedback = null;
    });
    await ProgressoRepository.registrarBonusFase(); // baú: 25 XP + 10 moedas
    await ProgressoFutebolPosicoes.marcarConcluido();
    await _carregarPontuacao();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TrofeuDaviDialog(
        dePrimeira: _dePrimeira,
        total: kOrdemPosicoes.length,
        onJogarDeNovo: () {
          Navigator.of(context).pop();
          _reiniciar();
        },
      ),
    );
  }

  void _reiniciar() {
    setState(() {
      _geracao++;
      _idx = 0;
      _errosNoItem = 0;
      _dePrimeira = 0;
      _pinoCerto = null;
      _pinoErrado = null;
      _dicaAtiva = false;
      _travado = false;
      _fim = false;
      _feedback = null;
    });
    _falarPergunta();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              // ── faixa da pergunta (compacta, FORA da foto) ──
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).pop(),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.arrow_back_rounded,
                                color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.62),
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: Colors.white24, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'ONDE FICA?',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    Text(
                                      '${_emojiDe(_atual)}  ${_atual.toUpperCase()}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      _feedback ??
                                          '${_idx + 1} de ${kOrdemPosicoes.length} · 🪙 $_moedas · Nv ${ProgressoRepository.nivelDe(_xp)}',
                                      style: TextStyle(
                                        color: _feedback != null
                                            ? const Color(0xFFFFD54F)
                                            : Colors.white60,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Material(
                                color: AppColors.accent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _falarPergunta,
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Icon(Icons.volume_up_rounded,
                                        color: Colors.white, size: 24),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ── foto INTEIRA (contain: nada cortado, pinos sempre visíveis) ──
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final h = c.maxHeight;
                    // contain: a foto inteira cabe na zona, sem cortar nada.
                    var dispW = w;
                    var dispH = w / kFutebolCampoAspect;
                    if (dispH > h) {
                      dispH = h;
                      dispW = h * kFutebolCampoAspect;
                    }
                    final ox = (w - dispW) / 2;
                    final oy = (h - dispH) / 2;
                    return Stack(
                      children: [
                        Positioned(
                          left: ox,
                          top: oy,
                          width: dispW,
                          height: dispH,
                          child: Image.asset(
                            _assetCampo,
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (_, _, _) =>
                                const ColoredBox(color: Colors.black),
                          ),
                        ),
                        for (final (i, pino) in kPinosCampo.indexed)
                          Positioned(
                            left: ox + pino.fx * dispW - 32,
                            top: oy + pino.fy * dispH - 32,
                            width: 64,
                            height: 64,
                            child: _PinoCampo(
                              aceso: pino.palavra == _atual && !_fim,
                              certo: _pinoCerto == i,
                              errado: _pinoErrado == i,
                              dica: _dicaAtiva && pino.palavra == _atual,
                              onTap: () => _tocarPino(i),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          if (_confeteSeq > 0)
            Positioned.fill(
              child: ConfeteBurst(key: ValueKey(_confeteSeq)),
            ),
          // ── botões de baixo (sobre a mesa da foto, sem pinos) ──
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BotaoCampo(
                        icon: Icons.undo_rounded,
                        texto: 'VOLTAR FUTEBOL',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 10),
                      _BotaoCampo(
                        icon: Icons.refresh_rounded,
                        texto: 'REINICIAR JOGO',
                        onTap: _reiniciar,
                      ),
                      const SizedBox(width: 10),
                      _BotaoCampo(
                        icon: Icons.home_rounded,
                        texto: 'VOLTAR INÍCIO',
                        onTap: () =>
                            Navigator.of(context).popUntil((r) => r.isFirst),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// O ponto tocável sobre a lousa: anel azul (igual ao da lousa), verde no
/// acerto, vermelho no erro e dourado pulsante na dica (após 3 erros).
/// Caixa de toque 64×64 (anel visual 44): suficiente pro dedo da criança sem
/// roubar o toque do pino vizinho (pares do mesmo time aceitam qualquer um).
class _PinoCampo extends StatefulWidget {
  const _PinoCampo({
    required this.aceso,
    required this.certo,
    required this.errado,
    required this.dica,
    required this.onTap,
  });

  final bool aceso;
  final bool certo;
  final bool errado;
  final bool dica;
  final VoidCallback onTap;

  @override
  State<_PinoCampo> createState() => _PinoCampoState();
}

class _PinoCampoState extends State<_PinoCampo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulso;

  @override
  void initState() {
    super.initState();
    // Criado sempre (mesmo sem pulsar): `late final` inicializado só no
    // dispose quebra em elemento desativado (molde do Espaço/Nomes).
    _pulso = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.dica && !widget.certo) _pulso.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PinoCampo oldWidget) {
    super.didUpdateWidget(oldWidget);
    final devePulsar = widget.dica && !widget.certo;
    final pulsava = oldWidget.dica && !oldWidget.certo;
    if (devePulsar && !pulsava) {
      _pulso.repeat(reverse: true);
    } else if (!devePulsar && pulsava) {
      _pulso.stop();
      _pulso.value = 0;
    }
  }

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cor = widget.certo
        ? const Color(0xFF2E9D44)
        : widget.errado
            ? const Color(0xFFFF6B6B)
            : widget.dica
                ? const Color(0xFFF5A524)
                : widget.aceso
                    ? kCorPinoCampo
                    : kCorPinoCampo.withValues(alpha: 0.45);
    final corpo = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cor.withValues(alpha: 0.85),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 6,
            spreadRadius: 1,
          ),
          if (widget.certo || widget.dica)
            BoxShadow(
              color: cor.withValues(alpha: 0.7),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
      ),
      child: widget.certo
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
          : null,
    );
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: widget.onTap,
        child: SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: widget.dica && !widget.certo
                ? AnimatedBuilder(
                    animation: _pulso,
                    builder: (_, _) => Transform.scale(
                      scale: 1 + 0.18 * _pulso.value,
                      child: corpo,
                    ),
                  )
                : corpo,
          ),
        ),
      ),
    );
  }
}

class _BotaoCampo extends StatelessWidget {
  const _BotaoCampo({
    required this.texto,
    required this.onTap,
    this.icon,
  });

  final String texto;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x8C000000),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon, color: Colors.white, size: 18),
              if (icon != null) const SizedBox(width: 8),
              Text(
                texto,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Baú do fim do quiz: troféu "Time do Davi".
class _TrofeuDaviDialog extends StatelessWidget {
  const _TrofeuDaviDialog({
    required this.dePrimeira,
    required this.total,
    required this.onJogarDeNovo,
  });

  final int dePrimeira;
  final int total;
  final VoidCallback onJogarDeNovo;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🏆 Time do Davi!'),
      content: Text(
        'Você achou as $total posições do campo!\n'
        'De primeira: $dePrimeira de $total.\n'
        'Ganhou ${ProgressoRepository.bonusFase} moedas + 1 nível!',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          child: const Text('INÍCIO'),
        ),
        FilledButton(
          onPressed: onJogarDeNovo,
          child: const Text('JOGAR DE NOVO'),
        ),
      ],
    );
  }
}
