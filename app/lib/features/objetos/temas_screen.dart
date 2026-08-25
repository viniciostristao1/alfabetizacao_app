import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/tema.dart';
import '../../services/banco_palavras.dart';
import '../estudo/estudo_screen.dart';

/// Tela de TEMAS: a foto `assets/objetos/objetos_temas_foto.png` preenche a
/// tela inteira (modo "cover": corta só o que sobra do cenário em cima/embaixo,
/// as palavras do meio ficam visíveis) e tem **5 faixas clicáveis** — uma para
/// cada palavra da foto (casa, museu, escola, cafeteria, bombeiros), da
/// esquerda para a direita. A imagem já tem a descrição de cada lugar, então as
/// faixas são invisíveis. Tocar numa faixa abre o estudo das palavras do tema.
///
/// As faixas acompanham a imagem "esticada": cada palavra está no centro de uma
/// das 5 colunas iguais da foto; o botão fica exatamente na posição que a
/// coluna ocupa depois do corte (`dx`/`dy` da matemática do cover).
class TemasScreen extends StatelessWidget {
  const TemasScreen({super.key});

  void _abrirTema(BuildContext context, Tema tema) {
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
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: Colors.black),
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
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
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
  const _FaixaTema({required this.tema, required this.onTap});

  final Tema tema;
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
            Center(child: _AnelTema(tema: tema)),
          ],
        ),
      ),
    );
  }
}

class _AnelTema extends StatefulWidget {
  const _AnelTema({required this.tema});
  final Tema tema;

  @override
  State<_AnelTema> createState() => _AnelTemaState();
}

class _AnelTemaState extends State<_AnelTema>
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
