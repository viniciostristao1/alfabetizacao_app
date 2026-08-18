import 'package:alfabetizacao/models/categoria.dart';
import 'package:alfabetizacao/models/habitat.dart';
import 'package:alfabetizacao/services/banco_palavras.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('banco de palavras', () {
    test('toda palavra tem de 2 a 6 sílabas, sem vazios', () {
      for (final p in bancoPalavras) {
        expect(p.silabas, isNotEmpty, reason: 'palavra sem sílabas');
        expect(
          p.nivelSilabas >= 2 && p.nivelSilabas <= 6,
          isTrue,
          reason: '"${p.texto}" tem ${p.nivelSilabas} sílabas (fora de 2–6)',
        );
        for (final s in p.silabas) {
          expect(s.trim(), isNotEmpty, reason: 'sílaba vazia em "${p.texto}"');
          expect(s, equals(s.trim()),
              reason: 'sílaba com espaço em "${p.texto}"');
        }
      }
    });

    test('texto = junção das sílabas (ou o override, quando há espaço/hífen)', () {
      for (final p in bancoPalavras) {
        if (p.textoOverride == null) {
          expect(p.texto, equals(p.silabas.join()));
        } else {
          expect(p.texto.trim(), isNotEmpty);
        }
      }
    });

    test('cada categoria+nível tem pelo menos 1 palavra (card não fica vazio)',
        () {
      for (final c in Categoria.values) {
        // "Escrever" é a categoria DO USUÁRIO (palavras digitadas na tela) —
        // não tem banco próprio.
        if (c == Categoria.escrever) continue;
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

    test('subcategorias (sub) usam os rótulos previstos', () {
      const validas = {
        Categoria.animais: {'aquatico', 'terrestre', 'voador'},
        Categoria.nomes: {'menino', 'menina'},
        Categoria.objetos: {'casa', 'rua'},
      };
      for (final p in bancoPalavras) {
        final permitidas = validas[p.categoria];
        if (permitidas != null && p.sub != null) {
          expect(permitidas.contains(p.sub), isTrue,
              reason: '"${p.texto}" tem sub="${p.sub}" inesperada');
        }
      }
    });
  });

  group('jogo de habitats', () {
    test('cada habitat tem palavras, ordenadas do menos ao mais sílabas', () {
      for (final h in Habitat.values) {
        final lista = palavrasDoHabitat(h.chave);
        expect(lista, isNotEmpty, reason: 'habitat ${h.rotulo} sem palavras');
        for (var i = 1; i < lista.length; i++) {
          expect(
            lista[i].nivelSilabas >= lista[i - 1].nivelSilabas,
            isTrue,
            reason: 'habitat ${h.rotulo} fora de ordem: '
                '${lista.map((p) => "${p.texto}(${p.nivelSilabas})").toList()}',
          );
        }
      }
    });

    test('todo animal com habitat usa uma chave de habitat válida', () {
      final chaves = Habitat.values.map((h) => h.chave).toSet();
      for (final p in bancoPalavras) {
        if (p.habitat != null) {
          expect(p.categoria, Categoria.animais);
          expect(chaves.contains(p.habitat), isTrue,
              reason: '"${p.texto}" tem habitat="${p.habitat}" inválido');
        }
      }
    });
  });

  group('selecionar animais', () {
    test('todosOsAnimais() traz só animais, sem repetir e em ordem A→Z', () {
      final lista = todosOsAnimais();
      expect(lista, isNotEmpty);
      expect(lista.every((p) => p.categoria == Categoria.animais), isTrue,
          reason: 'entrou algo que não é animal');
      final textos = lista.map((p) => p.texto).toList();
      expect(textos.toSet().length, equals(textos.length),
          reason: 'animal repetido na seleção');
      for (var i = 1; i < lista.length; i++) {
        expect(
          semAcento(lista[i].texto).compareTo(semAcento(lista[i - 1].texto)) >=
              0,
          isTrue,
          reason: 'fora de ordem alfabética: '
              '${lista.map((p) => p.texto).toList()}',
        );
      }
    });

    test('semAcento() normaliza acentos e caixa (busca amigável)', () {
      expect(semAcento('Águia'), equals('aguia'));
      expect(semAcento('LEÃO'), equals('leao'));
      expect(semAcento('tucano'), equals('tucano'));
      expect(semAcento('pinguim'), equals('pinguim'));
      // buscar sem acento acha a palavra acentuada (substring)
      expect(semAcento('onça'), equals('onca'));
      expect(semAcento('Águia').contains('gui'), isTrue);
    });
  });
}
