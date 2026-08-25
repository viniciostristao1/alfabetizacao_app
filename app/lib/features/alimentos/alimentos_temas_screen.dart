import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/alimentos_tema.dart';
import '../../services/banco_palavras.dart';
import '../estudo/estudo_screen.dart';

class AlimentosTemasScreen extends StatelessWidget {
  const AlimentosTemasScreen({super.key});

  void _abrirTema(BuildContext context, AlimentosTema tema) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '${tema.emoji}  ${tema.rotulo}',
          palavras: palavrasDoTema(tema.chave),
        ),
      ),
    );
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
              final dW = math.max(w, h * kAlimentosTemasFotoAspect);
              final dH = math.max(h, w / kAlimentosTemasFotoAspect);
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
                      'assets/alimentos/alimentos_temas_foto.png',
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
                    ),
                  ),
                  for (final tema in AlimentosTema.values)
                    Positioned(
                      left: _rect(tema).left * dW - dx,
                      top: _rect(tema).top * dH - dy,
                      width: _rect(tema).width * dW,
                      height: _rect(tema).height * dH,
                      child: _FaixaAlimentosTema(
                        tema: tema,
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
        ],
      ),
    );
  }

  Rect _rect(AlimentosTema t) {
    switch (t) {
      case AlimentosTema.mercado:
        return const Rect.fromLTWH(0.30, 0.30, 0.38, 0.42);
      case AlimentosTema.pomar:
        return const Rect.fromLTWH(0.00, 0.00, 0.30, 0.48);
      case AlimentosTema.horta:
        return const Rect.fromLTWH(0.55, 0.58, 0.45, 0.42);
      case AlimentosTema.roca:
        return const Rect.fromLTWH(0.62, 0.00, 0.38, 0.48);
      case AlimentosTema.arrozal:
        return const Rect.fromLTWH(0.00, 0.52, 0.32, 0.48);
    }
  }
}

class _FaixaAlimentosTema extends StatelessWidget {
  const _FaixaAlimentosTema({required this.tema, required this.onTap});

  final AlimentosTema tema;
  final VoidCallback onTap;

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
            Center(child: _AnelAlimentos(tema: tema)),
          ],
        ),
      ),
    );
  }
}

class _AnelAlimentos extends StatefulWidget {
  const _AnelAlimentos({required this.tema});
  final AlimentosTema tema;

  @override
  State<_AnelAlimentos> createState() => _AnelAlimentosState();
}

class _AnelAlimentosState extends State<_AnelAlimentos>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulso = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _pulso.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulso,
      builder: (_, _) {
        final pulso = 0.5 + 0.5 * _pulso.value;
        return Container(
          width: 78,
          height: 26,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.elliptical(360, 120)),
            gradient: RadialGradient(
              radius: 0.95,
              colors: [
                widget.tema.cor.withValues(alpha: 0.08),
                widget.tema.cor.withValues(alpha: 0.38),
              ],
              stops: const [0.35, 1.0],
            ),
            border: Border.all(
              color: Color.lerp(Colors.white, widget.tema.cor, pulso)!,
              width: 2.2 + 1.2 * pulso,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.tema.cor.withValues(alpha: 0.45),
                blurRadius: 14,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: widget.tema.cor.withValues(alpha: 0.22 + 0.35 * pulso),
                blurRadius: 10 + 14 * pulso,
                spreadRadius: 1 + 2 * pulso,
              ),
            ],
          ),
        );
      },
    );
  }
}
