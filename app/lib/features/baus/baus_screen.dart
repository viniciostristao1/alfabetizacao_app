import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import 'bau_variante_painter.dart';

class BausScreen extends StatelessWidget {
  const BausScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('🧰 Baús — Ateliê', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.surface2,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: const Text('Toque no baú para abrir/fechar • Só o baú + moedas, sem cenário • 10 estilos com pivô real', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.42, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: bauEstilos.length,
              itemBuilder: (c, i) => _BauCard(estilo: bauEstilos[i], index: i),
            ),
          ),
        ],
      ),
    );
  }
}

class _BauCard extends StatefulWidget {
  const _BauCard({required this.estilo, required this.index});
  final BauEstilo estilo;
  final int index;
  @override
  State<_BauCard> createState() => _BauCardState();
}

class _BauCardState extends State<_BauCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  bool get _aberto => _c.value > 0.5;
  void _toggle() {
    HapticFeedback.mediumImpact();
    if (_c.isCompleted || _c.value > 0.5) {
      _c.reverse();
    } else {
      _c.forward();
    }
  }
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: widget.estilo.ouro.withValues(alpha: 0.35))),
      child: Column(
        children: [
          Padding(padding: const EdgeInsets.only(top: 8), child: Text(widget.estilo.nome, style: TextStyle(color: widget.estilo.ouro, fontWeight: FontWeight.w800, fontSize: 12))),
          Expanded(
            child: GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.opaque,
              child: AnimatedBuilder(
                animation: _c,
                builder: (_, _) {
                  final p = Curves.easeInOutCubic.transform(_c.value);
                  return CustomPaint(size: const Size(168, 112), painter: BauBausPainter(p, widget.estilo));
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(_aberto ? 'aberto' : 'toque para abrir', style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
