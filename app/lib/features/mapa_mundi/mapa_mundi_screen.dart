import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/habitat.dart';
import '../../services/banco_palavras.dart';
import '../../services/progresso_fases.dart';
import '../estudo/estudo_screen.dart';

/// Cor neon dos círculos/caminho das fases.
const _neon = Color(0xFF3DF5E4);

/// Mapa-múndi de FASES (PAISAGEM, tela cheia). O mapa é esticado pra encostar
/// nas laterais (`kMapaDisplayAspect`), com uma vinheta pra dar profundidade.
/// Cada habitat é um **disco 3D achatado com contorno neon** (uma "fase"):
/// toque num disco → abre as palavras daquele habitat; ao terminar (chegar na
/// última palavra), a fase é marcada como concluída — o disco **acende** e o
/// **caminho** até a próxima fase brilha. O progresso fica salvo
/// (`ProgressoFases`) — por isso os botões inferiores: **Voltar habitat** (volta
/// à lista/mapa de habitats) e **Reiniciar aventura** (apaga as luzes).
class MapaMundiScreen extends StatefulWidget {
  const MapaMundiScreen({super.key});

  @override
  State<MapaMundiScreen> createState() => _MapaMundiScreenState();
}

class _MapaMundiScreenState extends State<MapaMundiScreen> {
  static const _paisagem = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  Set<String> _concluidas = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(_paisagem);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _recarregar();
  }

  Future<void> _recarregar() async {
    final c = await ProgressoFases.carregar();
    if (mounted) setState(() => _concluidas = c);
  }

  Future<void> _abrirFase(Habitat h) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '${h.emoji}  Fase ${h.ordem} · ${h.rotulo}',
          palavras: palavrasDoHabitat(h.chave),
          manterPaisagemAoSair: true,
          habitatConcluivel: h.chave,
        ),
      ),
    );
    if (!mounted) return;
    SystemChrome.setPreferredOrientations(_paisagem);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _recarregar(); // acende o que foi concluído
  }

  Future<void> _reiniciarAventura() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reiniciar aventura?'),
        content: const Text(
          'Apaga o progresso das fases — as luzes voltam a apagar. '
          'As palavras continuam todas lá.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ProgressoFases.reiniciar();
    if (mounted) setState(() => _concluidas = {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAgua,
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final boxH = (w / kMapaDisplayAspect).clamp(0.0, c.maxHeight);
                final d = (w * 0.11).clamp(52.0, 104.0); // largura do disco
                final dh = d * 0.66; // bem achatado (impressão de "fase" 3D)
                return Center(
                  child: SizedBox(
                    width: w,
                    height: boxH,
                    child: Stack(
                      children: [
                        // mapa-múndi (arte com relevo/sombra/bichos), tela cheia
                        Positioned.fill(
                          child: Image.asset(
                            'assets/habitats/mapa_mundi.jpg',
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (_, _, _) =>
                                const ColoredBox(color: kAgua),
                          ),
                        ),
                        // caminho entre as fases (acende conforme conclui)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _CaminhoPainter(_concluidas),
                            ),
                          ),
                        ),
                        // discos das fases
                        for (final fase in Habitat.fases)
                          Positioned(
                            left: fase.fx * w - d / 2,
                            top: fase.fy * boxH - dh / 2,
                            width: d,
                            height: dh,
                            child: _DiscoFase(
                              emoji: fase.emoji,
                              concluida: _concluidas.contains(fase.chave),
                              onTap: () => _abrirFase(fase),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // botões inferiores translúcidos
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _BotaoTransparente(
                      icon: Icons.arrow_back_rounded,
                      texto: 'VOLTAR HABITAT',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 10),
                    _BotaoTransparente(
                      icon: Icons.refresh_rounded,
                      texto: 'REINICIAR AVENTURA',
                      onTap: _reiniciarAventura,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Desenha o caminho ligando as fases na ordem. O trecho fase[i]→fase[i+1]
/// "acende" (neon) quando a fase[i] está concluída; senão fica fraco.
class _CaminhoPainter extends CustomPainter {
  _CaminhoPainter(this.concluidas);
  final Set<String> concluidas;

  @override
  void paint(Canvas canvas, Size size) {
    final fases = Habitat.fases;
    Offset centro(Habitat f) => Offset(f.fx * size.width, f.fy * size.height);
    for (var i = 0; i < fases.length - 1; i++) {
      final a = centro(fases[i]);
      final b = centro(fases[i + 1]);
      final aceso = concluidas.contains(fases[i].chave);
      if (aceso) {
        // halo + linha sólida (pseudo-brilho, sem depender de MaskFilter)
        canvas.drawLine(
          a,
          b,
          Paint()
            ..color = _neon.withValues(alpha: 0.25)
            ..strokeWidth = 14
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          a,
          b,
          Paint()
            ..color = _neon
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round,
        );
      } else {
        canvas.drawLine(
          a,
          b,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.22)
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CaminhoPainter old) => old.concluidas != concluidas;
}

/// Disco de fase 3D **achatado** (elipse): gradiente radial pra dar volume,
/// brilho no topo (glossy), contorno neon e sombra embaixo (profundidade).
/// Concluída = aceso (neon) + estrelinha; pendente = escuro/apagado.
class _DiscoFase extends StatelessWidget {
  const _DiscoFase({
    required this.emoji,
    required this.concluida,
    required this.onTap,
  });

  final String emoji;
  final bool concluida;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // borderRadius grande num retângulo achatado => ELIPSE (disco achatado).
    const forma = BorderRadius.all(Radius.elliptical(200, 160));
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: forma,
          gradient: RadialGradient(
            center: const Alignment(-0.25, -0.6),
            radius: 1.15,
            colors: concluida
                ? const [Color(0xFFCAFFFB), _neon, Color(0xFF0B9488)]
                : const [Color(0xFF3C5C65), Color(0xFF1B3138), Color(0xFF0B171C)],
            stops: const [0.0, 0.55, 1.0],
          ),
          border: Border.all(
            color: concluida ? _neon : _neon.withValues(alpha: 0.55),
            width: concluida ? 3 : 2,
          ),
          boxShadow: [
            // sombra de profundidade (embaixo)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
            // brilho "fumacinha" no contorno — largo e difuso quando ACESO
            if (concluida) ...[
              BoxShadow(
                color: _neon.withValues(alpha: 0.55),
                blurRadius: 34,
                spreadRadius: 7,
              ),
              BoxShadow(
                color: _neon.withValues(alpha: 0.95),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ] else
              // apagado: só um contorno neon bem sutil
              BoxShadow(
                color: _neon.withValues(alpha: 0.28),
                blurRadius: 8,
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // reflexo/glossy no topo
            Align(
              alignment: const Alignment(0, -0.55),
              child: FractionallySizedBox(
                widthFactor: 0.72,
                heightFactor: 0.4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.elliptical(200, 140),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.55),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(emoji, style: const TextStyle(fontSize: 30)),
              ),
            ),
            if (concluida)
              const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 1, right: 1),
                  child: Icon(Icons.star_rounded,
                      color: Color(0xFFFFD54A), size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Botão translúcido (mesmo estilo dos nomes/habitats) — os botões inferiores.
class _BotaoTransparente extends StatelessWidget {
  const _BotaoTransparente({
    required this.icon,
    required this.texto,
    required this.onTap,
  });

  final IconData icon;
  final String texto;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
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
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
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
