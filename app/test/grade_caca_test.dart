import 'dart:math';

import 'package:alfabetizacao/models/categoria.dart';
import 'package:alfabetizacao/models/palavra.dart';
import 'package:alfabetizacao/services/banco_palavras.dart';
import 'package:alfabetizacao/services/grade_caca.dart';
import 'package:flutter_test/flutter_test.dart';

/// Conta quantas vezes a forma de grade aparece na grade, só nas direções
/// permitidas (prova de que a palavra está achável).
int _ocorrencias(GradeCaca g, String forma, Set<Direcao> dirs) {
  var n = 0;
  for (var r = 0; r < g.tamanho; r++) {
    for (var c = 0; c < g.tamanho; c++) {
      for (final d in dirs) {
        final rf = r + d.dr * (forma.length - 1);
        final cf = c + d.dc * (forma.length - 1);
        if (rf < 0 || rf >= g.tamanho || cf < 0 || cf >= g.tamanho) continue;
        var ok = true;
        for (var k = 0; k < forma.length; k++) {
          if (g.celulas[r + d.dr * k][c + d.dc * k] != forma[k]) {
            ok = false;
            break;
          }
        }
        if (ok) n++;
      }
    }
  }
  return n;
}

void main() {
  group('pool por tema e nível (cuidado 3 da T004)', () {
    const temas = [
      Categoria.animais,
      Categoria.objetos,
      Categoria.alimentos,
      Categoria.nomes,
      Categoria.espaco,
      Categoria.futebol,
    ];
    test('fácil tem 3+ palavras em todo tema', () {
      for (final t in temas) {
        expect(palavrasParaCaca(t, Nivel.facil).length, greaterThanOrEqualTo(3),
            reason: 'fácil/$t');
      }
    });
    test('médio tem 4+ palavras em todo tema', () {
      for (final t in temas) {
        expect(palavrasParaCaca(t, Nivel.media).length, greaterThanOrEqualTo(4),
            reason: 'médio/$t');
      }
    });
    test('difícil tem 5 palavras em todo tema', () {
      for (final t in temas) {
        expect(
            palavrasParaCaca(t, Nivel.dificil).length, greaterThanOrEqualTo(5),
            reason: 'difícil/$t');
      }
    });
    test('Futebol difícil (decisão T004-a): 2 de 4 sílabas + 3 de 3 sílabas',
        () {
      final pool = palavrasParaCaca(Categoria.futebol, Nivel.dificil);
      final grades = pool.map((p) => textoGradeDe(p.texto)).toList();
      expect(pool.length, 5);
      // As 2 de 4 sílabas que cabem em 8.
      expect(grades, containsAll(['CAMISETA', 'ATACANTE']));
      // As 3 de 3 sílabas mais longas (8 letras).
      expect(grades, containsAll(['BANDEIRA', 'ZAGUEIRO', 'INGRESSO']));
      // Nenhuma com espaço/hífen e nenhuma maior que a grade 8.
      for (final p in pool) {
        expect(p.texto.contains(' '), isFalse);
        expect(p.texto.contains('-'), isFalse);
      }
      for (final g in grades) {
        expect(g.length, lessThanOrEqualTo(8));
      }
    });
  });

  group('gerarGrade', () {
    List<Palavra> mini() => [
          const Palavra(['ga', 'to'], Categoria.futebol),
          const Palavra(['bo', 'la'], Categoria.futebol),
          const Palavra(['sol'], Categoria.futebol),
          const Palavra(['lu', 'a'], Categoria.espaco),
          const Palavra(['gol'], Categoria.futebol),
          const Palavra(['mar'], Categoria.espaco),
        ];

    test('determinística com semente', () {
      GradeCaca uma(int seed) => gerarGrade(mini(),
          tamanho: 6,
          direcoes: Direcao.paraFrente2,
          nPalavras: 3,
          rng: Random(seed));
      final a = uma(7);
      final b = uma(7);
      expect(
          a.celulas.map((l) => l.join()).toList(),
          b.celulas.map((l) => l.join()).toList());
      expect(a.escondidas.map((e) => e.grade).toList(),
          b.escondidas.map((e) => e.grade).toList());
    });

    test('todas as pedidas presentes e acháveis na grade', () {
      for (var seed = 0; seed < 20; seed++) {
        final g = gerarGrade(mini(),
            tamanho: 6,
            direcoes: Direcao.todas8,
            nPalavras: 4,
            rng: Random(seed));
        expect(g.escondidas.length, 4);
        for (final e in g.escondidas) {
          expect(_ocorrencias(g, e.grade, Direcao.todas8),
              greaterThanOrEqualTo(1),
              reason: 'seed $seed, ${e.grade} sumiu da grade');
        }
      }
    });

    test('sem estouro: tudo dentro de 0..tamanho-1, 1 letra por célula', () {
      for (final tam in [6, 7, 8]) {
        final g = gerarGrade(mini(),
            tamanho: tam,
            direcoes: Direcao.todas8,
            nPalavras: 4,
            rng: Random(3));
        expect(g.celulas.length, tam);
        for (final linha in g.celulas) {
          expect(linha.length, tam);
          for (final letra in linha) {
            expect(letra.length, 1);
          }
        }
        for (final e in g.escondidas) {
          for (final p in e.celulas) {
            expect(p.r, inInclusiveRange(0, tam - 1));
            expect(p.c, inInclusiveRange(0, tam - 1));
          }
        }
      }
    });

    test('acentos e cedilha: grade sem acento, lista com acento', () {
      final pool = [
        const Palavra(['a', 'gua'], Categoria.alimentos, texto: 'água'),
        const Palavra(['ma', 'ca'], Categoria.alimentos, texto: 'maçã'),
        const Palavra(['la', 'ran', 'ja'], Categoria.alimentos,
            texto: 'laranja'),
      ];
      final g = gerarGrade(pool,
          tamanho: 8,
          direcoes: Direcao.paraFrente4,
          nPalavras: 3,
          rng: Random(11));
      expect(g.escondidas.length, 3);
      final grades = g.escondidas.map((e) => e.grade).toSet();
      expect(grades, containsAll(['AGUA', 'MACA', 'LARANJA']));
      // A lista mostra o original com acento.
      final textos = g.escondidas.map((e) => e.texto).toSet();
      expect(textos, containsAll(['água', 'maçã', 'laranja']));
      // Comparação bate via semAcento.
      for (final e in g.escondidas) {
        expect(textoGradeDe(e.texto), e.grade);
      }
    });

    test('palavras com K/W/Y entram normalmente (só o recheio evita)', () {
      final pool = [
        const Palavra(['ki', 'wi'], Categoria.alimentos),
        const Palavra(['chan', 'ti', 'lly'], Categoria.objetos),
        const Palavra(['ga', 'to'], Categoria.futebol),
      ];
      final g = gerarGrade(pool,
          tamanho: 10,
          direcoes: Direcao.paraFrente4,
          nPalavras: 3,
          rng: Random(5));
      expect(
          g.escondidas.map((e) => e.grade).toSet(),
          containsAll(
              ['KIWI', textoGradeDe('chantilly'), 'GATO']));
      // O recheio aleatório nunca usa K, W ou Y.
      final usadas = g.escondidas.map((e) => e.grade).toSet();
      for (var r = 0; r < g.tamanho; r++) {
        for (var c = 0; c < g.tamanho; c++) {
          final emPalavra = g.escondidas.any((e) =>
              e.celulas.any((p) => p.r == r && p.c == c && usadas.contains(e.grade)));
          if (!emPalavra) {
            expect('KWY'.contains(g.celulas[r][c]), isFalse,
                reason: 'recheio com K/W/Y em ($r,$c)');
          }
        }
      }
    });

    test('banco pequeno: usa o que houver, sem repetir nem quebrar', () {
      final pool = [
        const Palavra(['ga', 'to'], Categoria.futebol),
        const Palavra(['bo', 'la'], Categoria.futebol),
      ];
      final g = gerarGrade(pool,
          tamanho: 6,
          direcoes: Direcao.paraFrente2,
          nPalavras: 5,
          rng: Random(1));
      expect(g.escondidas.length, 2);
      expect(
          g.escondidas.map((e) => e.grade).toSet(), {'GATO', 'BOLA'});
    });

    test('50 seeds por nível: sem sobreposição inválida e tudo achável', () {
      final configs = [
        (Nivel.facil, 20),
        (Nivel.media, 20),
        (Nivel.dificil, 10),
      ];
      for (final (nivel, seeds) in configs) {
        final tam = tamanhoParaNivel(nivel);
        final dirs = direcoesParaNivel(nivel);
        final n = nPalavrasParaNivel(nivel);
        for (final tema in [
          Categoria.animais,
          Categoria.objetos,
          Categoria.alimentos,
          Categoria.nomes,
          Categoria.espaco,
          Categoria.futebol,
        ]) {
          final pool = palavrasParaCaca(tema, nivel);
          for (var seed = 0; seed < seeds; seed++) {
            final g = gerarGrade(pool,
                tamanho: tam,
                direcoes: dirs,
                nPalavras: n,
                rng: Random(seed));
            expect(g.escondidas.length, n,
                reason: '$tema/$nivel seed $seed');
            for (final e in g.escondidas) {
              expect(_ocorrencias(g, e.grade, dirs), greaterThanOrEqualTo(1),
                  reason: '$tema/$nivel seed $seed ${e.grade}');
            }
          }
        }
      }
    });
  });

  group('seleção (lógica pura do arrasto)', () {
    final dirs = Direcao.todas8;
    final escondidas = [
      const PalavraEscondida(
          texto: 'gato',
          grade: 'GATO',
          celulas: [Pos(0, 0), Pos(0, 1), Pos(0, 2), Pos(0, 3)]),
      const PalavraEscondida(
          texto: 'sol',
          grade: 'SOL',
          celulas: [Pos(1, 1), Pos(2, 1), Pos(3, 1)]),
    ];

    test('normalizarArrasto trava em linha reta (desvio gruda no eixo)', () {
      // Quase horizontal com desvio: gruda no Leste.
      expect(normalizarArrasto(const Pos(0, 0), 0.4, 3.2, dirs),
          [const Pos(0, 0), const Pos(0, 1), const Pos(0, 2), const Pos(0, 3)]);
      // Vertical.
      expect(normalizarArrasto(const Pos(1, 1), 2.7, 0.2, dirs),
          [const Pos(1, 1), const Pos(2, 1), const Pos(3, 1)]);
      // Diagonal (2.1, 2.4): projeção 3.18 -> 3 passos, 4 células.
      expect(normalizarArrasto(const Pos(0, 0), 2.1, 2.4, dirs), [
        const Pos(0, 0),
        const Pos(1, 1),
        const Pos(2, 2),
        const Pos(3, 3)
      ]);
      // Parado: só a âncora.
      expect(normalizarArrasto(const Pos(2, 2), 0.0, 0.0, dirs),
          [const Pos(2, 2)]);
      // Fácil ignora diagonal: eixo dominante vence.
      expect(
          normalizarArrasto(
              const Pos(0, 0), 1.2, 2.9, Direcao.paraFrente2),
          [const Pos(0, 0), const Pos(0, 1), const Pos(0, 2)]);
    });

    test('conferirSelecao: direta e inversa acertam; resto erra', () {
      expect(
          conferirSelecao(
              [const Pos(0, 0), const Pos(0, 1), const Pos(0, 2), const Pos(0, 3)],
              escondidas)!
              .grade,
          'GATO');
      // Inverso vale em todos os níveis (decisão T004).
      expect(
          conferirSelecao(
              [const Pos(0, 3), const Pos(0, 2), const Pos(0, 1), const Pos(0, 0)],
              escondidas)!
              .grade,
          'GATO');
      // Trecho curto ou de outra palavra: nulo.
      expect(conferirSelecao([const Pos(0, 0), const Pos(0, 1)], escondidas),
          isNull);
      expect(
          conferirSelecao(
              [const Pos(5, 5), const Pos(5, 6)], escondidas),
          isNull);
    });
  });
}
