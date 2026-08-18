import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/habitat.dart';
import '../../services/banco_palavras.dart';
import '../../services/config_ordem.dart';
import '../../services/progresso_fases.dart';
import '../../services/progresso_repository.dart';
import '../../theme/app_colors.dart';
import '../estudo/estudo_screen.dart';

/// Cor neon dos anéis/caminho das fases.
const _neon = Color(0xFF3DF5E4);

/// Mapa-múndi de FASES (PAISAGEM, tela cheia). Sobre a arte `mapa_mundi.jpg`,
/// cada habitat é um **anel/pódio 3D achatado com brilho neon** (estilo "anel
/// embaixo do personagem" de jogo). Toque → abre as palavras daquela categoria;
/// ao concluir, o anel **acende** e o **caminho** até a próxima fase brilha.
/// A ordem das fases vem de [ConfigOrdem] (o usuário reordena em Configurações).
///
/// Botões: **seta** (topo-esq) volta à tela anterior · **Voltar habitat** desfaz
/// a última fase concluída · **Reiniciar aventura** apaga tudo · **Voltar início**
/// (casinha, inferior-dir) volta à tela principal.
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

  List<String> _concluidas = const [];
  List<Habitat> _fases = Habitat.fases;
  Map<String, String?> _medalhas = {}; // chave do habitat → 'ouro'|'prata'|'bronze'

  @override
  void initState() {
    super.initState();
    _aplicarTela();
    _carregar();
  }

  void _aplicarTela() {
    SystemChrome.setPreferredOrientations(_paisagem);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<Map<String, String?>> _carregarMedalhas() async {
    final mapa = <String, String?>{};
    for (final h in Habitat.values) {
      mapa[h.chave] = await ProgressoRepository.medalhaDe(h.chave);
    }
    return mapa;
  }

  Future<void> _carregar() async {
    final fases = await ConfigOrdem.fases();
    final concluidas = await ProgressoFases.carregar();
    final medalhas = await _carregarMedalhas();
    if (mounted) {
      setState(() {
        _fases = fases;
        _concluidas = concluidas;
        _medalhas = medalhas;
      });
    }
  }

  Future<void> _recarregarProgresso() async {
    final c = await ProgressoFases.carregar();
    final m = await _carregarMedalhas();
    if (mounted) {
      setState(() {
        _concluidas = c;
        _medalhas = m;
      });
    }
  }

  Future<void> _abrirFase(Habitat h, int numero) async {
    // "Aves" na aventura inclui a Fazenda (que não tem célula própria).
    final palavras = h == Habitat.aves
        ? palavrasDosHabitats(['aves', 'fazenda'])
        : palavrasDoHabitat(h.chave);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '${h.emoji}  Fase $numero · ${h.rotulo}',
          palavras: palavras,
          manterPaisagemAoSair: true,
          habitatConcluivel: h.chave,
        ),
      ),
    );
    if (!mounted) return;
    _aplicarTela();
    _recarregarProgresso();
  }

  /// "INICIAR JOGO" (botão central branco): começa a aventura pela PRIMEIRA
  /// fase da ordem configurada (a da engrenagem ⚙️).
  Future<void> _iniciarJogo() async {
    final fases = await ConfigOrdem.fases();
    if (!mounted || fases.isEmpty) return;
    await _abrirFase(fases.first, 1);
  }

  /// "Voltar habitat" — desfaz a ÚLTIMA fase concluída (uma por toque).
  Future<void> _voltarHabitat() async {
    final restantes = await ProgressoFases.voltarUltima();
    if (mounted) setState(() => _concluidas = restantes);
  }

  Future<void> _reiniciarAventura() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reiniciar aventura?'),
        content: const Text(
          'Apaga o progresso de TODAS as fases — as luzes voltam a apagar. '
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
    if (mounted) setState(() => _concluidas = const []);
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
                final d = (w * 0.12).clamp(56.0, 120.0); // tamanho do marcador
                final anelH = d * 0.34; // altura da elipse do anel (bem achatada)
                return Center(
                  child: SizedBox(
                    width: w,
                    height: boxH,
                    child: Stack(
                      clipBehavior: Clip.none,
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
                              painter: _CaminhoPainter(_fases, _concluidas),
                            ),
                          ),
                        ),
                        // anéis das fases (na ordem configurada)
                        for (var i = 0; i < _fases.length; i++)
                          Positioned(
                            left: _fases[i].fx * w - d / 2,
                            top: _fases[i].fy * boxH - (d - anelH / 2),
                            width: d,
                            height: d,
                            child: _AnelFase(
                              emoji: _fases[i].emoji,
                              anelAltura: anelH,
                              concluida: _concluidas.contains(_fases[i].chave),
                              medalha: _medalhas[_fases[i].chave],
                              onTap: () => _abrirFase(_fases[i], i + 1),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // seta de voltar (topo-esq)
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
          // botões de baixo: TODOS numa linha centralizada (Wrap → nunca fica
          // um sobre o outro; em telas estreitas quebra a linha).
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _BotaoTransparente(
                      icon: Icons.undo_rounded,
                      texto: 'VOLTAR HABITAT',
                      onTap: _voltarHabitat,
                    ),
                    _BotaoTransparente(
                      icon: Icons.refresh_rounded,
                      texto: 'REINICIAR AVENTURA',
                      onTap: _reiniciarAventura,
                    ),
                    _BotaoTransparente(
                      icon: Icons.play_arrow_rounded,
                      texto: 'INICIAR JOGO',
                      fundo: Colors.white,
                      letra: AppColors.bg,
                      onTap: _iniciarJogo,
                    ),
                    _BotaoTransparente(
                      icon: Icons.home_rounded,
                      texto: 'VOLTAR INÍCIO',
                      onTap: () => Navigator.of(context)
                          .popUntil((route) => route.isFirst),
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

/// Desenha o caminho ligando as fases na ordem configurada. O trecho
/// fase[i]→fase[i+1] "acende" (neon) quando a fase[i] está concluída.
class _CaminhoPainter extends CustomPainter {
  _CaminhoPainter(this.fases, this.concluidas);
  final List<Habitat> fases;
  final List<String> concluidas;

  @override
  void paint(Canvas canvas, Size size) {
    Offset centro(Habitat f) => Offset(f.fx * size.width, f.fy * size.height);
    for (var i = 0; i < fases.length - 1; i++) {
      final a = centro(fases[i]);
      final b = centro(fases[i + 1]);
      final aceso = concluidas.contains(fases[i].chave);
      if (aceso) {
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
  bool shouldRepaint(_CaminhoPainter old) =>
      old.concluidas != concluidas || old.fases != fases;
}

/// Anel/pódio de fase (estilo "anel embaixo do personagem"): elipse bem achatada
/// no "chão" com contorno neon e brilho difuso ("fumacinha"); o emoji fica em
/// cima. Concluída = anel ACESO (neon forte) + estrelinha; pendente = apagado.
class _AnelFase extends StatelessWidget {
  const _AnelFase({
    required this.emoji,
    required this.anelAltura,
    required this.concluida,
    required this.medalha,
    required this.onTap,
  });

  final String emoji;
  final double anelAltura;
  final bool concluida;

  /// Medalha da fase ('ouro'|'prata'|'bronze' ou null) — gamificação.
  final String? medalha;
  final VoidCallback onTap;

  static String _emojiMedalha(String? medalha) => switch (medalha) {
        'ouro' => '🥇',
        'prata' => '🥈',
        'bronze' => '🥉',
        _ => '⭐',
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // ANEL (pódio no chão)
          FractionallySizedBox(
            widthFactor: 0.94,
            child: SizedBox(
              height: anelAltura,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.all(Radius.elliptical(360, 120)),
                  gradient: RadialGradient(
                    radius: 0.95,
                    colors: concluida
                        ? [
                            _neon.withValues(alpha: 0.05),
                            _neon.withValues(alpha: 0.45),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.02),
                            Colors.black.withValues(alpha: 0.30),
                          ],
                    stops: const [0.35, 1.0],
                  ),
                  border: Border.all(
                    color: concluida
                        ? _neon
                        : Colors.white.withValues(alpha: 0.5),
                    width: concluida ? 3.5 : 2,
                  ),
                  boxShadow: concluida
                      ? [
                          BoxShadow(
                            color: _neon.withValues(alpha: 0.6),
                            blurRadius: 26,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: _neon.withValues(alpha: 0.9),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
              ),
            ),
          ),
          // EMOJI "em pé" no anel
          Positioned(
            bottom: anelAltura * 0.28,
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: anelAltura * 1.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // medalha da fase (ou estrelinha quando só concluída)
          if (concluida)
            Positioned(
              top: 0,
              right: anelAltura * 0.6,
              child: medalha == null
                  ? const Icon(Icons.star_rounded,
                      color: Color(0xFFFFD54A), size: 18)
                  : Text(
                      _emojiMedalha(medalha),
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
        ],
      ),
    );
  }
}

/// Botão dos mapas (mesmo estilo dos nomes/habitats) — os botões do mapa.
/// Padrão: fundo escuro translúcido e texto/ícone brancos. O "INICIAR JOGO"
/// passa `fundo: Colors.white` (pedido do usuário) com texto escuro.
class _BotaoTransparente extends StatelessWidget {
  const _BotaoTransparente({
    required this.icon,
    required this.texto,
    required this.onTap,
    this.fundo = const Color(0x8C000000),
    this.letra = Colors.white,
  });

  final IconData icon;
  final String texto;
  final VoidCallback onTap;

  /// Cor do fundo (padrão: preto translúcido).
  final Color fundo;

  /// Cor de texto/ícone (padrão: branco; no fundo branco fica escura).
  final Color letra;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fundo,
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
              Icon(icon, color: letra, size: 18),
              const SizedBox(width: 8),
              Text(
                texto,
                style: TextStyle(
                  color: letra,
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
