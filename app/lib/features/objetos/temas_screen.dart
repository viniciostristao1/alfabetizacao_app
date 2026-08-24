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
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Temas'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final h = c.maxHeight;
            // Cover: a imagem (aspecto kTemasFotoAspect) cresce até cobrir a
            // tela toda — o que passa da borda é cortado (dx/dy de cada lado).
            final dW = math.max(w, h * kTemasFotoAspect);
            final dH = math.max(h, w / kTemasFotoAspect);
            final dx = (dW - w) / 2;
            final dy = (dH - h) / 2;
            // Cada palavra ocupa 1/5 da largura da IMAGEM — a faixa acompanha.
            final zona = dW / Tema.values.length;
            return Stack(
              fit: StackFit.expand,
              children: [
                // A imagem posicionada manualmente (esquerda = -dx) — a mesma
                // matemática do BoxFit.cover, sem depender do renderizador.
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
      ),
    );
  }
}

/// Faixa invisível sobre a palavra da foto — só o toque.
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
        child: const SizedBox.expand(),
      ),
    );
  }
}
