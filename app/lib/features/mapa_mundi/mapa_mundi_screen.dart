import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/habitat.dart'; // kAgua, kMapaDisplayAspect
import '../../models/regiao.dart';
import '../../services/banco_palavras.dart';
import '../../services/config_ordem.dart';
import '../../services/progresso_fases.dart';
import '../../services/progresso_repository.dart';
import '../../theme/app_colors.dart';
import '../colecao/colecao_screen.dart';
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
  List<Regiao> _fases = Regiao.regioes;

  // Pontuação (moedas/nível) — sempre visível no canto superior direito.
  int _moedas = 0;
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    _aplicarTela();
    _carregar();
    _carregarPontuacao();
  }

  void _aplicarTela() {
    SystemChrome.setPreferredOrientations(_paisagem);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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

  Future<void> _carregar() async {
    final fases = await ConfigOrdem.fases();
    final concluidas = await ProgressoFases.carregar();
    if (mounted) {
      setState(() {
        _fases = fases;
        _concluidas = concluidas;
      });
    }
  }

  /// A PRÓXIMA fase a jogar na ordem configurada (primeira ainda não
  /// concluída) — o anel dela fica pulsando, guiando o olhar. `null` quando
  /// todas já foram concluídas (aí todas acendem, sem pista de "próxima").
  String? get _proximaChave {
    for (final r in _fases) {
      if (!_concluidas.contains(r.chave)) return r.chave;
    }
    return null;
  }

  Future<void> _recarregarProgresso() async {
    final c = await ProgressoFases.carregar();
    if (mounted) setState(() => _concluidas = c);
    await _carregarPontuacao(); // moedas mudaram com acertos/erros
  }

  Future<void> _abrirFase(Regiao r, int numero) async {
    final palavras = palavrasDaRegiao(r.chave);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstudoScreen(
          titulo: '${r.emoji}  Fase $numero · ${r.rotulo}',
          palavras: palavras,
          manterPaisagemAoSair: true,
          habitatConcluivel: r.chave,
        ),
      ),
    );
    if (!mounted) return;
    _aplicarTela();
    _recarregarProgresso();
  }

  /// "INICIAR/CONTINUAR JOGO" (botão central branco): começa a aventura pela
  /// PRIMEIRA fase ainda não concluída da ordem configurada (a da engrenagem
  /// ⚙️) — se todas já foram concluídas, recomeça pela primeira.
  Future<void> _iniciarJogo() async {
    final fases = await ConfigOrdem.fases();
    if (!mounted || fases.isEmpty) return;
    final concluidas = await ProgressoFases.carregar();
    final idx = fases.indexWhere((r) => !concluidas.contains(r.chave));
    final inicio = idx < 0 ? 0 : idx;
    await _abrirFase(fases[inicio], inicio + 1);
  }

  /// Rótulo do botão principal: nenhuma fase → "INICIAR JOGO"; no meio da
  /// aventura → "CONTINUAR JOGO"; tudo concluído → "REINICIAR JOGO".
  String get _rotuloIniciar {
    if (_concluidas.isEmpty) return 'INICIAR JOGO';
    if (_proximaChave != null) return 'CONTINUAR JOGO';
    return 'REINICIAR JOGO';
  }

  /// "Voltar habitat" — desfaz a ÚLTIMA fase concluída (uma por toque).
  Future<void> _voltarHabitat() async {
    final restantes = await ProgressoFases.voltarUltima();
    if (mounted) setState(() => _concluidas = restantes);
  }

  /// Abre a COLEÇÃO de animais direto do mapa-múndi.
  Future<void> _abrirColecao() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ColecaoScreen()),
    );
    if (!mounted) return;
    _aplicarTela();
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
                        // anéis das fases (na ordem configurada) — só o anel,
                        // SEM emoji de bicho (pedido do usuário)
                        for (var i = 0; i < _fases.length; i++)
                          Positioned(
                            // caixa = SÓ o anel (centrado em fx,fy) — antes era
                            // d×d e a parte de cima vazia sobrepunha a fase
                            // vizinha (tocar no Céu abria a Ásia). Ver bug fix.
                            left: _fases[i].fx * w - d / 2,
                            top: _fases[i].fy * boxH - anelH / 2,
                            width: d,
                            height: anelH,
                            child: _AnelFase(
                              concluida: _concluidas.contains(_fases[i].chave),
                              proximo: _fases[i].chave == _proximaChave,
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
          // pontuação (moedas · nível) — canto superior direito.
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    '🪙 $_moedas · Nv ${ProgressoRepository.nivelDe(_xp)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
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
          // Fileira única de botões (inferior, CENTRALIZADA): VOLTAR HABITAT ·
          // REINICIAR AVENTURA · VOLTAR INÍCIO · COLEÇÃO · INICIAR/CONTINUAR
          // JOGO (fundo branco, último). Tudo numa linha — cabe sem encostar.
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
                      _BotaoTransparente(
                        icon: Icons.undo_rounded,
                        texto: 'VOLTAR HABITAT',
                        onTap: _voltarHabitat,
                      ),
                      const SizedBox(width: 10),
                      _BotaoTransparente(
                        icon: Icons.refresh_rounded,
                        texto: 'REINICIAR AVENTURA',
                        onTap: _reiniciarAventura,
                      ),
                      const SizedBox(width: 10),
                      _BotaoTransparente(
                        icon: Icons.home_rounded,
                        texto: 'VOLTAR INÍCIO',
                        onTap: () => Navigator.of(context)
                            .popUntil((route) => route.isFirst),
                      ),
                      const SizedBox(width: 10),
                      _BotaoTransparente(
                        icon: Icons.pets_rounded,
                        texto: 'COLEÇÃO',
                        onTap: _abrirColecao,
                      ),
                      const SizedBox(width: 10),
                      _BotaoTransparente(
                        icon: Icons.play_arrow_rounded,
                        texto: _rotuloIniciar,
                        fundo: Colors.white,
                        letra: AppColors.bg,
                        onTap: _iniciarJogo,
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

/// Desenha o caminho ligando as fases na ordem configurada. O trecho
/// fase[i]→fase[i+1] "acende" (neon) quando a fase[i] está concluída.
class _CaminhoPainter extends CustomPainter {
  _CaminhoPainter(this.fases, this.concluidas);
  final List<Regiao> fases;
  final List<String> concluidas;

  @override
  void paint(Canvas canvas, Size size) {
    Offset centro(Regiao f) => Offset(f.fx * size.width, f.fy * size.height);
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
/// no "chão" com contorno neon e brilho difuso ("fumacinha"). SÓ o anel/círculo
/// — sem emoji nenhum (pedido do usuário). Concluída = anel ACESO; `proximo`
/// (a próxima fase a jogar) = anel **pulsando**, guiando o olhar da criança.
class _AnelFase extends StatefulWidget {
  const _AnelFase({
    required this.concluida,
    required this.proximo,
    required this.onTap,
  });

  final bool concluida;

  /// É a próxima fase da ordem (primeira ainda não concluída)?
  final bool proximo;

  final VoidCallback onTap;

  @override
  State<_AnelFase> createState() => _AnelFaseState();
}

class _AnelFaseState extends State<_AnelFase>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulso = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.proximo) _pulso.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // O anel PREENCHE a caixa que recebe (largura d × altura anelH) — a área de
    // toque é exatamente o anel, sem "sobra" clicável por cima.
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _pulso,
        builder: (_, _) {
          final pulso = widget.proximo ? (0.5 + 0.5 * _pulso.value) : 0.0;
          final base = widget.concluida ? 3.5 : 2.0;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.elliptical(360, 120)),
              gradient: RadialGradient(
                radius: 0.95,
                colors: widget.concluida
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
                color: widget.proximo
                    ? Color.lerp(Colors.white, _neon, pulso)!
                    : widget.concluida
                        ? _neon
                        : Colors.white.withValues(alpha: 0.5),
                width: base + (widget.proximo ? 1.6 * pulso : 0),
              ),
              boxShadow: widget.concluida
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
                      if (widget.proximo)
                        BoxShadow(
                          color: _neon.withValues(alpha: 0.25 + 0.65 * pulso),
                          blurRadius: 14 + 22 * pulso,
                          spreadRadius: 2 + 4 * pulso,
                        ),
                    ]
                  : [
                      BoxShadow(
                        color: widget.proximo
                            ? _neon.withValues(alpha: 0.15 + 0.5 * pulso)
                            : Colors.black.withValues(alpha: 0.4),
                        blurRadius: widget.proximo ? 6 + 20 * pulso : 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
          );
        },
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
