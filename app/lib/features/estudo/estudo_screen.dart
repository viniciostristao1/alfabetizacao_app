import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/estudo_opcoes.dart';
import '../../models/palavra.dart';
import '../../services/progresso_fases.dart';
import '../../services/progresso_repository.dart';
import '../../theme/app_colors.dart';

/// Tela de estudo (PAISAGEM): mostra uma palavra grande de cada vez, com:
///  - **bolinhas de fundo (horizontais)** no topo, ao lado do título — preto,
///    branco, bege escuro, bege claro (a palavra fica branca só no preto);
///  - **bolinhas de caneta (verticais)** à esquerda + um "limpar" — a criança
///    escreve na tela por cima (como um caderno), com caneta capacitiva ou dedo;
///  - **botões baixos** embaixo (Voltar / Anterior / Recomeçar / Próximo).
///
/// Força paisagem ao abrir e RESTAURA o retrato ao sair (botão ou "voltar" do
/// sistema). O desenho é limpo ao trocar de palavra.
class EstudoScreen extends StatefulWidget {
  const EstudoScreen({
    super.key,
    required this.titulo,
    required this.palavras,
    this.manterPaisagemAoSair = false,
    this.habitatConcluivel,
  });

  /// Cabeçalho da tela, ex.: "🍎  Alimentos · Fácil" ou "🐶  Animais · Ártico".
  final String titulo;
  final List<Palavra> palavras;

  /// Se `true`, ao sair volta para PAISAGEM (fluxo do mapa de habitats, que já é
  /// deitado); se `false` (padrão, fluxo de Nível), volta para RETRATO.
  final bool manterPaisagemAoSair;

  /// Se preenchido (chave do habitat), marca a **fase concluída** no
  /// [ProgressoFases] quando a criança chega na última palavra — o mapa-múndi
  /// então acende o círculo e o caminho até a próxima fase.
  final String? habitatConcluivel;

  @override
  State<EstudoScreen> createState() => _EstudoScreenState();
}

class _EstudoScreenState extends State<EstudoScreen> {
  int _i = 0;
  FundoTela _fundo = FundoTela.preto;
  CorCaneta _caneta = CorCaneta.azul;
  final List<_Traco> _tracos = [];

  // ── gamificação (XP/moedas): carregados no initState e atualizados no V/X ──
  int _moedas = 0;
  int _xp = 0;
  String? _feedback; // "+4" / "-4" flutuando sobre a palavra
  int _feedbackSeq = 0; // key nova a cada feedback (reinicia a animação)

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _carregarGamificacao();
    _talvezConcluir(); // caso o habitat tenha 1 palavra só
  }

  Future<void> _carregarGamificacao() async {
    final moedas = await ProgressoRepository.moedas();
    final xp = await ProgressoRepository.xp();
    if (mounted) {
      setState(() {
        _moedas = moedas;
        _xp = xp;
      });
    }
  }

  /// Pontos da palavra atual: 2 × (sílabas − 1) → 2 sílabas = 2, 3 = 4, 4 = 6.
  /// Palavras do usuário (1 sílaba) dão 1 ponto.
  int get _pontosPalavra =>
      (2 * (widget.palavras[_i].nivelSilabas - 1)).clamp(1, 999);

  void _mostrarFeedback(String texto) {
    _feedback = texto;
    _feedbackSeq++;
  }

  /// V verde: acertou → soma pontos (XP + moedas) e avança. Se for a última
  /// palavra de uma fase do mapa-múndi, abre o baú (bônus + medalha).
  Future<void> _acertou() async {
    final pontos = _pontosPalavra;
    final habitat = widget.habitatConcluivel;
    await ProgressoRepository.registrarAcerto(pontos, habitat: habitat);
    if (!mounted) return;
    setState(() {
      _moedas += pontos;
      _xp += pontos;
      _tracos.clear();
      _mostrarFeedback('+$pontos');
    });
    final ultima = _i == widget.palavras.length - 1;
    if (ultima && habitat != null) {
      await _concluirFase();
    } else if (_temProximo) {
      setState(() => _i++);
    }
  }

  /// X vermelho: errou → perde os pontos da palavra (nunca abaixo de zero) e a
  /// palavra REPETE até acertar (erro vira aprendizado, não frustração).
  Future<void> _errou() async {
    final pontos = _pontosPalavra;
    final habitat = widget.habitatConcluivel;
    await ProgressoRepository.registrarErro(pontos, habitat: habitat);
    if (!mounted) return;
    setState(() {
      _moedas = (_moedas - pontos).clamp(0, 99999);
      _tracos.clear();
      _mostrarFeedback('-$pontos');
    });
  }

  /// Fim de fase no mapa-múndi: baú com bônus de moedas + medalha pela
  /// precisão (ouro/prata/bronze).
  Future<void> _concluirFase() async {
    final medalha = await ProgressoRepository.medalhaDe(
      widget.habitatConcluivel!,
    );
    await ProgressoRepository.registrarBonusFase();
    if (!mounted) return;
    setState(() => _moedas += ProgressoRepository.bonusFase);
    await showDialog<void>(
      context: context,
      builder: (_) => _BauDialog(medalha: medalha),
    );
  }

  /// Marca a fase concluída quando a criança chega na última palavra do habitat.
  void _talvezConcluir() {
    if (widget.habitatConcluivel != null &&
        _i == widget.palavras.length - 1) {
      ProgressoFases.marcarConcluido(widget.habitatConcluivel!);
    }
  }

  @override
  void dispose() {
    // O app é todo PAISAGEM — garante ao sair (redundante, mas seguro).
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  bool get _temAnterior => _i > 0;
  bool get _temProximo => _i < widget.palavras.length - 1;

  void _limparDesenho() => setState(_tracos.clear);

  void _desfazer() {
    if (_tracos.isEmpty) return;
    setState(() => _tracos.removeLast());
  }

  void _anterior() {
    if (!_temAnterior) return;
    setState(() {
      _i--;
      _tracos.clear();
    });
  }

  void _proximo() {
    if (!_temProximo) return;
    setState(() {
      _i++;
      _tracos.clear();
    });
    _talvezConcluir();
  }

  void _recomecar() => setState(() {
        _i = 0;
        _tracos.clear();
      });

  void _sair() => Navigator.of(context).pop();

  // ── desenho (caneta) ──
  void _inicioTraco(PointerDownEvent e) {
    setState(() => _tracos.add(_Traco(_caneta.cor)..pontos.add(e.localPosition)));
  }

  void _moveTraco(PointerMoveEvent e) {
    if (_tracos.isEmpty) return;
    setState(() => _tracos.last.pontos.add(e.localPosition));
  }

  @override
  Widget build(BuildContext context) {
    final palavra = widget.palavras[_i];
    final letra = _fundo.corLetra; // cor da palavra (contraste)
    final ui = _fundo.corLetra; // cor base da UI sobre o fundo

    return Scaffold(
      backgroundColor: _fundo.cor,
      body: Stack(
        children: [
          Column(
            children: [
              // Linha do topo FORA do SafeArea. O padding direito (104)
              // RESERVA o espaço dos botões V/X flutuantes (eles ficam por cima,
              // colados no canto). Sem V/X aqui — são posicionados no Stack.
              MediaQuery.removePadding(
                context: context,
                removeLeft: true,
                removeRight: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 104, 0),
                  child: Row(
                    children: [
                      // Grupo esquerdo (título + bolinhas de fundo) absorve o
                      // espaço livre.
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.titulo,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: ui.withValues(alpha: 0.65),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            for (final f in FundoTela.values)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _Bolinha(
                                  cor: f.cor,
                                  selecionada: f == _fundo,
                                  contraste: ui,
                                  onTap: () => setState(() => _fundo = f),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Bloco da direita (progresso + moedas + nível).
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      Text(
                        '${_i + 1} / ${widget.palavras.length}',
                        style: TextStyle(
                          color: ui.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // moedas + nível (gamificação)
                      Text(
                        '🪙 $_moedas',
                        style: TextStyle(
                          color: ui,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nv ${ProgressoRepository.nivelDe(_xp)}',
                        style: TextStyle(
                          color: ui.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
            // ── meio: bolinhas de CANETA (verticais) + palavra + desenho ──
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final c in CorCaneta.values)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 9),
                            child: _Bolinha(
                              cor: c.cor,
                              selecionada: c == _caneta,
                              contraste: ui,
                              onTap: () => setState(() => _caneta = c),
                            ),
                          ),
                        const SizedBox(height: 3),
                        // Vassoura = limpa TUDO que foi desenhado.
                        _BotaoIcone(
                          icon: Icons.cleaning_services_rounded,
                          cor: ui,
                          onTap: _tracos.isEmpty ? null : _limparDesenho,
                          tooltip: 'Limpar tudo',
                        ),
                        const SizedBox(height: 8),
                        // Desfazer = apaga só o ÚLTIMO rabisco (clicando, apaga
                        // um a um, até esvaziar).
                        _BotaoIcone(
                          icon: Icons.undo_rounded,
                          cor: ui,
                          onTap: _tracos.isEmpty ? null : _desfazer,
                          tooltip: 'Apagar o último rabisco',
                        ),
                      ],
                    ),
                  ),
                  // área da palavra + camada de desenho (o "caderno")
                  Expanded(
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: _inicioTraco,
                      onPointerMove: _moveTraco,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8, 4, 20, 4),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    palavra.texto.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 200,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
                                      color: letra,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _DesenhoPainter(_tracos),
                              ),
                            ),
                          ),
                          // feedback "+4" / "-4" (acerto/erro) — no topo,
                          // CENTRALIZADO (não fica sobre a palavra).
                          if (_feedback != null)
                            Positioned(
                              top: 4,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: _PontosFeedback(
                                  key: ValueKey(_feedbackSeq),
                                  texto: _feedback!,
                                  onFim: () =>
                                      setState(() => _feedback = null),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── embaixo: botões baixos ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
              child: Row(
                children: [
                  _Botao(
                    icon: Icons.home_rounded,
                    label: 'Voltar',
                    ui: ui,
                    onTap: _sair,
                  ),
                  _Botao(
                    icon: Icons.chevron_left_rounded,
                    label: 'Anterior',
                    ui: ui,
                    onTap: _temAnterior ? _anterior : null,
                  ),
                  _Botao(
                    icon: Icons.restart_alt_rounded,
                    label: 'Recomeçar',
                    ui: ui,
                    onTap: _i == 0 ? null : _recomecar,
                  ),
                  _Botao(
                    icon: Icons.chevron_right_rounded,
                    label: 'Próximo',
                    ui: ui,
                    onTap: _temProximo ? _proximo : null,
                    destaque: true,
                  ),
                ],
              ),
            ),
                ],
              ),
            ),
          ),
            ],
          ),
          // V/X FLUTUANTES: no canto superior direito da TELA, lado a lado.
          // right: 12 → com folga da borda (a borda branca/sombra não é
          // cortada pela tela).
          Positioned(
            top: 10,
            right: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BotaoAcertoErro(
                  cor: AppColors.acerto,
                  letra: 'V',
                  tooltip: 'Acertou! Ganha os pontos e passa pra próxima',
                  onTap: _acertou,
                ),
                const SizedBox(width: 8),
                _BotaoAcertoErro(
                  cor: AppColors.danger,
                  letra: 'X',
                  tooltip: 'Errou. Perde os pontos e repete a palavra',
                  onTap: _errou,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Um traço desenhado (uma "canetada" contínua): pontos + cor.
class _Traco {
  _Traco(this.cor);
  final Color cor;
  final List<Offset> pontos = [];
}

/// Baú do fim de fase (mapa-múndi): presente animado + bônus de moedas +
/// medalha pela precisão da fase.
class _BauDialog extends StatefulWidget {
  const _BauDialog({required this.medalha});

  final String? medalha; // 'ouro' | 'prata' | 'bronze' | null

  @override
  State<_BauDialog> createState() => _BauDialogState();
}

class _BauDialogState extends State<_BauDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();

  late final Animation<double> _escala = CurvedAnimation(
    parent: _c,
    curve: Curves.elasticOut,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String get _medalhaTexto => switch (widget.medalha) {
        'ouro' => '🥇 Medalha de OURO!',
        'prata' => '🥈 Medalha de PRATA!',
        'bronze' => '🥉 Medalha de BRONZE!',
        _ => 'Sem medalha ainda — tente acertar todas!',
      };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('FASE CONCLUÍDA!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _escala,
            child: const Text('🎁', style: TextStyle(fontSize: 76)),
          ),
          const SizedBox(height: 10),
          Text(
            '+${ProgressoRepository.bonusFase} moedas!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _medalhaTexto,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}

/// "+4" / "-4" flutuando (sobe e some) — feedback rápido do V/X.
class _PontosFeedback extends StatefulWidget {
  const _PontosFeedback({super.key, required this.texto, required this.onFim});

  final String texto;
  final VoidCallback onFim;

  @override
  State<_PontosFeedback> createState() => _PontosFeedbackState();
}

class _PontosFeedbackState extends State<_PontosFeedback>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  )..forward();

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onFim();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final positivo = widget.texto.startsWith('+');
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final t = _c.value;
        return Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -22 * t),
            child: Text(
              widget.texto,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: positivo ? AppColors.acerto : AppColors.danger,
                shadows: const [
                  Shadow(color: Colors.black54, blurRadius: 4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Botão V (verde, acertou) / X (vermelho, errou) do topo direito — QUADRADO
/// com bordas levemente arredondadas (mesmo clima dos botões de baixo).
class _BotaoAcertoErro extends StatelessWidget {
  const _BotaoAcertoErro({
    required this.cor,
    required this.letra,
    required this.tooltip,
    required this.onTap,
  });

  final Color cor;
  final String letra;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: cor.withValues(alpha: 0.6),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Text(
              letra,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesenhoPainter extends CustomPainter {
  _DesenhoPainter(this.tracos);
  final List<_Traco> tracos;

  @override
  void paint(Canvas canvas, Size size) {
    for (final t in tracos) {
      if (t.pontos.isEmpty) continue;
      final paint = Paint()
        ..color = t.cor
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (t.pontos.length == 1) {
        canvas.drawCircle(t.pontos.first, 3, paint..style = PaintingStyle.fill);
        continue;
      }
      final path = Path()..moveTo(t.pontos.first.dx, t.pontos.first.dy);
      for (final p in t.pontos.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_DesenhoPainter old) => true;
}

/// Bolinha de seleção (cor de fundo ou de caneta). `contraste` = cor do texto
/// atual, usada na borda para a bolinha aparecer em qualquer fundo.
class _Bolinha extends StatelessWidget {
  const _Bolinha({
    required this.cor,
    required this.selecionada,
    required this.contraste,
    required this.onTap,
  });

  final Color cor;
  final bool selecionada;
  final Color contraste;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: cor,
          shape: BoxShape.circle,
          border: Border.all(
            color: selecionada
                ? contraste
                : contraste.withValues(alpha: 0.35),
            width: selecionada ? 3.5 : 1.5,
          ),
        ),
      ),
    );
  }
}

/// Botão de ícone só (o "limpar" da coluna de canetas).
class _BotaoIcone extends StatelessWidget {
  const _BotaoIcone({
    required this.icon,
    required this.cor,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final Color cor;
  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final habilitado = onTap != null;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: cor.withValues(alpha: habilitado ? 0.5 : 0.2),
            ),
          ),
          child: Icon(
            icon,
            size: 17,
            color: cor.withValues(alpha: habilitado ? 0.85 : 0.3),
          ),
        ),
      ),
    );
  }
}

/// Botão da barra inferior — BAIXO (ícone + rótulo lado a lado). `destaque` =
/// preenchido com o accent (o "Próximo"). Cores adaptam ao fundo via [ui].
class _Botao extends StatelessWidget {
  const _Botao({
    required this.icon,
    required this.label,
    required this.ui,
    required this.onTap,
    this.destaque = false,
  });

  final IconData icon;
  final String label;
  final Color ui;
  final VoidCallback? onTap;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    final habilitado = onTap != null;
    final Color fg;
    final Color bg;
    if (destaque) {
      fg = Colors.white;
      bg = habilitado
          ? AppColors.accent
          : AppColors.accent.withValues(alpha: 0.35);
    } else {
      fg = ui.withValues(alpha: habilitado ? 0.9 : 0.3);
      bg = ui.withValues(alpha: habilitado ? 0.08 : 0.04);
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: fg, size: 20),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
