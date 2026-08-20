import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// "+4" / "-4" flutuando (sobe e some) — feedback rápido do acerto/erro.
class PontosFeedback extends StatefulWidget {
  const PontosFeedback({super.key, required this.texto, required this.onFim});

  final String texto;
  final VoidCallback onFim;

  @override
  State<PontosFeedback> createState() => _PontosFeedbackState();
}

class _PontosFeedbackState extends State<PontosFeedback>
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
                fontSize: 52,
                fontWeight: FontWeight.w900,
                color: positivo ? AppColors.acerto : AppColors.danger,
                shadows: const [
                  Shadow(color: Colors.black54, blurRadius: 6),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
