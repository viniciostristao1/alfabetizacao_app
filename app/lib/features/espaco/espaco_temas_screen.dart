import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/espaco_tema.dart';
import '../../services/banco_palavras.dart';
import '../../services/progresso_espaco_temas_fases.dart';
import '../../services/progresso_repository.dart';
import '../../theme/app_colors.dart';
import '../colecao/colecao_espaco_screen.dart';
import '../estudo/estudo_screen.dart';

/// Temas do Espaço (PAISAGEM): foto do hangar com 4 círculos de fase em
/// zigue-zague (Planetas → Naves → Astros → Missão) + botões embaixo
/// (voltar, reiniciar, início, coleção, iniciar) — mesmo molde de Nomes.
class EspacoTemasScreen extends StatefulWidget {
  const EspacoTemasScreen({super.key});

  @override
  State<EspacoTemasScreen> createState() => _EspacoTemasScreenState();
}

class _EspacoTemasScreenState extends State<EspacoTemasScreen> {
  List<String> _concluidas = const [];
  int _moedas = 0;
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    _carregar();
    _carregarPontuacao();
  }

  Future<void> _carregar() async {
    final c = await ProgressoEspacoTemasFases.carregar();
    if (mounted) setState(() => _concluidas = c);
  }

  Future<void> _carregarPontuacao() async {
    final moedas = await ProgressoRepository.moedas();
    final xp = await ProgressoRepository.xp();
    if (mounted) setState(() { _moedas = moedas; _xp = xp; });
  }

  String? get _proximaChave {
    for (final t in EspacoTema.values) {
      if (!_concluidas.contains(t.chave)) return t.chave;
    }
    return null;
  }

  String get _rotuloIniciar {
    if (_concluidas.isEmpty) return 'INICIAR JOGO';
    if (_proximaChave != null) return 'CONTINUAR JOGO';
    return 'REINICIAR JOGO';
  }

  void _abrirTema(BuildContext context, EspacoTema tema) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '${tema.emoji}  ${tema.rotulo}',
          palavras: palavrasDoTemaEspaco(tema.chave),
          manterPaisagemAoSair: true,
          espacoTemaConcluivel: tema.chave,
          fundoImagem: 'assets/espaco/espaco_temas_foto.png',
        ),
      ),
    );
    if (mounted) { _carregar(); _carregarPontuacao(); }
  }

  Future<void> _reiniciarAventura(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reiniciar aventura?'),
        content: const Text('As fases do Espaço voltarão ao início. As palavras continuam todas lá.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reiniciar')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ProgressoEspacoTemasFases.reiniciar();
    if (mounted) setState(() => _concluidas = const []);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aventura reiniciada!')));
    }
  }

  Future<void> _abrirColecao(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ColecaoEspacoScreen()),
    );
    if (mounted) { _carregar(); _carregarPontuacao(); }
  }

  Future<void> _iniciarJogo(BuildContext context) async {
    final concluidas = await ProgressoEspacoTemasFases.carregar();
    final idx = EspacoTema.values.indexWhere((t) => !concluidas.contains(t.chave));
    final inicio = idx < 0 ? 0 : idx;
    final tema = EspacoTema.values[inicio];
    if (!context.mounted) return;
    _abrirTema(context, tema);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final h = c.maxHeight;
              final dW = math.max(w, h * kEspacoTemasFotoAspect);
              final dH = math.max(h, w / kEspacoTemasFotoAspect);
              final dx = (dW - w) / 2;
              final dy = (dH - h) / 2;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    left: -dx,
                    top: -dy,
                    width: dW,
                    height: dH,
                    child: Image.asset(
                      'assets/espaco/espaco_temas_foto.png',
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _CaminhoEspacoPainter(concluidas: _concluidas, dW: dW, dH: dH, dx: dx, dy: dy),
                      ),
                    ),
                  ),
                  for (final tema in EspacoTema.values)
                    Positioned(
                      left: _pos(tema, w, h, dW, dH, dx, dy).dx - 36,
                      top: _pos(tema, w, h, dW, dH, dx, dy).dy - 12,
                      width: 72,
                      height: 24,
                      child: _FaixaEspacoTema(
                        tema: tema,
                        isProximo: tema.chave == _proximaChave,
                        isConcluida: _concluidas.contains(tema.chave),
                        onTap: () => _abrirTema(context, tema),
                      ),
                    ),
                ],
              );
            },
          ),
          Positioned(
            top: 6,
            left: 6,
            child: SafeArea(
              child: Material(
                color: Colors.black.withValues(alpha: 0.45),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    '🪙 $_moedas · Nv ${ProgressoRepository.nivelDe(_xp)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ),
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
                      _BotaoEspaco(
                        icon: Icons.undo_rounded,
                        texto: 'VOLTAR ESPAÇO',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 10),
                      _BotaoEspaco(
                        icon: Icons.refresh_rounded,
                        texto: 'REINICIAR AVENTURA',
                        onTap: () => _reiniciarAventura(context),
                      ),
                      const SizedBox(width: 10),
                      _BotaoEspaco(
                        icon: Icons.home_rounded,
                        texto: 'VOLTAR INÍCIO',
                        onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                      ),
                      const SizedBox(width: 10),
                      _BotaoEspaco(
                        texto: 'COLEÇÃO',
                        emoji: '🚀',
                        onTap: () => _abrirColecao(context),
                      ),
                      const SizedBox(width: 10),
                      _BotaoEspaco(
                        icon: Icons.play_arrow_rounded,
                        texto: _rotuloIniciar,
                        fundo: Colors.white,
                        letra: AppColors.bg,
                        onTap: () => _iniciarJogo(context),
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

  /// 4 círculos em zigue-zague sobre a foto (esq→dir, alternando alto/baixo).
  Offset _pos(EspacoTema tema, double w, double h, double dW, double dH, double dx, double dy) {
    final idx = EspacoTema.values.indexOf(tema);
    const total = 4;
    final step = w / (total + 1);
    final x = step * (idx + 1);
    final y = h * (idx.isEven ? 0.62 : 0.40);
    return Offset(x, y);
  }
}

class _FaixaEspacoTema extends StatelessWidget {
  const _FaixaEspacoTema({required this.tema, required this.onTap, this.isProximo = false, this.isConcluida = false});

  final EspacoTema tema;
  final VoidCallback onTap;
  final bool isProximo;
  final bool isConcluida;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: tema.cor.withValues(alpha: 0.35),
        highlightColor: tema.cor.withValues(alpha: 0.15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const SizedBox.expand(),
            Center(child: _AnelEspaco(tema: tema, isProximo: isProximo, isConcluida: isConcluida)),
          ],
        ),
      ),
    );
  }
}

class _AnelEspaco extends StatefulWidget {
  const _AnelEspaco({required this.tema, this.isProximo = false, this.isConcluida = false});
  final EspacoTema tema;
  final bool isProximo;
  final bool isConcluida;

  @override
  State<_AnelEspaco> createState() => _AnelEspacoState();
}

class _AnelEspacoState extends State<_AnelEspaco> with SingleTickerProviderStateMixin {
  late final AnimationController _pulso;

  @override
  void initState() {
    super.initState();
    // Cria o controlador sempre (mesmo sem pulsar): evita inicializar o
    // `late final` no dispose, o que quebra em testes (elemento desativado).
    _pulso = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    if (widget.isProximo) _pulso.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _AnelEspaco oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isProximo && !oldWidget.isProximo) {
      _pulso.repeat(reverse: true);
    } else if (!widget.isProximo && oldWidget.isProximo) {
      _pulso.stop();
      _pulso.value = 0;
    }
  }

  @override
  void dispose() { _pulso.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!widget.isProximo) {
      return Container(
        width: 72,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.elliptical(360, 120)),
          gradient: RadialGradient(
            radius: 0.95,
            colors: widget.isConcluida
                ? [widget.tema.cor.withValues(alpha: 0.12), widget.tema.cor.withValues(alpha: 0.45)]
                : [Colors.white.withValues(alpha: 0.02), Colors.black.withValues(alpha: 0.28)],
          ),
          border: Border.all(color: widget.isConcluida ? widget.tema.cor : Colors.white.withValues(alpha: 0.5), width: widget.isConcluida ? 2.6 : 2.0),
          boxShadow: widget.isConcluida ? [BoxShadow(color: widget.tema.cor.withValues(alpha: 0.55), blurRadius: 14, spreadRadius: 1)] : null,
        ),
      );
    }
    return AnimatedBuilder(
      animation: _pulso,
      builder: (_, _) {
        final pulso = 0.5 + 0.5 * _pulso.value;
        return Container(
          width: 78,
          height: 26,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.elliptical(360, 120)),
            gradient: RadialGradient(radius: 0.95, colors: [widget.tema.cor.withValues(alpha: 0.08), widget.tema.cor.withValues(alpha: 0.38)], stops: const [0.35, 1.0]),
            border: Border.all(color: Color.lerp(Colors.white, widget.tema.cor, pulso)!, width: 2.2 + 1.2 * pulso),
            boxShadow: [
              BoxShadow(color: widget.tema.cor.withValues(alpha: 0.45), blurRadius: 14, spreadRadius: 1),
              BoxShadow(color: widget.tema.cor.withValues(alpha: 0.22 + 0.35 * pulso), blurRadius: 10 + 14 * pulso, spreadRadius: 1 + 2 * pulso),
            ],
          ),
        );
      },
    );
  }
}

class _CaminhoEspacoPainter extends CustomPainter {
  _CaminhoEspacoPainter({required this.concluidas, required this.dW, required this.dH, required this.dx, required this.dy});
  final List<String> concluidas;
  final double dW; final double dH; final double dx; final double dy;

  Offset _pos(EspacoTema t, double w, double h) {
    final idx = EspacoTema.values.indexOf(t);
    const total = 4;
    final step = w / (total + 1);
    final x = step * (idx + 1);
    final y = h * (idx.isEven ? 0.62 : 0.40);
    return Offset(x, y);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    for (var i = 0; i < EspacoTema.values.length - 1; i++) {
      final a = _pos(EspacoTema.values[i], w, h);
      final b = _pos(EspacoTema.values[i + 1], w, h);
      final aceso = concluidas.contains(EspacoTema.values[i].chave);
      if (aceso) {
        canvas.drawLine(a, b, Paint()..color = const Color(0xFF3DF5E4).withValues(alpha: 0.25)..strokeWidth = 14..strokeCap = StrokeCap.round);
        canvas.drawLine(a, b, Paint()..color = const Color(0xFF3DF5E4)..strokeWidth = 5..strokeCap = StrokeCap.round);
      } else {
        canvas.drawLine(a, b, Paint()..color = Colors.white.withValues(alpha: 0.22)..strokeWidth = 3..strokeCap = StrokeCap.round);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CaminhoEspacoPainter old) => old.concluidas != concluidas || old.dW != dW || old.dH != dH || old.dx != dx || old.dy != dy;
}

class _BotaoEspaco extends StatelessWidget {
  const _BotaoEspaco({required this.texto, required this.onTap, this.icon, this.emoji, this.fundo = const Color(0x8C000000), this.letra = Colors.white});
  final String texto; final VoidCallback onTap; final IconData? icon; final String? emoji; final Color fundo; final Color letra;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: fundo, borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22), onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white24)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) Icon(icon, color: letra, size: 18),
            if (emoji != null) Text(emoji!, style: TextStyle(fontSize: 16, color: letra)),
            if (icon != null || emoji != null) const SizedBox(width: 8),
            Text(texto, style: TextStyle(color: letra, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
          ]),
        ),
      ),
    );
  }
}
