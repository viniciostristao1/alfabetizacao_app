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

  group('reconheceuFrase (Modo Frases — frase inteira, em ordem)', () {
    const frase = 'O OVO É DA GALINHA';
    const tema = 'OVO';

    test('frase completa acerta (caixa diferente)', () {
      expect(reconheceuFrase(frase, tema, ['o ovo é da galinha']), isTrue);
      expect(reconheceuFrase(frase, tema, ['O OVO É DA GALINHA']), isTrue);
    });

    test('variações dentro da tolerância acertam', () {
      // motor trocou 1 letra (galinha→galina) e 1 curta (é→e)
      expect(reconheceuFrase(frase, tema, ['o ovo e da galina']), isTrue);
      // faltou 1 curta (é) — permitido
      expect(reconheceuFrase(frase, tema, ['o ovo da galinha']), isTrue);
      // recheio antes não estraga
      expect(reconheceuFrase(frase, tema, ['ah o ovo é da galinha']), isTrue);
    });

    test('só a palavra do tema erra', () {
      expect(reconheceuFrase(frase, tema, ['ovo']), isFalse);
      expect(reconheceuFrase(frase, tema, ['o ovo']), isFalse);
      expect(reconheceuFrase(frase, tema, ['galinha']), isFalse);
    });

    test('T008: "O pato nada na lagoa" — só o tema ou pedaços erram', () {
      const f = 'O pato nada na lagoa';
      const t = 'pato';
      for (final tol in [0, 1, 2]) {
        expect(reconheceuFrase(f, t, ['pato'], tolerancia: tol), isFalse,
            reason: 'tol $tol');
        expect(reconheceuFrase(f, t, ['o pato'], tolerancia: tol), isFalse,
            reason: 'tol $tol');
        expect(reconheceuFrase(f, t, ['pato nada'], tolerancia: tol), isFalse,
            reason: 'tol $tol');
        expect(
            reconheceuFrase(f, t, ['pato nada lagoa'], tolerancia: tol),
            isFalse,
            reason: 'tol $tol');
        expect(
            reconheceuFrase(f, t, ['o pato nada na lagoa'],
                tolerancia: tol),
            isTrue,
            reason: 'tol $tol');
      }
    });

    test('frase muito incompleta erra', () {
      expect(reconheceuFrase(frase, tema, ['o ovo é']), isFalse);
      expect(reconheceuFrase(frase, tema, ['é da galinha']), isFalse);
    });

    test('palavra-chave errada erra', () {
      expect(reconheceuFrase(frase, tema, ['o ovo é da pata']), isFalse);
    });

    test('ordem trocada erra', () {
      expect(reconheceuFrase(frase, tema, ['galinha ovo da é o']), isFalse);
    });

    test('frase sem palavra de 3+ letras exige todas', () {
      expect(reconheceuFrase('É O PÉ', 'PÉ', ['é o pé']), isTrue);
      // "a" no lugar de "o": curta, mas sem folga quando só há curtas
      expect(reconheceuFrase('É O PÉ', 'PÉ', ['é a pé']), isFalse);
      expect(reconheceuFrase('É O PÉ', 'PÉ', ['é o']), isFalse);
    });

    test('palavra repetida: ordem e contagem funcionam', () {
      const f = 'O PATO VIU O PATO';
      expect(reconheceuFrase(f, 'PATO', ['o pato viu o pato']), isTrue);
      // só um PATO (o segundo, cheio, faltou) → erra
      expect(reconheceuFrase(f, 'PATO', ['o pato viu o']), isFalse);
      // repetição sobrando no fim não estraga
      expect(reconheceuFrase(f, 'PATO', ['o pato viu o pato pato']), isTrue);
    });

    test('tolerância 0 exige palavras exatas (ainda ignora caixa)', () {
      expect(
          reconheceuFrase(frase, tema, ['o ovo é da galinha'],
              tolerancia: 0),
          isTrue);
      expect(
          reconheceuFrase(frase, tema, ['o ovo e da galina'], tolerancia: 0),
          isFalse);
    });

    test('frase ou tema vazios → não acerta', () {
      expect(reconheceuFrase('', tema, ['o ovo é da galinha']), isFalse);
      expect(reconheceuFrase(frase, '', ['o ovo é da galinha']), isFalse);
      expect(reconheceuFrase(frase, tema, const []), isFalse);
    });

    test('modo Palavra inalterado: só a palavra continua valendo', () {
      expect(reconheceu('OVO', ['o ovo é da galinha']), isTrue);
      expect(reconheceu('OVO', ['ovo']), isTrue);
    });
  });

  group('palavrasFaltando (dica do "faltou: ...")', () {
    const frase = 'O OVO É DA GALINHA';

    test('frase completa → nada falta', () {
      expect(palavrasFaltando(frase, 'o ovo é da galinha'), isEmpty);
    });

    test('lista o que não foi dito', () {
      expect(palavrasFaltando(frase, 'o ovo'), ['DA', 'GALINHA']);
      expect(palavrasFaltando(frase, 'o ovo é da pata'), ['GALINHA']);
    });
  });
}
