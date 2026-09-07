import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class BauEstilo {
  const BauEstilo({
    required this.nome,
    required this.madeira,
    required this.madeiraEscura,
    required this.ouro,
    required this.ouroEscuro,
    required this.interior,
  });
  final String nome;
  final Color madeira;
  final Color madeiraEscura;
  final Color ouro;
  final Color ouroEscuro;
  final Color interior;
}

const bauEstilos = [
  BauEstilo(nome: '1 Clássico', madeira: Color(0xFF9C6B3C), madeiraEscura: Color(0xFF6B4523), ouro: Color(0xFFF5C542), ouroEscuro: Color(0xFFB8860B), interior: Color(0xFF2E1B0D)),
  BauEstilo(nome: '2 Pirata', madeira: Color(0xFF5C3310), madeiraEscura: Color(0xFF2A1608), ouro: Color(0xFF9C6B2A), ouroEscuro: Color(0xFF6B3A0A), interior: Color(0xFF1A0F0A)),
  BauEstilo(nome: '3 Real', madeira: Color(0xFF7A3300), madeiraEscura: Color(0xFF3D1A00), ouro: Color(0xFFFFD54F), ouroEscuro: Color(0xFFB7790A), interior: Color(0xFF1E0F04)),
  BauEstilo(nome: '4 Rubi', madeira: Color(0xFF6A1B0A), madeiraEscura: Color(0xFF2B0800), ouro: Color(0xFFC0392B), ouroEscuro: Color(0xFF7A1A12), interior: Color(0xFF1A0505)),
  BauEstilo(nome: '5 Safira', madeira: Color(0xFF1A4A6A), madeiraEscura: Color(0xFF0B2538), ouro: Color(0xFF2E86C1), ouroEscuro: Color(0xFF1A5276), interior: Color(0xFF0A141E)),
  BauEstilo(nome: '6 Esmeralda', madeira: Color(0xFF2F5A1A), madeiraEscura: Color(0xFF132E0A), ouro: Color(0xFF27AE60), ouroEscuro: Color(0xFF1E6A3A), interior: Color(0xFF0F1A0A)),
  BauEstilo(nome: '7 Galáxia', madeira: Color(0xFF2C1A5A), madeiraEscura: Color(0xFF120A2E), ouro: Color(0xFF8E44AD), ouroEscuro: Color(0xFF4A235A), interior: Color(0xFF0F0A1A)),
  BauEstilo(nome: '8 Gelo', madeira: Color(0xFF4A7FBF), madeiraEscura: Color(0xFF1E3A4F), ouro: Color(0xFFAED6F1), ouroEscuro: Color(0xFF2E86C1), interior: Color(0xFF0A141E)),
  BauEstilo(nome: '9 Mel', madeira: Color(0xFFC48A1A), madeiraEscura: Color(0xFF7A4A0A), ouro: Color(0xFFF5C16C), ouroEscuro: Color(0xFFB7790A), interior: Color(0xFF1E1508)),
  BauEstilo(nome: '10 Toy', madeira: Color(0xFFE74C3C), madeiraEscura: Color(0xFF7B1C1C), ouro: Color(0xFFF1C40F), ouroEscuro: Color(0xFFB7950B), interior: Color(0xFF1A0A0A)),
];

class BauBausPainter extends CustomPainter {
  BauBausPainter(this.p, this.estilo);
  final double p;
  final BauEstilo estilo;
  final Random _r = Random(7);
  static const _larg = 98.0;
  static const _prof = 32.0;
  static const _alt = 42.0;
  static const _raioT = _prof / 2;
  static const _espT = 3.2;
  static const _parede = 4.0;
  static const _saia = 5.0;
  static const _kx = 0.55;
  static const _ky = 0.30;
  double _ox = 0;
  double _oy = 0;
  Offset _proj(double x, double y, double z) => Offset(_ox + x + _kx * z, _oy - y - _ky * z);
  double get _theta {
    final t = p.clamp(0.0, 1.0);
    return (t + 0.06 * sin(t * pi) * (1 - t)) * (pi / 2);
  }
  Offset _lid(double x, double y0, double z0) {
    final th = _theta;
    final s = sin(th);
    final c = cos(th);
    final dz0 = z0 - _prof;
    final y = y0 * c - dz0 * s;
    final z = _prof + y0 * s + dz0 * c;
    return _proj(x, y, z);
  }
  @override
  void paint(Canvas canvas, Size size) {
    _ox = size.width * 0.462;
    _oy = size.height * 0.50;
    final th = _theta;
    _sombraChao(canvas, th);
    _glow(canvas, size, th);
    if (th > 0.05) _interior(canvas, th);
    if (th > 0.22) _tesouro(canvas, th);
    _corpo(canvas);
    _derramado(canvas, th);
    _cadeado(canvas);
    _tampa(canvas, th);
  }
  void _sombraChao(Canvas canvas, double th) {
    final s = sin(th);
    final base = _proj(0, -_alt, _prof * 0.45);
    canvas.drawOval(Rect.fromCenter(center: base + const Offset(0, 3), width: _larg * 1.28, height: 15), Paint()..color = Colors.black.withValues(alpha: 0.40)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));
    canvas.drawOval(Rect.fromCenter(center: base + const Offset(0, 2), width: _larg * 1.05, height: 10), Paint()..color = Colors.black.withValues(alpha: 0.24)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    if (s > 0.08) {
      final atras = _proj(0, -_alt, _prof + 4 + s * _prof * 0.7);
      canvas.drawOval(Rect.fromCenter(center: atras + const Offset(0, 2.5), width: _larg * 0.9, height: 8), Paint()..color = Colors.black.withValues(alpha: 0.20 * s)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    }
  }
  void _glow(Canvas canvas, Size size, double th) {
    if (th <= 0.02) return;
    final f = (th / 1.2).clamp(0.0, 1.0);
    final c = _proj(0, 3, _prof * 0.45);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), Paint()..shader = RadialGradient(colors: [estilo.ouro.withValues(alpha: 0.55 * f), estilo.ouro.withValues(alpha: 0.14 * f), estilo.ouro.withValues(alpha: 0)], stops: const [0.0, 0.5, 1.0]).createShader(Rect.fromCircle(center: c, radius: 52 + 26 * f)));
  }
  void _interior(Canvas canvas, double th) {
    final xi = _larg / 2 - _parede;
    final z0 = _parede;
    final z1 = _prof - _parede;
    const yPiso = -6.0;
    final piso = Path()..moveTo(_proj(-xi, yPiso, z1).dx, _proj(-xi, yPiso, z1).dy)..lineTo(_proj(xi, yPiso, z1).dx, _proj(xi, yPiso, z1).dy)..lineTo(_proj(xi, yPiso, z0).dx, _proj(xi, yPiso, z0).dy)..lineTo(_proj(-xi, yPiso, z0).dx, _proj(-xi, yPiso, z0).dy)..close();
    canvas.drawPath(piso, Paint()..color = estilo.interior);
    canvas.drawPath(piso, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent]).createShader(piso.getBounds()));
    final pF = Path()..moveTo(_proj(-xi, 0, z1).dx, _proj(-xi, 0, z1).dy)..lineTo(_proj(xi, 0, z1).dx, _proj(xi, 0, z1).dy)..lineTo(_proj(xi, yPiso, z1).dx, _proj(xi, yPiso, z1).dy)..lineTo(_proj(-xi, yPiso, z1).dx, _proj(-xi, yPiso, z1).dy)..close();
    canvas.drawPath(pF, Paint()..color = Color.lerp(estilo.madeira, Colors.white, 0.08)!);
    final pT = Path()..moveTo(_proj(-xi, 0, z0).dx, _proj(-xi, 0, z0).dy)..lineTo(_proj(xi, 0, z0).dx, _proj(xi, 0, z0).dy)..lineTo(_proj(xi, yPiso, z0).dx, _proj(xi, yPiso, z0).dy)..lineTo(_proj(-xi, yPiso, z0).dx, _proj(-xi, yPiso, z0).dy)..close();
    canvas.drawPath(pT, Paint()..color = Color.lerp(estilo.interior, Colors.black, 0.3)!);
    final pL = Path()..moveTo(_proj(xi, 0, z1).dx, _proj(xi, 0, z1).dy)..lineTo(_proj(xi, 0, z0).dx, _proj(xi, 0, z0).dy)..lineTo(_proj(xi, yPiso, z0).dx, _proj(xi, yPiso, z0).dy)..lineTo(_proj(xi, yPiso, z1).dx, _proj(xi, yPiso, z1).dy)..close();
    canvas.drawPath(pL, Paint()..color = Color.lerp(estilo.madeiraEscura, Colors.black, 0.2)!);
    final cobre = (1 - th / 1.45).clamp(0.0, 1.0);
    if (cobre > 0.02) {
      final boca = Path()..moveTo(_proj(-xi, 0, z1).dx, _proj(-xi, 0, z1).dy)..lineTo(_proj(xi, 0, z1).dx, _proj(xi, 0, z1).dy)..lineTo(_proj(xi, 0, z0).dx, _proj(xi, 0, z0).dy)..lineTo(_proj(-xi, 0, z0).dx, _proj(-xi, 0, z0).dy)..close();
      canvas.drawPath(boca, Paint()..color = Colors.black.withValues(alpha: 0.55 * cobre));
    }
  }
  late final List<({double x, double y, double z, double s, Color? joia})> _monte = _gerarMonte();
  List<({double x, double y, double z, double s, Color? joia})> _gerarMonte() {
    final rnd = Random(11);
    final list = <({double x, double y, double z, double s, Color? joia})>[];
    for (var i = 0; i < 6; i++) {
      list.add((x: -36 + i * 14 + rnd.nextDouble() * 6 - 3, y: -5.2, z: 9 + rnd.nextDouble() * 16, s: 1.0, joia: null));
    }
    for (var i = 0; i < 5; i++) {
      list.add((x: -28 + i * 14 + rnd.nextDouble() * 5 - 2.5, y: -1.8, z: 11 + rnd.nextDouble() * 12, s: 0.97, joia: null));
    }
    for (var i = 0; i < 3; i++) {
      list.add((x: -14 + i * 14 + rnd.nextDouble() * 4 - 2, y: 1.6, z: 14 + rnd.nextDouble() * 7, s: 0.94, joia: null));
    }
    list[3] = (x: list[3].x, y: list[3].y, z: list[3].z, s: 1.0, joia: AppColors.acerto);
    list[10] = (x: list[10].x, y: list[10].y, z: list[10].z, s: 0.9, joia: AppColors.accent);
    list.sort((a, b) { final dz = b.z.compareTo(a.z); return dz != 0 ? dz : a.y.compareTo(b.y); });
    return list;
  }
  void _tesouro(Canvas canvas, double th) {
    for (final m in _monte) {
      final c = _proj(m.x, m.y, m.z);
      if (m.joia != null) {
        _joia(canvas, c + const Offset(0, -2), 6.4 * m.s, m.joia!);
      } else {
        _moeda3d(canvas, c, m.s);
      }
    }
    for (var i = 0; i < 4; i++) {
      final bx = -20 + i * 13 + _r.nextDouble() * 6 - 3;
      final bz = 12 + _r.nextDouble() * 10;
      final c = _proj(bx, 4 + _r.nextDouble() * 3, bz);
      _brilho(canvas, c, 2.6 + _r.nextDouble() * 1.4, 0.35 + 0.55 * ((th - 0.22) / 0.5).clamp(0.0, 1.0));
    }
  }
  void _moeda3d(Canvas canvas, Offset c, double s) {
    final rx = 5.4 * s;
    final ry = rx * 0.40;
    canvas.drawOval(Rect.fromCenter(center: c + Offset(1.6 * s, 1.4 * s), width: rx * 2, height: ry * 2), Paint()..color = Colors.black.withValues(alpha: 0.34));
    canvas.drawOval(Rect.fromCenter(center: c + Offset(0, 1.2 * s), width: rx * 2, height: ry * 2), Paint()..color = const Color(0xFF8C6A0E));
    final face = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2);
    canvas.drawOval(face, Paint()..shader = RadialGradient(center: const Alignment(-0.42, -0.55), radius: 1.0, colors: [Color.lerp(estilo.ouro, Colors.white, 0.55)!, estilo.ouro, const Color(0xFFE8A910), estilo.ouroEscuro], stops: const [0.0, 0.34, 0.68, 1.0]).createShader(face));
    canvas.drawOval(face, Paint()..color = estilo.ouroEscuro.withValues(alpha: 0.9)..style = PaintingStyle.stroke..strokeWidth = 0.9 * s);
    canvas.drawOval(Rect.fromCenter(center: c, width: rx * 1.3, height: ry * 1.3), Paint()..color = estilo.ouroEscuro.withValues(alpha: 0.5)..style = PaintingStyle.stroke..strokeWidth = 0.7 * s);
    canvas.drawOval(Rect.fromCenter(center: c + Offset(-rx * 0.30, -ry * 0.40), width: rx * 0.6, height: ry * 0.5), Paint()..color = Colors.white.withValues(alpha: 0.8));
  }
  void _joia(Canvas canvas, Offset c, double r, Color cor) {
    canvas.drawOval(Rect.fromCenter(center: c + Offset(0.9, 1.3), width: r * 1.6, height: r * 1.3), Paint()..color = Colors.black.withValues(alpha: 0.38));
    final path = Path()..moveTo(c.dx, c.dy - r)..lineTo(c.dx + r * 0.82, c.dy)..lineTo(c.dx, c.dy + r)..lineTo(c.dx - r * 0.82, c.dy)..close();
    canvas.drawPath(path, Paint()..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color.lerp(cor, Colors.white, 0.48)!, cor, Color.lerp(cor, Colors.black, 0.58)!], stops: const [0.0, 0.52, 1.0]).createShader(Rect.fromCircle(center: c, radius: r)));
    final faceta = Paint()..color = Colors.white.withValues(alpha: 0.52)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    canvas.drawLine(Offset(c.dx - r * 0.52, c.dy - r * 0.32), Offset(c.dx + r * 0.52, c.dy - r * 0.32), faceta);
    canvas.drawLine(Offset(c.dx - r * 0.52, c.dy - r * 0.32), Offset(c.dx, c.dy + r * 0.28), faceta);
    canvas.drawLine(Offset(c.dx + r * 0.52, c.dy - r * 0.32), Offset(c.dx, c.dy + r * 0.28), faceta);
    canvas.drawCircle(c + Offset(-r * 0.28, -r * 0.32), r * 0.22, Paint()..color = Colors.white.withValues(alpha: 0.92));
  }
  void _brilho(Canvas canvas, Offset c, double r, double alpha) {
    final paint = Paint()..color = Colors.white.withValues(alpha: alpha)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: r * 3.8, height: r * 0.95), Radius.circular(r / 2)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: r * 0.95, height: r * 3.8), Radius.circular(r / 2)), paint);
    canvas.drawCircle(c, r * 0.78, Paint()..color = Colors.white.withValues(alpha: alpha));
    canvas.drawCircle(c, r * 0.28, Paint()..color = Colors.white);
  }
  void _corpo(Canvas canvas) {
    final a = _proj(-_larg / 2, 0, 0);
    final b = _proj(_larg / 2, 0, 0);
    final c = _proj(_larg / 2, -_alt, 0);
    final d = _proj(-_larg / 2, -_alt, 0);
    final bz = _proj(_larg / 2, 0, _prof);
    final cz = _proj(_larg / 2, -_alt, _prof);
    final sombraCorpo = Path()..moveTo(a.dx + 1, a.dy + 1)..lineTo(bz.dx + 1, bz.dy + 1)..lineTo(cz.dx + 1, cz.dy + 1)..lineTo(c.dx + 1, c.dy + 1)..lineTo(d.dx + 1, d.dy + 1)..close();
    canvas.drawPath(sombraCorpo, Paint()..color = Colors.black.withValues(alpha: 0.30));
    final lado = Path()..moveTo(b.dx, b.dy)..lineTo(bz.dx, bz.dy)..lineTo(cz.dx, cz.dy)..lineTo(c.dx, c.dy)..close();
    canvas.drawPath(lado, Paint()..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [estilo.madeira, Color.lerp(estilo.madeira, estilo.madeiraEscura, 0.5)!, estilo.madeiraEscura]).createShader(lado.getBounds()));
    canvas.drawPath(lado, Paint()..color = const Color(0xFF2A1608)..style = PaintingStyle.stroke..strokeWidth = 1.1);
    final vincoL = Paint()..color = const Color(0xFF2A1608).withValues(alpha: 0.4)..strokeWidth = 1.0..style = PaintingStyle.stroke;
    for (final zz in const [10.0, 20.0]) {
      final p1 = _proj(_larg / 2, 0, zz);
      final p2 = _proj(_larg / 2, -_alt, zz);
      canvas.drawLine(p1, p2, vincoL);
    }
    _faixaOuroQuad(canvas, _proj(_larg / 2, -1.2, 0), _proj(_larg / 2, -1.2, _prof), _proj(_larg / 2, -4.6, _prof), _proj(_larg / 2, -4.6, 0), claro: false);
    _faixaOuroQuad(canvas, _proj(_larg / 2, -_alt + 3.4, 0), _proj(_larg / 2, -_alt + 3.4, _prof), cz, c, claro: false);
    final zMeio = _prof / 2;
    _faixaOuroQuad(canvas, _proj(_larg / 2, -3, zMeio - 3.4), _proj(_larg / 2, -3, zMeio + 3.4), _proj(_larg / 2, -_alt + 4, zMeio + 3.4), _proj(_larg / 2, -_alt + 4, zMeio - 3.4));
    _rebite(canvas, _proj(_larg / 2, -8, zMeio));
    _rebite(canvas, _proj(_larg / 2, -_alt + 8, zMeio));
    final frente = Path()..moveTo(a.dx, a.dy)..lineTo(b.dx, b.dy)..lineTo(c.dx, c.dy)..lineTo(d.dx, d.dy)..close();
    canvas.drawPath(frente, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.lerp(estilo.madeira, Colors.white, 0.14)!, estilo.madeira, Color.lerp(estilo.madeira, estilo.madeiraEscura, 0.6)!, estilo.madeiraEscura], stops: const [0.0, 0.4, 0.78, 1.0]).createShader(frente.getBounds()));
    canvas.drawPath(frente, Paint()..color = const Color(0xFF2A1608)..style = PaintingStyle.stroke..strokeWidth = 1.3);
    canvas.drawLine(b, c, Paint()..color = Colors.black.withValues(alpha: 0.4)..strokeWidth = 1.4);
    final vinco = Paint()..color = const Color(0xFF2A1608).withValues(alpha: 0.4)..strokeWidth = 1.2..style = PaintingStyle.stroke;
    final vincoLuz = Paint()..color = Colors.white.withValues(alpha: 0.07)..strokeWidth = 0.9..style = PaintingStyle.stroke;
    for (final fx in const [-0.167, 0.0, 0.167]) {
      final x = fx * _larg;
      final p1 = _proj(x, -1, 0);
      final p2 = _proj(x, -_alt + 1, 0);
      canvas.drawLine(p1, p2, vinco);
      canvas.drawLine(p1 + const Offset(0.9, 0), p2 + const Offset(0.9, 0), vincoLuz);
    }
    final veio = Paint()..color = Colors.white.withValues(alpha: 0.05)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    for (final yy in const [-14.0, -26.0]) {
      final path = Path()..moveTo(_proj(-_larg / 2 + 5, yy, 0).dx, _proj(-_larg / 2 + 5, yy, 0).dy);
      for (var x = -_larg / 2 + 5; x < _larg / 2 - 4; x += 6) {
        final pt = _proj(x, yy + 1.2 * sin(x / 9), 0);
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, veio);
    }
    _faixaOuroQuad(canvas, a, b, _proj(_larg / 2, -4.4, 0), _proj(-_larg / 2, -4.4, 0));
    _faixaOuroQuad(canvas, _proj(-_larg / 2, -_alt + 3.4, 0), _proj(_larg / 2, -_alt + 3.4, 0), c, d, claro: false);
    for (final fx in const [-0.30, 0.30]) {
      final x = fx * _larg;
      _faixaOuroQuad(canvas, _proj(x - 3.6, -2, 0), _proj(x + 3.6, -2, 0), _proj(x + 3.6, -_alt + 4, 0), _proj(x - 3.6, -_alt + 4, 0));
      _rebite(canvas, _proj(x, -8.5, 0));
      _rebite(canvas, _proj(x, -_alt / 2, 0));
      _rebite(canvas, _proj(x, -_alt + 8.5, 0));
    }
  }
  void _faixaOuroQuad(Canvas canvas, Offset p1, Offset p2, Offset p3, Offset p4, {bool claro = true}) {
    final path = Path()..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..lineTo(p4.dx, p4.dy)..close();
    canvas.drawPath(path, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: claro ? [Color.lerp(estilo.ouro, Colors.white, 0.35)!, estilo.ouro, estilo.ouroEscuro] : [estilo.ouro, estilo.ouroEscuro, const Color(0xFF7A5806)]).createShader(path.getBounds()));
    canvas.drawPath(path, Paint()..color = const Color(0xFF4A3205).withValues(alpha: 0.8)..style = PaintingStyle.stroke..strokeWidth = 0.7);
  }
  void _rebite(Canvas canvas, Offset c) {
    canvas.drawCircle(c + const Offset(0.5, 0.6), 1.9, Paint()..color = Colors.black.withValues(alpha: 0.4));
    canvas.drawCircle(c, 1.8, Paint()..shader = RadialGradient(center: const Alignment(-0.4, -0.45), colors: [Color.lerp(estilo.ouro, Colors.white, 0.5)!, estilo.ouro, estilo.ouroEscuro]).createShader(Rect.fromCircle(center: c, radius: 1.8)));
    canvas.drawCircle(c + const Offset(-0.4, -0.5), 0.7, Paint()..color = Colors.white.withValues(alpha: 0.9));
  }
  void _derramado(Canvas canvas, double th) {
    if (th < 1.0) return;
    final f = ((th - 1.0) / 0.55).clamp(0.0, 1.0);
    _moeda3d(canvas, _proj(-24, -_alt + 0.5 - 1.5 * f, -6 - 3 * f), 0.9);
    _moeda3d(canvas, _proj(2, -_alt + 0.2 - 1.0 * f, -8 - 4 * f), 1.0);
    _moeda3d(canvas, _proj(22, -_alt + 0.6 - 1.8 * f, -5 - 2.5 * f), 0.86);
  }
  void _cadeado(Canvas canvas) {
    final c = _proj(0, -_alt * 0.30, 0);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    final placa = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 13.5, height: 11), const Radius.circular(3));
    canvas.drawRRect(placa.shift(const Offset(0.6, 0.9)), Paint()..color = Colors.black.withValues(alpha: 0.35));
    canvas.drawRRect(placa, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.lerp(estilo.ouro, Colors.white, 0.34)!, estilo.ouro, estilo.ouroEscuro]).createShader(placa.outerRect));
    canvas.drawRRect(placa, Paint()..color = const Color(0xFF4A3205)..style = PaintingStyle.stroke..strokeWidth = 1.2);
    canvas.drawCircle(const Offset(0, -1.2), 1.9, Paint()..color = estilo.interior);
    canvas.drawPath(Path()..moveTo(-1.4, -0.6)..lineTo(1.4, -0.6)..lineTo(0, 3.2)..close(), Paint()..color = estilo.interior);
    canvas.drawArc(Rect.fromCircle(center: const Offset(0, -5.2), radius: 4.2), pi, pi, false, Paint()..color = estilo.ouroEscuro..style = PaintingStyle.stroke..strokeWidth = 2.6);
    canvas.restore();
  }
  void _tampa(Canvas canvas, double th) {
    const n = 12;
    final xl = -_larg / 2;
    final xr = _larg / 2;
    double arcoY(double t) => _raioT * sin(t);
    double arcoZ(double t) => _prof / 2 - _raioT * cos(t);
    if (th > 0.12) {
      final ri = _raioT - _espT;
      for (var i = 0; i < n; i++) {
        final t0 = pi * i / n;
        final t1 = pi * (i + 1) / n;
        final q = Path()..moveTo(_lid(xl, ri * sin(t0), _prof / 2 - ri * cos(t0)).dx, _lid(xl, ri * sin(t0), _prof / 2 - ri * cos(t0)).dy)..lineTo(_lid(xr, ri * sin(t0), _prof / 2 - ri * cos(t0)).dx, _lid(xr, ri * sin(t0), _prof / 2 - ri * cos(t0)).dy)..lineTo(_lid(xr, ri * sin(t1), _prof / 2 - ri * cos(t1)).dx, _lid(xr, ri * sin(t1), _prof / 2 - ri * cos(t1)).dy)..lineTo(_lid(xl, ri * sin(t1), _prof / 2 - ri * cos(t1)).dx, _lid(xl, ri * sin(t1), _prof / 2 - ri * cos(t1)).dy)..close();
        canvas.drawPath(q, Paint()..color = const Color(0xFF5A3418));
      }
      final nerv = Paint()..color = estilo.ouroEscuro.withValues(alpha: 0.75)..style = PaintingStyle.stroke..strokeWidth = 1.2;
      for (final tt in const [0.35, 0.65]) {
        final path = Path();
        final pIni = _lid(xl, (_raioT - _espT) * sin(pi * tt), _prof / 2 - (_raioT - _espT) * cos(pi * tt));
        path.moveTo(pIni.dx, pIni.dy);
        for (var x = xl + 4; x <= xr; x += 5) {
          final pt = _lid(x, (_raioT - _espT) * sin(pi * tt), _prof / 2 - (_raioT - _espT) * cos(pi * tt));
          path.lineTo(pt.dx, pt.dy);
        }
        canvas.drawPath(path, nerv);
      }
      final saiaInt = Path()..moveTo(_lid(xl, 0, 0).dx, _lid(xl, 0, 0).dy)..lineTo(_lid(xr, 0, 0).dx, _lid(xr, 0, 0).dy)..lineTo(_lid(xr, 0, -0.01).dx, _lid(xr, 0, -0.01).dy)..lineTo(_lid(xl, 0, -0.01).dx, _lid(xl, 0, -0.01).dy)..close();
      canvas.drawPath(saiaInt, Paint()..color = const Color(0xFF4A2A12));
    }
    final cap = Path()..moveTo(_lid(xr, 0, 0).dx, _lid(xr, 0, 0).dy);
    for (var i = 1; i <= n; i++) {
      final t = pi * i / n;
      final pt = _lid(xr, arcoY(t), arcoZ(t));
      cap.lineTo(pt.dx, pt.dy);
    }
    cap.lineTo(_lid(xr, 0, _prof).dx, _lid(xr, 0, _prof).dy);
    cap.close();
    canvas.drawPath(cap, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: const [Color(0xFF8E5A24), Color(0xFF5A3418), Color(0xFF3A1F0A)]).createShader(cap.getBounds()));
    canvas.drawPath(cap, Paint()..color = const Color(0xFF2A1608)..style = PaintingStyle.stroke..strokeWidth = 1.1);
    final aro = Paint()..color = estilo.ouro..style = PaintingStyle.stroke..strokeWidth = 2.2;
    final aroPath = Path();
    final aroIni = _lid(xr + 0.6, arcoY(0.08), arcoZ(0.08));
    aroPath.moveTo(aroIni.dx, aroIni.dy);
    for (var i = 1; i <= n; i++) {
      final t = 0.08 + (pi - 0.16) * i / n;
      final pt = _lid(xr + 0.6, arcoY(t), arcoZ(t));
      aroPath.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(aroPath, aro);
    _rebite(canvas, _lid(xr + 0.8, arcoY(pi / 2), arcoZ(pi / 2)));
    for (var i = 0; i < n; i++) {
      final t0 = pi * i / n;
      final t1 = pi * (i + 1) / n;
      final q = Path()..moveTo(_lid(xl, arcoY(t0), arcoZ(t0)).dx, _lid(xl, arcoY(t0), arcoZ(t0)).dy)..lineTo(_lid(xr, arcoY(t0), arcoZ(t0)).dx, _lid(xr, arcoY(t0), arcoZ(t0)).dy)..lineTo(_lid(xr, arcoY(t1), arcoZ(t1)).dx, _lid(xr, arcoY(t1), arcoZ(t1)).dy)..lineTo(_lid(xl, arcoY(t1), arcoZ(t1)).dx, _lid(xl, arcoY(t1), arcoZ(t1)).dy)..close();
      final tm = (t0 + t1) / 2;
      final lum = 0.45 + 0.55 * sin(tm * 0.85 + 0.42);
      final cor = Color.lerp(const Color(0xFF4E2E14), const Color(0xFFC98A44), lum)!;
      canvas.drawPath(q, Paint()..color = Color.lerp(cor, estilo.madeira, 0.35)!);
      canvas.drawPath(q, Paint()..color = const Color(0xFF2A1608).withValues(alpha: 0.35)..style = PaintingStyle.stroke..strokeWidth = 0.5);
    }
    final vinco = Paint()..color = const Color(0xFF2A1608).withValues(alpha: 0.35)..strokeWidth = 0.9..style = PaintingStyle.stroke;
    for (final fx in const [-0.167, 0.0, 0.167]) {
      final path = Path();
      final x = fx * _larg;
      final ini = _lid(x, arcoY(0.06), arcoZ(0.06));
      path.moveTo(ini.dx, ini.dy);
      for (var i = 1; i <= n; i++) {
        final t = 0.06 + (pi - 0.12) * i / n;
        final pt = _lid(x, arcoY(t), arcoZ(t));
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(path, vinco);
    }
    for (final fx in const [-0.30, 0.30]) {
      final x0 = fx * _larg - 3.4;
      final x1 = fx * _larg + 3.4;
      final path = Path();
      final ini = _lid(x0, arcoY(0.05), arcoZ(0.05));
      path.moveTo(ini.dx, ini.dy);
      for (var i = 1; i <= n; i++) {
        final t = 0.05 + (pi - 0.10) * i / n;
        final pt = _lid(x0, arcoY(t), arcoZ(t));
        path.lineTo(pt.dx, pt.dy);
      }
      for (var i = n; i >= 0; i--) {
        final t = 0.05 + (pi - 0.10) * i / n;
        final pt = _lid(x1, arcoY(t), arcoZ(t));
        path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.lerp(estilo.ouro, Colors.white, 0.3)!, estilo.ouro, estilo.ouroEscuro]).createShader(path.getBounds()));
      canvas.drawPath(path, Paint()..color = const Color(0xFF4A3205).withValues(alpha: 0.8)..style = PaintingStyle.stroke..strokeWidth = 0.7);
      _rebite(canvas, _lid((fx * _larg), arcoY(pi / 2), arcoZ(pi / 2)));
      _rebite(canvas, _lid((fx * _larg), arcoY(0.18), arcoZ(0.18)));
    }
    final saia = Path()..moveTo(_lid(xl, 0, 0).dx, _lid(xl, 0, 0).dy)..lineTo(_lid(xr, 0, 0).dx, _lid(xr, 0, 0).dy)..lineTo(_lid(xr, -_saia, 0).dx, _lid(xr, -_saia, 0).dy)..lineTo(_lid(xl, -_saia, 0).dx, _lid(xl, -_saia, 0).dy)..close();
    canvas.drawPath(saia, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color.lerp(estilo.madeira, Colors.white, 0.1)!, estilo.madeira]).createShader(saia.getBounds()));
    canvas.drawPath(saia, Paint()..color = const Color(0xFF2A1608)..style = PaintingStyle.stroke..strokeWidth = 0.9);
    final friso = Path()..moveTo(_lid(xl, -1.4, 0).dx, _lid(xl, -1.4, 0).dy)..lineTo(_lid(xr, -1.4, 0).dx, _lid(xr, -1.4, 0).dy)..lineTo(_lid(xr, -3.4, 0).dx, _lid(xr, -3.4, 0).dy)..lineTo(_lid(xl, -3.4, 0).dx, _lid(xl, -3.4, 0).dy)..close();
    canvas.drawPath(friso, Paint()..shader = LinearGradient(colors: [Color.lerp(estilo.ouro, Colors.white, 0.35)!, estilo.ouro, estilo.ouroEscuro]).createShader(friso.getBounds()));
    if (cos(_theta) > 0.30) {
      final cB = _lid(0, _raioT * sin(pi * 0.30), _prof / 2 - _raioT * cos(pi * 0.30));
      final s = 0.6 + 0.4 * cos(_theta);
      canvas.save(); canvas.translate(cB.dx, cB.dy); canvas.scale(s, s * 0.9); canvas.rotate(pi / 4);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 8.4, height: 8.4), const Radius.circular(1.2)), Paint()..shader = LinearGradient(colors: [Color.lerp(estilo.ouro, Colors.white, 0.32)!, estilo.ouroEscuro]).createShader(Rect.fromCenter(center: Offset.zero, width: 8.4, height: 8.4)));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 8.4, height: 8.4), const Radius.circular(1.2)), Paint()..color = const Color(0xFF4A3205)..style = PaintingStyle.stroke..strokeWidth = 0.8);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 3.8, height: 3.8), Paint()..color = const Color(0xFF7A5806)); canvas.restore();
    }
    final cont = Paint()..color = Colors.white.withValues(alpha: 0.16 * cos(_theta).clamp(0.0, 1.0))..style = PaintingStyle.stroke..strokeWidth = 1.6;
    final contPath = Path();
    final contIni = _lid(xl, _raioT * sin(pi * 0.38), _prof / 2 - _raioT * cos(pi * 0.38));
    contPath.moveTo(contIni.dx, contIni.dy);
    for (var i = 1; i <= 6; i++) {
      final pt = _lid(xl + (xr - xl) * i / 6, _raioT * sin(pi * 0.42), _prof / 2 - _raioT * cos(pi * 0.42));
      contPath.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(contPath, cont);
  }
  @override
  bool shouldRepaint(BauBausPainter old) => old.p != p || old.estilo != estilo;
}
