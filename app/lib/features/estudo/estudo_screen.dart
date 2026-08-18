import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/estudo_opcoes.dart';
import '../../models/palavra.dart';
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
  });

  /// Cabeçalho da tela, ex.: "🍎  Alimentos · Fácil" ou "🐶  Animais · Ártico".
  final String titulo;
  final List<Palavra> palavras;

  /// Se `true`, ao sair volta para PAISAGEM (fluxo do mapa de habitats, que já é
  /// deitado); se `false` (padrão, fluxo de Nível), volta para RETRATO.
  final bool manterPaisagemAoSair;

  @override
  State<EstudoScreen> createState() => _EstudoScreenState();
}

class _EstudoScreenState extends State<EstudoScreen> {
  int _i = 0;
  FundoTela _fundo = FundoTela.preto;
  CorCaneta _caneta = CorCaneta.azul;
  final List<_Traco> _tracos = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Ao sair: volta ao retrato (fluxo de Nível) OU mantém a paisagem (fluxo do
    // mapa de habitats, que já é deitado) — evita o mapa voltar "em pé".
    SystemChrome.setPreferredOrientations(
      widget.manterPaisagemAoSair
          ? const [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : const [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ],
    );
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
      body: SafeArea(
        child: Column(
          children: [
            // ── topo: título + bolinhas de FUNDO (horizontais) + progresso ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
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
                  const Spacer(),
                  Text(
                    '${_i + 1} / ${widget.palavras.length}',
                    style: TextStyle(
                      color: ui.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
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
    );
  }
}

/// Um traço desenhado (uma "canetada" contínua): pontos + cor.
class _Traco {
  _Traco(this.cor);
  final Color cor;
  final List<Offset> pontos = [];
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
