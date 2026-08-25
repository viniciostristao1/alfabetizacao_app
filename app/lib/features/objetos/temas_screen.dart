import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/tema.dart';
import '../../services/banco_palavras.dart';
import '../../services/progresso_objetos_temas_fases.dart';
import '../../services/progresso_repository.dart';
import '../../theme/app_colors.dart';
import '../colecao/colecao_objetos_screen.dart';
import '../estudo/estudo_screen.dart';

class TemasScreen extends StatefulWidget {
  const TemasScreen({super.key});

  @override
  State<TemasScreen> createState() => _TemasScreenState();
}

class _TemasScreenState extends State<TemasScreen> {
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
    final c = await ProgressoObjetosTemasFases.carregar();
    if (mounted) setState(() => _concluidas = c);
  }

  Future<void> _carregarPontuacao() async {
    final moedas = await ProgressoRepository.moedas();
    final xp = await ProgressoRepository.xp();
    if (mounted) setState(() { _moedas = moedas; _xp = xp; });
  }

  String? get _proximaChave {
    for (final t in Tema.values) {
      if (!_concluidas.contains(t.chave)) return t.chave;
    }
    return null;
  }

  String get _rotuloIniciar {
    if (_concluidas.isEmpty) return 'INICIAR JOGO';
    if (_proximaChave != null) return 'CONTINUAR JOGO';
    return 'REINICIAR JOGO';
  }

  void _abrirTema(BuildContext context, Tema tema) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '${tema.emoji}  ${tema.rotulo}',
          palavras: palavrasDoTema(tema.chave),
          manterPaisagemAoSair: true,
          objetosTemaConcluivel: tema.chave,
        ),
      ),
    );
    if (mounted) { _carregar(); _carregarPontuacao(); }
  }

  Future<void> _abrirColecao(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ColecaoObjetosScreen()),
    );
    if (mounted) { _carregar(); _carregarPontuacao(); }
  }

  Future<void> _reiniciarAventura(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reiniciar aventura?'),
        content: const Text('As fases voltarão ao início. As palavras continuam todas lá.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reiniciar')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ProgressoObjetosTemasFases.reiniciar();
    if (mounted) setState(() => _concluidas = const []);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aventura reiniciada!')));
    }
  }

  Future<void> _iniciarJogo(BuildContext context) async {
    final concluidas = await ProgressoObjetosTemasFases.carregar();
    final idx = Tema.values.indexWhere((t) => !concluidas.contains(t.chave));
    final inicio = idx < 0 ? 0 : idx;
    final tema = Tema.values[inicio];
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
              final dW = math.max(w, h * kTemasFotoAspect);
              final dH = math.max(h, w / kTemasFotoAspect);
              final dx = (dW - w) / 2;
              final dy = (dH - h) / 2;
              final zona = dW / Tema.values.length;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    left: -dx,
                    top: -dy,
                    width: dW,
                    height: dH,
                    child: Image.asset(
                      'assets/objetos/objetos_temas_foto.png',
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _CaminhoObjetosPainter(concluidas: _concluidas, dW: dW, dH: dH, dx: dx, dy: dy, zona: zona),
                      ),
                    ),
                  ),
                  for (final (i, tema) in Tema.values.indexed)
                    Positioned(
                      left: (i + 0.5) * zona - dx - zona / 2,
                      width: zona,
                      top: 0,
                      bottom: 0,
                      child: _FaixaTema(
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
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
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
                      _BotaoObjetos(
                        icon: Icons.undo_rounded,
                        texto: 'VOLTAR OBJETOS',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 10),
                      _BotaoObjetos(
                        icon: Icons.refresh_rounded,
                        texto: 'REINICIAR AVENTURA',
                        onTap: () => _reiniciarAventura(context),
                      ),
                      const SizedBox(width: 10),
                      _BotaoObjetos(
                        icon: Icons.home_rounded,
                        texto: 'VOLTAR INÍCIO',
                        onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                      ),
                      const SizedBox(width: 10),
                      _BotaoObjetos(
                        texto: 'COLEÇÃO',
                        emoji: '🧸',
                        onTap: () => _abrirColecao(context),
                      ),
                      const SizedBox(width: 10),
                      _BotaoObjetos(
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
}

class _FaixaTema extends StatelessWidget {
  const _FaixaTema({required this.tema, required this.onTap, this.isProximo = false, this.isConcluida = false});

  final Tema tema;
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
            Center(child: _AnelTema(tema: tema, isProximo: isProximo, isConcluida: isConcluida)),
          ],
        ),
      ),
    );
  }
}

class _AnelTema extends StatefulWidget {
  const _AnelTema({required this.tema, this.isProximo = false, this.isConcluida = false});
  final Tema tema;
  final bool isProximo;
  final bool isConcluida;

  @override
  State<_AnelTema> createState() => _AnelTemaState();
}

class _AnelTemaState extends State<_AnelTema> with SingleTickerProviderStateMixin {
  late final AnimationController _pulso = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    if (widget.isProximo) {
      _pulso.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _AnelTema oldWidget) {
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
        width: 72, height: 24,
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
          width: 78, height: 26,
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

class _CaminhoObjetosPainter extends CustomPainter {
  _CaminhoObjetosPainter({required this.concluidas, required this.dW, required this.dH, required this.dx, required this.dy, required this.zona});
  final List<String> concluidas;
  final double dW; final double dH; final double dx; final double dy; final double zona;
  @override
  void paint(Canvas canvas, Size size) {
    final fases = Tema.values;
    for (var i = 0; i < fases.length - 1; i++) {
      final ax = (i + 0.5) * zona - dx + zona / 2;
      final ay = size.height / 2;
      final bx = (i + 1 + 0.5) * zona - dx + zona / 2;
      final by = size.height / 2;
      final a = Offset(ax, ay);
      final b = Offset(bx, by);
      final aceso = concluidas.contains(fases[i].chave);
      if (aceso) {
        canvas.drawLine(a, b, Paint()..color = const Color(0xFF3DF5E4).withValues(alpha: 0.25)..strokeWidth = 14..strokeCap = StrokeCap.round);
        canvas.drawLine(a, b, Paint()..color = const Color(0xFF3DF5E4)..strokeWidth = 5..strokeCap = StrokeCap.round);
      } else {
        canvas.drawLine(a, b, Paint()..color = Colors.white.withValues(alpha: 0.22)..strokeWidth = 3..strokeCap = StrokeCap.round);
      }
    }
  }
  @override
  bool shouldRepaint(covariant _CaminhoObjetosPainter oldDelegate) => oldDelegate.concluidas != concluidas || oldDelegate.dW != dW || oldDelegate.dH != dH || oldDelegate.dx != dx || oldDelegate.dy != dy;
}

class _BotaoObjetos extends StatelessWidget {
  const _BotaoObjetos({required this.texto, required this.onTap, this.icon, this.emoji, this.fundo = const Color(0x8C000000), this.letra = Colors.white});
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
