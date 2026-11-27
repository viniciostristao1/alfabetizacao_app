import 'dart:math';

import 'package:alfabetizacao/models/categoria.dart';
import 'package:alfabetizacao/models/palavra.dart';
import 'package:alfabetizacao/services/caca_recentes.dart';
import 'package:alfabetizacao/services/grade_caca.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Palavra> _pool() => [
      const Palavra(['ga', 'to'], Categoria.futebol),
      const Palavra(['bo', 'la'], Categoria.futebol),
      const Palavra(['sol'], Categoria.futebol),
      const Palavra(['lu', 'a'], Categoria.espaco),
      const Palavra(['gol'], Categoria.futebol),
      const Palavra(['mar'], Categoria.espaco),
    ];

void main() {
  group('aplicarRecentes (pura)', () {
    test('sem recentes: devolve tudo', () {
      expect(aplicarRecentes(_pool(), [], 3).length, _pool().length);
    });

    test('tira as recentes; sobrando >= n, usa só as novas', () {
      final filtradas = aplicarRecentes(_pool(), ['gato', 'bola'], 3);
      final textos = filtradas.map((p) => p.texto).toSet();
      expect(textos.contains('gato'), isFalse);
      expect(textos.contains('bola'), isFalse);
      expect(filtradas.length, 4);
    });

    test('faltando palavra: libera as mais antigas primeiro', () {
      // Pool de 4, n = 3, recentes = 3 (sobra 1 < 3): libera 2 antigas.
      // Ordem das recentes: mais nova primeiro (gato); libera do fim.
      final pool = _pool().take(4).toList();
      final filtradas =
          aplicarRecentes(pool, ['gato', 'bola', 'sol'], 3);
      expect(
          filtradas.map((p) => p.texto).toList(), ['lua', 'sol', 'bola']);
    });

    test('tudo recente e pool curto: completa o que der', () {
      final filtradas = aplicarRecentes(
          _pool().take(2).toList(), ['gato', 'bola'], 3);
      expect(filtradas.length, 2);
    });
  });

  group('duas rodadas seguidas sem repetir (18 combos)', () {
    test('rodada 2 disjunta da 1 enquanto o banco permite', () {
      const temas = [
        Categoria.animais,
        Categoria.objetos,
        Categoria.alimentos,
        Categoria.nomes,
        Categoria.espaco,
        Categoria.futebol,
      ];
      for (final nivel in Nivel.values) {
        final tam = tamanhoParaNivel(nivel);
        final dirs = direcoesParaNivel(nivel);
        final n = nPalavrasParaNivel(nivel);
        for (final tema in temas) {
          final pool = palavrasParaCaca(tema, nivel);
          for (var seed = 0; seed < 20; seed++) {
            final g1 = gerarGrade(pool,
                tamanho: tam,
                direcoes: dirs,
                nPalavras: n,
                rng: Random(seed));
            final r1 = g1.escondidas.map((e) => e.texto).toList();
            final pool2 = aplicarRecentes(pool, r1, n);
            final g2 = gerarGrade(pool2,
                tamanho: tam,
                direcoes: dirs,
                nPalavras: n,
                rng: Random(seed + 1000));
            final r2 = g2.escondidas.map((e) => e.texto).toSet();
            // Pool >= 2n em todos os combos: dá para ser disjunta.
            if (pool.length >= 2 * n) {
              expect(r2.intersection(r1.toSet()), isEmpty,
                  reason: '$tema/$nivel seed $seed repetiu: $r1 x $r2');
            }
            expect(g2.escondidas.length, n,
                reason: '$tema/$nivel seed $seed rodada 2 curta');
          }
        }
      }
    });
  });

  testWidgets('memória persiste por tema e nível (chave nova)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await CacaRecentes.guardar(
        Categoria.futebol, Nivel.facil, ['gato', 'bola']);
    await CacaRecentes.guardar(
        Categoria.espaco, Nivel.facil, ['lua']);
    expect(
        await CacaRecentes.carregar(Categoria.futebol, Nivel.facil),
        ['gato', 'bola']);
    expect(await CacaRecentes.carregar(Categoria.espaco, Nivel.facil),
        ['lua']);
    expect(await CacaRecentes.carregar(Categoria.futebol, Nivel.media),
        isEmpty);
    // Nova rodada do mesmo combo substitui a anterior (só a última
    // rodada é lembrada — basta para rodadas seguidas nunca repetirem).
    await CacaRecentes.guardar(
        Categoria.futebol, Nivel.facil, ['sol']);
    expect(await CacaRecentes.carregar(Categoria.futebol, Nivel.facil),
        ['sol']);
    // Outro combo intacto.
    expect(await CacaRecentes.carregar(Categoria.espaco, Nivel.facil),
        ['lua']);
  });

  testWidgets('chaves antigas intactas (só a nova existe)', (tester) async {
    SharedPreferences.setMockInitialValues(
        {'moedas_v1': 7, 'xp_total_v1': 25});
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('moedas_v1'), 7);
    expect(prefs.getInt('xp_total_v1'), 25);
    await CacaRecentes.guardar(Categoria.nomes, Nivel.media, ['ana']);
    expect(prefs.getInt('moedas_v1'), 7);
    expect(prefs.getInt('xp_total_v1'), 25);
    expect(prefs.getStringList(CacaRecentes.chave)!.length, 1);
  });
}
