import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/habitat.dart';
import '../../services/banco_palavras.dart';
import '../../services/progresso_fases.dart';
import '../estudo/estudo_screen.dart';

/// Cor neon dos círculos/caminho das fases.
const _neon = Color(0xFF3DF5E4);

/// Mapa-múndi de FASES (PAISAGEM, tela cheia). Sobre `mapa_mundi.jpg`, cada
/// habitat é um **círculo com contorno neon** (uma "fase"). Toque num círculo →
/// abre as palavras daquele habitat; ao terminar (chegar na última palavra),
/// a fase é marcada como concluída: o círculo **acende** e o **caminho** até a
/// próxima fase brilha. O progresso fica salvo (ProgressoFases).
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAgua,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: kMapaMundiAspect,
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final h = c.maxHeight;
                  final d = (w * 0.13).clamp(44.0, 88.0);
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/habitats/mapa_mundi.jpg',
                          fit: BoxFit.fill,
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
                      // círculos das fases
                      for (final fase in Habitat.fases)
                        Positioned(
                          left: fase.fx * w - d / 2,
                          top: fase.fy * h - d / 2,
                          width: d,
                          height: d,
                          child: _CirculoFase(
                            emoji: fase.emoji,
                            numero: fase.ordem,
                            concluida: _concluidas.contains(fase.chave),
                            onTap: () => _abrirFase(fase),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          // voltar
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Material(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: const CircleBorder(
                    side: BorderSide(color: Colors.white24),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: Colors.white,
                    tooltip: 'Voltar',
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

/// Um círculo de fase, com contorno neon e brilho. Concluída = preenchido e
/// brilhando mais (com uma estrelinha).
class _CirculoFase extends StatelessWidget {
  const _CirculoFase({
    required this.emoji,
    required this.numero,
    required this.concluida,
    required this.onTap,
  });

  final String emoji;
  final int numero;
  final bool concluida;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: concluida
              ? _neon.withValues(alpha: 0.30)
              : Colors.black.withValues(alpha: 0.42),
          border: Border.all(color: _neon, width: concluida ? 4 : 3),
          boxShadow: [
            BoxShadow(
              color: _neon.withValues(alpha: concluida ? 0.95 : 0.6),
              blurRadius: concluida ? 20 : 11,
              spreadRadius: concluida ? 2 : 1,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(emoji, style: const TextStyle(fontSize: 34)),
              ),
            ),
            if (concluida)
              const Align(
                alignment: Alignment.topRight,
                child: Icon(Icons.star_rounded,
                    color: Color(0xFFFFD54A), size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
