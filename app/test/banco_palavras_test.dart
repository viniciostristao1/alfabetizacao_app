import 'package:alfabetizacao/models/categoria.dart';
import 'package:alfabetizacao/services/banco_palavras.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('banco de palavras', () {
    test('toda palavra tem 2, 3 ou 4 sílabas, sem vazios', () {
      for (final p in bancoPalavras) {
        expect(p.silabas, isNotEmpty, reason: 'palavra sem sílabas');
        expect(
          p.nivelSilabas >= 2 && p.nivelSilabas <= 4,
          isTrue,
          reason: '"${p.texto}" tem ${p.nivelSilabas} sílabas (fora de 2–4)',
        );
        for (final s in p.silabas) {
          expect(s.trim(), isNotEmpty, reason: 'sílaba vazia em "${p.texto}"');
          expect(s, equals(s.trim()),
              reason: 'sílaba com espaço em "${p.texto}"');
        }
      }
    });

    test('texto = junção das sílabas', () {
      for (final p in bancoPalavras) {
        expect(p.texto, equals(p.silabas.join()));
      }
    });

    test('cada categoria+nível tem pelo menos 1 palavra (card não fica vazio)',
        () {
      for (final c in Categoria.values) {
        for (final n in Nivel.values) {
          expect(
            contarPalavras(c, n),
            greaterThan(0),
            reason: 'sem palavras em ${c.rotulo} / ${n.rotulo}',
          );
        }
      }
    });

    test('sem palavras duplicadas dentro da mesma categoria+nível', () {
      for (final c in Categoria.values) {
        for (final n in Nivel.values) {
          final textos = palavrasDe(c, n).map((p) => p.texto).toList();
          expect(
            textos.toSet().length,
            equals(textos.length),
            reason: 'duplicata em ${c.rotulo} / ${n.rotulo}: $textos',
          );
        }
      }
    });

    test('subcategorias (sub) usam os rótulos previstos para o futuro', () {
      const validas = {
        Categoria.animais: {'aquatico', 'terrestre', 'voador'},
        Categoria.nomes: {'menino', 'menina'},
        Categoria.objetos: {'casa', 'rua'},
      };
      for (final p in bancoPalavras) {
        final permitidas = validas[p.categoria];
        if (permitidas != null && p.sub != null) {
          expect(
            permitidas.contains(p.sub),
            isTrue,
            reason: '"${p.texto}" tem sub="${p.sub}" inesperada',
          );
        }
      }
    });
  });
}
