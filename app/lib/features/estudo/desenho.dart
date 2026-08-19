import 'package:flutter/material.dart';

/// Componentes de "escrever/rabiscar na tela" (caderno), compartilhados entre a
/// tela de palavras (EstudoScreen) e a de contas (ContaEstudoScreen): um traço,
/// o painter, a bolinha de seleção (cor de fundo/caneta) e o botão de ícone.

/// Um traço desenhado (uma "canetada" contínua): pontos + cor.
class Traco {
  Traco(this.cor);
  final Color cor;
  final List<Offset> pontos = [];
}

/// Desenha os traços por cima do conteúdo (a "camada de caderno").
class DesenhoPainter extends CustomPainter {
  DesenhoPainter(this.tracos);
  final List<Traco> tracos;

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
  bool shouldRepaint(DesenhoPainter old) => true;
}

/// Bolinha de seleção (cor de fundo ou de caneta). `contraste` = cor do texto
/// atual, usada na borda para a bolinha aparecer em qualquer fundo.
class BolinhaCor extends StatelessWidget {
  const BolinhaCor({
    super.key,
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

/// Botão de ícone só (o "limpar"/"desfazer" da coluna de canetas).
class BotaoIconeDesenho extends StatelessWidget {
  const BotaoIconeDesenho({
    super.key,
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
