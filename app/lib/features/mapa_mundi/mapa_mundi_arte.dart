import 'package:flutter/material.dart';

/// Desenha um **mapa-múndi estilizado (infográfico)** direto no canvas — nítido
/// em qualquer tela, sem depender de arquivo de imagem. Tem oceano com
/// profundidade (gradiente + plataforma rasa nas costas), continentes com
/// sombra/relevo e algumas montanhas. As silhuetas são **propositalmente
/// simplificadas** (é um desenho de jogo, não um mapa geográfico exato); o que
/// importa é dar pra reconhecer os continentes e pôr cada bicho no lugar certo.
///
/// Coordenadas dos continentes/montanhas são **frações 0..1** (x→direita,
/// y→baixo) sobre a box do mapa — então escalam com o stretch sem sair do lugar.
class MapaMundiArtePainter extends CustomPainter {
  const MapaMundiArtePainter();

  // ── Continentes (polígonos suavizados) ────────────────────────────────────
  static const _gelo = <Offset>[
    Offset(0.31, 0.10), Offset(0.35, 0.05), Offset(0.42, 0.05),
    Offset(0.46, 0.09), Offset(0.44, 0.14), Offset(0.38, 0.16),
    Offset(0.33, 0.14),
  ];
  static const _norteAmerica = <Offset>[
    Offset(0.06, 0.24), Offset(0.11, 0.15), Offset(0.18, 0.13),
    Offset(0.23, 0.17), Offset(0.24, 0.24), Offset(0.20, 0.30),
    Offset(0.22, 0.36), Offset(0.16, 0.40), Offset(0.12, 0.34),
    Offset(0.08, 0.30),
  ];
  static const _sulAmerica = <Offset>[
    Offset(0.21, 0.55), Offset(0.27, 0.53), Offset(0.30, 0.58),
    Offset(0.29, 0.66), Offset(0.27, 0.74), Offset(0.24, 0.84),
    Offset(0.21, 0.78), Offset(0.205, 0.66), Offset(0.19, 0.60),
  ];
  static const _europa = <Offset>[
    Offset(0.47, 0.20), Offset(0.52, 0.16), Offset(0.57, 0.18),
    Offset(0.58, 0.22), Offset(0.54, 0.25), Offset(0.49, 0.26),
    Offset(0.46, 0.24),
  ];
  static const _africa = <Offset>[
    Offset(0.47, 0.30), Offset(0.53, 0.28), Offset(0.60, 0.33),
    Offset(0.61, 0.42), Offset(0.57, 0.52), Offset(0.52, 0.60),
    Offset(0.49, 0.52), Offset(0.46, 0.42), Offset(0.45, 0.35),
  ];
  static const _asia = <Offset>[
    Offset(0.58, 0.16), Offset(0.66, 0.11), Offset(0.78, 0.10),
    Offset(0.88, 0.15), Offset(0.90, 0.24), Offset(0.84, 0.30),
    Offset(0.76, 0.30), Offset(0.68, 0.28), Offset(0.62, 0.24),
    Offset(0.585, 0.20),
  ];
  static const _australia = <Offset>[
    Offset(0.80, 0.60), Offset(0.87, 0.58), Offset(0.92, 0.63),
    Offset(0.91, 0.70), Offset(0.85, 0.72), Offset(0.80, 0.67),
  ];

  // (pontos, é_gelo?)
  static const _continentes = <(List<Offset>, bool)>[
    (_norteAmerica, false),
    (_sulAmerica, false),
    (_europa, false),
    (_africa, false),
    (_asia, false),
    (_australia, false),
    (_gelo, true),
  ];

  // Montanhas: (centro-base fracionário, altura fracionária).
  static const _montanhas = <(Offset, double)>[
    // Andes
    (Offset(0.225, 0.62), 0.05), (Offset(0.235, 0.70), 0.042),
    (Offset(0.24, 0.77), 0.036),
    // Rochosas
    (Offset(0.12, 0.25), 0.044), (Offset(0.145, 0.31), 0.036),
    // Himalaia
    (Offset(0.72, 0.22), 0.052), (Offset(0.78, 0.205), 0.044),
    (Offset(0.66, 0.205), 0.038),
    // África / Alpes
    (Offset(0.55, 0.40), 0.036), (Offset(0.53, 0.225), 0.03),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1) OCEANO — gradiente vertical dá a sensação de profundidade.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E5F8C), Color(0xFF083F63), Color(0xFF04263F)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    // 2) CONTINENTES (plataforma rasa → sombra → terra → costa).
    for (final (pts, gelo) in _continentes) {
      _terra(canvas, size, pts, gelo);
    }

    // 3) MONTANHAS (relevo por cima da terra).
    for (final (centro, h) in _montanhas) {
      _montanha(canvas, size, centro, h);
    }
  }

  /// Polígono suavizado (quadráticas passando pelos vértices) → costas
  /// arredondadas, com carinha de desenho.
  Path _suave(Size size, List<Offset> pts) {
    final s = [
      for (final o in pts) Offset(o.dx * size.width, o.dy * size.height),
    ];
    final n = s.length;
    Offset meio(Offset a, Offset b) => Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
    final path = Path();
    final ini = meio(s[n - 1], s[0]);
    path.moveTo(ini.dx, ini.dy);
    for (var i = 0; i < n; i++) {
      final cur = s[i];
      final m = meio(cur, s[(i + 1) % n]);
      path.quadraticBezierTo(cur.dx, cur.dy, m.dx, m.dy);
    }
    path.close();
    return path;
  }

  void _terra(Canvas canvas, Size size, List<Offset> pts, bool gelo) {
    final path = _suave(size, pts);
    final b = path.getBounds();

    // plataforma rasa (rim azul claro ao redor da costa)
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..color = const Color(0x553FB3D8),
    );
    // sombra de profundidade (dá o "relevo")
    canvas.drawShadow(path.shift(const Offset(0, 2)), const Color(0xFF00131F),
        7, false);

    // terra: gradiente claro→escuro = volume
    final cores = gelo
        ? const [Color(0xFFF4FBFF), Color(0xFFC9E3F0)]
        : const [Color(0xFFA6D06B), Color(0xFF5C8F3C)];
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: cores,
        ).createShader(b),
    );
    // costa (contorno)
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = gelo ? const Color(0xFF9FC3D6) : const Color(0xFF3C6B27),
    );
  }

  void _montanha(Canvas canvas, Size size, Offset centro, double alturaFrac) {
    final cx = centro.dx * size.width;
    final cy = centro.dy * size.height;
    final h = alturaFrac * size.height;
    final w = h * 0.95;
    final pico = Offset(cx, cy - h);
    final esq = Offset(cx - w / 2, cy);
    final dir = Offset(cx + w / 2, cy);

    // face esquerda (iluminada) e direita (na sombra) → 3D
    canvas.drawPath(
      Path()
        ..moveTo(pico.dx, pico.dy)
        ..lineTo(esq.dx, esq.dy)
        ..lineTo(cx, cy)
        ..close(),
      Paint()..color = const Color(0xFF9C8375),
    );
    canvas.drawPath(
      Path()
        ..moveTo(pico.dx, pico.dy)
        ..lineTo(dir.dx, dir.dy)
        ..lineTo(cx, cy)
        ..close(),
      Paint()..color = const Color(0xFF5F4A3E),
    );
    // neve no topo
    canvas.drawPath(
      Path()
        ..moveTo(pico.dx, pico.dy)
        ..lineTo(pico.dx - w * 0.16, pico.dy + h * 0.24)
        ..lineTo(pico.dx + w * 0.16, pico.dy + h * 0.24)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
  }

  @override
  bool shouldRepaint(MapaMundiArtePainter oldDelegate) => false;
}
