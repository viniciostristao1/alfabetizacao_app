import 'package:alfabetizacao/services/reconhecimento.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('reconheceu (Modo Microfone — comparação tolerante)', () {
    test('acerto exato', () {
      expect(reconheceu('gato', ['gato']), isTrue);
    });

    test('ignora acento e caixa', () {
      expect(reconheceu('águia', ['AGUIA']), isTrue);
      expect(reconheceu('leão', ['leao']), isTrue);
    });

    test('perdoa ~1 letra quando a inicial bate (gato ↔ gatu)', () {
      expect(reconheceu('gato', ['gatu']), isTrue);
    });

    test('recusa palavra de inicial diferente a 1 letra (gato ✗ pato)', () {
      expect(reconheceu('gato', ['pato']), isFalse);
    });

    test('recusa palavra não relacionada', () {
      expect(reconheceu('gato', ['bola']), isFalse);
      expect(reconheceu('gato', ['cachorro']), isFalse);
    });

    test('acha a palavra entre as alternativas do motor', () {
      expect(reconheceu('bola', ['fola', 'bola', 'gola']), isTrue);
    });

    test('artigo grudado não estraga (o gato → gato)', () {
      expect(reconheceu('gato', ['o gato']), isTrue);
    });

    test('palavra com espaço/hífen (urso polar, beija-flor)', () {
      expect(reconheceu('urso polar', ['urso polar']), isTrue);
      expect(reconheceu('beija-flor', ['beija flor']), isTrue);
    });

    test('tolerância 0 exige exato', () {
      expect(reconheceu('gato', ['gatu'], tolerancia: 0), isFalse);
      expect(reconheceu('gato', ['gato'], tolerancia: 0), isTrue);
    });

    test('lista vazia ou alvo vazio → não acerta', () {
      expect(reconheceu('gato', const []), isFalse);
      expect(reconheceu('', ['gato']), isFalse);
    });
  });

  group('levenshtein', () {
    test('distâncias conhecidas', () {
      expect(levenshtein('gato', 'gato'), 0);
      expect(levenshtein('gato', 'gatu'), 1);
      expect(levenshtein('gato', 'pato'), 1);
      expect(levenshtein('gato', 'rato'), 1);
      expect(levenshtein('gato', ''), 4);
    });
  });
}
