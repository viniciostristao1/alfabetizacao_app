import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Estoura um monte de confetes coloridos (acerto de palavra / baú do fim de
/// fase). Animação única de ~1s: as partículas sobem, giram e somem. Não
/// captura toques (IgnorePointer) — é só efeito visual por cima da tela.
class ConfeteBurst extends StatefulWidget {
  const ConfeteBurst({super.key, this.muito = false});

  /// `true` = bem mais partículas (usado no baú do fim de fase).
  final bool muito;

  @override
  State<ConfeteBurst> createState() => _ConfeteBurstState();
}

class _ConfeteBurstState extends State<ConfeteBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  late final List<_Confete> _particulas = _gerar();

  final Random _r = Random();

  List<_Confete> _gerar() {
    final n = widget.muito ? 70 : 36;
    return [
      for (var i = 0; i < n; i++)
        _Confete(
          origemX: _r.nextDouble(),
          origemY: 0.2 + _r.nextDouble() * 0.55,
          angulo: _r.nextDouble() * 2 * pi,
          velocidade: 150 + _r.nextDouble() * 220,
          gravidade: 300 + _r.nextDouble() * 180,
          cor: AppColors.confete[_r.nextInt(AppColors.confete.length)],
          tamanho: 6 + _r.nextDouble() * 6,
          giro: (_r.nextDouble() - 0.5) * 12,
        ),
    ];
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(
          painter: _ConfetePainter(_particulas, _c.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Uma partícula de confete (quadradinho girando).
class _Confete {
  const _Confete({
    required this.origemX,
    required this.origemY,
    required this.angulo,
    required this.velocidade,
    required this.gravidade,
    required this.cor,
    required this.tamanho,
    required this.giro,
  });

  /// Origem em fração da tela (0..1).
  final double origemX;
  final double origemY;

  /// Direção do voo (radianos — espalha em 360°).
  final double angulo;
  final double velocidade;

  /// Aceleração pra baixo (o "cair" do confete).
  final double gravidade;
  final Color cor;
  final double tamanho;

  /// Velocidade de rotação (rad/s).
  final double giro;
}

class _ConfetePainter extends CustomPainter {
  _ConfetePainter(this.particulas, this.t);

  final List<_Confete> particulas;

  /// Progresso da animação (0..1).
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final fade = (1 - t).clamp(0.0, 1.0);
    for (final p in particulas) {
      final origem = Offset(p.origemX * size.width, p.origemY * size.height);
      final pos = origem +
          Offset(cos(p.angulo), sin(p.angulo)) * p.velocidade * t +
          Offset(0, p.gravidade * t * t);
      if (pos.dy > size.height + 40) continue;
      final escala = 1 - 0.6 * t;
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.giro * t);
      canvas.scale(escala);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.tamanho,
            height: p.tamanho * 0.55,
          ),
          const Radius.circular(1.5),
        ),
        Paint()..color = p.cor.withValues(alpha: fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfetePainter old) => old.t != t;
}
