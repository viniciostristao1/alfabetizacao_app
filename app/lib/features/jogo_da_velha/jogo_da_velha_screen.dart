import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  List<String?> _tab = List.filled(9, null);
  final List<List<String?>> _histTab = [];
  final List<String> _histVez = [];
  List<int>? _linhaVitoriosa;
  String _vez = 'X';
  bool _fim = false;
  String? _vencedor;

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );

  bool get _podeVoltar => _histTab.isNotEmpty;

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
        _anim.forward(from: 0);
        HapticFeedback.mediumImpact();
        return;
      }
    }
    if (!_tab.contains(null)) {
      _fim = true;
      HapticFeedback.heavyImpact();
    }
  }

  void _voltar() {
    if (!_podeVoltar) return;
    HapticFeedback.selectionClick();
    final tabAnterior = _histTab.removeLast();
    final vezAnterior = _histVez.removeLast();
    setState(() {
      _tab = List<String?>.from(tabAnterior);
      _vez = vezAnterior;
      _linhaVitoriosa = null;
      _vencedor = null;
      _fim = false;
      _anim.reset();
    });
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  _fim
                      ? (_vencedor != null ? 'Venceu $_vencedor! 🎉' : 'Deu velha! 😅')
                      : 'Vez do $_vez',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _fim && _vencedor != null
                        ? (_vencedor == 'X' ? AppColors.accent : AppColors.acerto)
                        : AppColors.text,
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
                                                  fontSize: 56,
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
