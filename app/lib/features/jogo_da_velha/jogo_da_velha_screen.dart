import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_colors.dart';

class JogoDaVelhaScreen extends StatefulWidget {
  const JogoDaVelhaScreen({super.key});

  @override
  State<JogoDaVelhaScreen> createState() => _JogoDaVelhaScreenState();
}

class _JogoDaVelhaScreenState extends State<JogoDaVelhaScreen>
    with SingleTickerProviderStateMixin {
  static const _vitorias = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];
  static const _kPlacarX = 'velha_placar_x_v1';
  static const _kPlacarO = 'velha_placar_o_v1';
  static const _kPlacarVelha = 'velha_placar_velha_v1';

  List<String?> _tab = List.filled(9, null);
  final List<List<String?>> _histTab = [];
  final List<String> _histVez = [];
  List<int>? _linhaVitoriosa;
  String _vez = 'X';
  bool _fim = false;
  String? _vencedor;
  int _placarX = 0;
  int _placarO = 0;
  int _placarVelha = 0;

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );

  bool get _podeVoltar => _histTab.isNotEmpty;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _carregarPlacar();
  }

  Future<void> _carregarPlacar() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _placarX = p.getInt(_kPlacarX) ?? 0;
        _placarO = p.getInt(_kPlacarO) ?? 0;
        _placarVelha = p.getInt(_kPlacarVelha) ?? 0;
      });
    }
  }

  Future<void> _salvarPlacar() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kPlacarX, _placarX);
    await p.setInt(_kPlacarO, _placarO);
    await p.setInt(_kPlacarVelha, _placarVelha);
  }

  Future<void> _zerarPlacar() async {
    HapticFeedback.selectionClick();
    setState(() {
      _placarX = 0;
      _placarO = 0;
      _placarVelha = 0;
    });
    await _salvarPlacar();
  }

  void _jogar(int i) {
    if (_fim || _tab[i] != null) return;
    HapticFeedback.selectionClick();
    setState(() {
      _histTab.add(List<String?>.from(_tab));
      _histVez.add(_vez);
      _tab[i] = _vez;
      _checarFim();
      if (!_fim) _vez = _vez == 'X' ? 'O' : 'X';
    });
  }

  void _checarFim() {
    for (final l in _vitorias) {
      final a = _tab[l[0]], b = _tab[l[1]], c = _tab[l[2]];
      if (a != null && a == b && b == c) {
        _linhaVitoriosa = l;
        _vencedor = a;
        _fim = true;
        if (a == 'X') {
          _placarX++;
        } else {
          _placarO++;
        }
        _salvarPlacar();
        _anim.forward(from: 0);
        HapticFeedback.mediumImpact();
        return;
      }
    }
    if (!_tab.contains(null)) {
      _fim = true;
      _placarVelha++;
      _salvarPlacar();
      HapticFeedback.heavyImpact();
    }
  }

  void _voltar() {
    if (!_podeVoltar) return;
    HapticFeedback.selectionClick();
    final tabAnterior = _histTab.removeLast();
    final vezAnterior = _histVez.removeLast();
    final tinhaVencedor = _vencedor;
    final tinhaVelha = _fim && _vencedor == null;
    setState(() {
      if (tinhaVencedor == 'X') _placarX = (_placarX - 1).clamp(0, 9999);
      if (tinhaVencedor == 'O') _placarO = (_placarO - 1).clamp(0, 9999);
      if (tinhaVelha) _placarVelha = (_placarVelha - 1).clamp(0, 9999);
      _tab = List<String?>.from(tabAnterior);
      _vez = vezAnterior;
      _linhaVitoriosa = null;
      _vencedor = null;
      _fim = false;
      _anim.reset();
    });
    if (tinhaVencedor != null || tinhaVelha) _salvarPlacar();
  }

  void _recomecar() {
    HapticFeedback.selectionClick();
    setState(() {
      _tab = List.filled(9, null);
      _histTab.clear();
      _histVez.clear();
      _linhaVitoriosa = null;
      _vencedor = null;
      _fim = false;
      _vez = 'X';
      _anim.reset();
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('⭕  Jogo da Velha'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lineStrong, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PlacarChip(label: 'X', valor: _placarX, cor: AppColors.accent),
                    const SizedBox(width: 10),
                    const Text('·', style: TextStyle(color: AppColors.dim, fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(width: 10),
                    _PlacarChip(label: 'O', valor: _placarO, cor: AppColors.danger),
                    const SizedBox(width: 10),
                    const Text('·', style: TextStyle(color: AppColors.dim, fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(width: 10),
                    _PlacarChip(label: 'VELHA', valor: _placarVelha, cor: AppColors.dim),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  _fim
                      ? (_vencedor != null ? 'Venceu $_vencedor! 🎉' : 'Deu velha! 😅')
                      : 'Vez do $_vez',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _fim && _vencedor != null
                        ? (_vencedor == 'X' ? AppColors.accent : AppColors.danger)
                        : AppColors.dim,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth.clamp(0, 420).toDouble();
                  final size = w > 360 ? 360.0 : w;
                  return SizedBox(
                    width: size,
                    height: size,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.lineStrong, width: 1.5),
                          ),
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                            itemCount: 9,
                            itemBuilder: (_, i) {
                              final v = _tab[i];
                              final borda = BorderSide(color: AppColors.line.withValues(alpha: 0.5), width: 1.2);
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _jogar(i),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: i % 3 != 2 ? borda : BorderSide.none,
                                        bottom: i < 6 ? borda : BorderSide.none,
                                      ),
                                    ),
                                    child: Center(
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 160),
                                        child: v == null
                                            ? const SizedBox.shrink()
                                            : Text(
                                                v,
                                                key: ValueKey('$i-$v'),
                                                style: TextStyle(
                                                  fontSize: 72,
                                                  fontWeight: FontWeight.w900,
                                                  color: v == 'X' ? AppColors.accent : AppColors.danger,
                                                  height: 1,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (_linhaVitoriosa != null)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: AnimatedBuilder(
                                animation: _anim,
                                builder: (_, _) => CustomPaint(
                                  painter: _LinhaVitoriaPainter(
                                    linha: _linhaVitoriosa!,
                                    progresso: _anim.value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _podeVoltar ? _voltar : null,
                      icon: const Icon(Icons.undo_rounded),
                      label: const Text('Voltar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text,
                        side: const BorderSide(color: AppColors.lineStrong),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _recomecar,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Recomeçar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.onAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: (_placarX + _placarO + _placarVelha) > 0 ? _zerarPlacar : null,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Zerar placar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dim,
                    side: const BorderSide(color: AppColors.line),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (_fim) ...[
                const SizedBox(height: 10),
                Text(
                  _vencedor != null ? 'Toque em Recomeçar para jogar de novo' : 'Toque em Recomeçar',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.dim),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlacarChip extends StatelessWidget {
  const _PlacarChip({required this.label, required this.valor, required this.cor});
  final String label;
  final int valor;
  final Color cor;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cor.withValues(alpha: 0.55), width: 1.5),
      ),
      child: Text(
        '$label $valor',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: cor, height: 1),
      ),
    );
  }
}

class _LinhaVitoriaPainter extends CustomPainter {
  _LinhaVitoriaPainter({required this.linha, required this.progresso});

  final List<int> linha;
  final double progresso;

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / 3;
    final cellH = size.height / 3;

    Offset centro(int idx) {
      final r = idx ~/ 3;
      final c = idx % 3;
      return Offset(c * cellW + cellW / 2, r * cellH + cellH / 2);
    }

    final p1 = centro(linha.first);
    final p2 = centro(linha.last);
    final cur = Offset.lerp(p1, p2, Curves.easeOutCubic.transform(progresso))!;

    final paint = Paint()
      ..color = AppColors.confete.first
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(p1, cur, shadow);
    canvas.drawLine(p1, cur, paint);

    final glow = Paint()
      ..color = AppColors.confete.first.withValues(alpha: 0.28)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawLine(p1, cur, glow);
  }

  @override
  bool shouldRepaint(covariant _LinhaVitoriaPainter old) =>
      old.progresso != progresso || old.linha != linha;
}
