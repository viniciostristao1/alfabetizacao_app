import 'package:alfabetizacao/models/futebol_posicao.dart';
import 'package:flutter_test/flutter_test.dart';

/// Invariantes do quiz das posições (jogo do Davi): cada pergunta tem ao
/// menos um pino, cada pino pertence a uma pergunta e todos os pinos estão
/// dentro da foto (fração 0..1) — assim o sorteio nunca quebra e os pinos
/// acompanham a imagem em qualquer tela.
void main() {
  test('6 posições únicas no quiz', () {
    expect(kOrdemPosicoes.length, 6);
    expect(kOrdemPosicoes.toSet().length, 6);
  });

  test('todo pino pertence a uma pergunta e vice-versa', () {
    for (final pino in kPinosCampo) {
      expect(kOrdemPosicoes, contains(pino.palavra),
          reason: 'pino ${pino.rotuloLousa} sem pergunta');
    }
    for (final palavra in kOrdemPosicoes) {
      expect(pinosDe(palavra), isNotEmpty, reason: '$palavra sem pino');
    }
  });

  test('pinos dentro da foto (0..1)', () {
    for (final pino in kPinosCampo) {
      expect(pino.fx, inInclusiveRange(0.0, 1.0));
      expect(pino.fy, inInclusiveRange(0.0, 1.0));
    }
  });
}
