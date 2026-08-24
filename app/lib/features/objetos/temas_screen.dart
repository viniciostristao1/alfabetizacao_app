import 'package:flutter/material.dart';

import '../../models/tema.dart';
import '../../services/banco_palavras.dart';
import '../estudo/estudo_screen.dart';

/// Tela de TEMAS: a foto `assets/objetos/objetos_temas_foto.png` aparece
/// inteira (sem cortar) e tem **5 faixas clicáveis** — uma para cada palavra da
/// foto (casa, museu, escola, cafeteria, bombeiros), da esquerda para a direita,
/// em colunas iguais. A imagem já tem a descrição de cada lugar, então as faixas
/// são invisíveis. Tocar numa faixa abre o estudo das palavras do tema.
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
            // Imagem inteira, na proporção nativa, preenchendo a largura (e só a
            // altura que ela ocupa) — as faixas ficam exatamente sobre a arte.
            final boxH = (w / kTemasFotoAspect).clamp(0.0, c.maxHeight);
            return Center(
              child: SizedBox(
                width: w,
                height: boxH,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/objetos/objetos_temas_foto.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: Colors.black),
                    ),
                    Row(
                      children: [
                        for (final tema in Tema.values)
                          Expanded(
                            child: _FaixaTema(
                              tema: tema,
                              onTap: () => _abrirTema(context, tema),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
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
