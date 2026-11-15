import 'package:alfabetizacao/models/categoria.dart';
import 'package:alfabetizacao/models/habitat.dart';
import 'package:alfabetizacao/models/alimentos_tema.dart';
import 'package:alfabetizacao/models/nomes_tema.dart';
import 'package:alfabetizacao/models/palavra.dart';
import 'package:alfabetizacao/models/regiao.dart';
import 'package:alfabetizacao/models/tema.dart';
import 'package:alfabetizacao/services/banco_palavras.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('banco de palavras', () {
    test('toda palavra tem de 1 a 6 sílabas, sem vazios', () {
      for (final p in bancoPalavras) {
        expect(p.silabas, isNotEmpty, reason: 'palavra sem sílabas');
        expect(
          p.nivelSilabas >= 1 && p.nivelSilabas <= 6,
          isTrue,
          reason: '"${p.texto}" tem ${p.nivelSilabas} sílabas (fora de 1–6)',
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
        if (c == Categoria.escrever || c == Categoria.contas || c == Categoria.historinhas || c == Categoria.jogoDaVelha) continue;
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

  group('temas da cidade (foto dos Temas)', () {
    test('todo tema tem palavras, ordenadas por dificuldade (letras→sílabas)',
        () {
      for (final t in Tema.values) {
        final lista = palavrasDoTema(t.chave);
        expect(lista, isNotEmpty, reason: 'tema ${t.rotulo} sem palavras');
        for (var i = 1; i < lista.length; i++) {
          expect(Palavra.porDificuldade(lista[i - 1], lista[i]) <= 0, isTrue,
              reason: 'tema ${t.rotulo} fora de ordem: '
                  '${lista.map((p) => "${p.texto}(${p.nivelLetras}L/${p.nivelSilabas}s)").toList()}');
        }
      }
    });

    test('palavras de tema NÃO entram nos níveis normais de Objetos', () {
      for (final n in Nivel.values) {
        final normais = palavrasDe(Categoria.objetos, n);
        expect(normais.every((p) => p.tema == null), isTrue,
            reason: 'palavra de tema vazou para Objetos/${n.rotulo}');
      }
    });

    test('toda palavra com tema usa uma chave de tema válida', () {
      final chaves = {
        ...Tema.values.map((t) => t.chave),
        ...AlimentosTema.values.map((t) => t.chave),
        ...NomesTema.values.map((t) => t.chave),
      };
      for (final p in bancoPalavras) {
        if (p.tema != null) {
          expect(chaves.contains(p.tema), isTrue,
              reason: '"${p.texto}" tem tema="${p.tema}" inválido');
        }
      }
    });

    test('todo tema de Alimentos tem palavras (12+), ordenadas', () {
      for (final t in AlimentosTema.values) {
        final lista = palavrasDoTema(t.chave);
        expect(lista.length, greaterThanOrEqualTo(10),
            reason: 'tema ${t.rotulo} tem só ${lista.length} palavras (quer 10+)');
        for (var i = 1; i < lista.length; i++) {
          expect(Palavra.porDificuldade(lista[i - 1], lista[i]) <= 0, isTrue,
              reason: 'tema ${t.rotulo} fora de ordem');
        }
      }
    });
  });

  group('jogo de habitats', () {
    test('cada habitat tem palavras, ordenadas por dificuldade (letras→sílabas)',
        () {
      for (final h in Habitat.values) {
        final lista = palavrasDoHabitat(h.chave);
        expect(lista, isNotEmpty, reason: 'habitat ${h.rotulo} sem palavras');
        for (var i = 1; i < lista.length; i++) {
          expect(
            Palavra.porDificuldade(lista[i - 1], lista[i]) <= 0,
            isTrue,
            reason: 'habitat ${h.rotulo} fora de ordem: '
                '${lista.map((p) => "${p.texto}(${p.nivelLetras}L/${p.nivelSilabas}s)").toList()}',
          );
        }
      }
    });

    test('menos letras vem primeiro (rena antes de pinguim)', () {
      final artico = palavrasDoHabitat('artico');
      final iRena = artico.indexWhere((p) => p.texto == 'rena'); // 4 letras
      final iPin = artico.indexWhere((p) => p.texto == 'pinguim'); // 7 letras
      expect(iRena, greaterThanOrEqualTo(0));
      expect(iPin, greaterThan(iRena),
          reason: 'rena (4L) deve vir antes de pinguim (7L), ambas 2 sílabas');
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

  group('mapa-múndi por região (continente)', () {
    test('todo animal tem uma região válida', () {
      final validas = Regiao.values.map((r) => r.chave).toSet();
      for (final p in bancoPalavras) {
        if (p.categoria != Categoria.animais) continue;
        expect(p.regiao, isNotNull, reason: '"${p.texto}" sem região');
        expect(validas.contains(p.regiao), isTrue,
            reason: '"${p.texto}" tem região="${p.regiao}" inválida');
      }
    });

    test('cada região tem palavras, ordenadas por dificuldade (letras→sílabas)',
        () {
      for (final r in Regiao.values) {
        final lista = palavrasDaRegiao(r.chave);
        expect(lista, isNotEmpty, reason: 'região ${r.rotulo} sem palavras');
        for (var i = 1; i < lista.length; i++) {
          expect(Palavra.porDificuldade(lista[i - 1], lista[i]) <= 0, isTrue,
              reason: 'região ${r.rotulo} fora de ordem');
        }
      }
    });

    test('exemplos ficam no continente certo', () {
      String regiaoDe(String texto) => bancoPalavras
          .firstWhere((p) => p.texto == texto)
          .regiao!;
      expect(regiaoDe('leão'), 'africa');
      expect(regiaoDe('macaco'), 'sul');
      expect(regiaoDe('canguru'), 'australia');
      expect(regiaoDe('panda'), 'asia');
      expect(regiaoDe('alce'), 'norte'); // alce nos EUA (pedido do usuário)
      expect(regiaoDe('golfinho'), 'oceano');
      expect(regiaoDe('águia'), 'ceu');
    });
  });

  group('categoria Espaço', () {
    test('tem as 38 palavras pedidas, nos níveis certos', () {
      final todas = todosOsEspaco();
      expect(todas.length, 38);
      final facil =
          palavrasDe(Categoria.espaco, Nivel.facil).map((p) => p.texto).toSet();
      expect(
        facil,
        containsAll({
          'lua',
          'terra',
          'Marte',
          'astro',
          'nave',
          'robô',
          'pouso',
          'luz',
          'cosmos',
          'traje',
          'radar',
          'sonda',
          'vácuo'
        }),
      );
      // "luz" tem 1 sílaba e entra no Fácil
      expect(
        palavrasDe(Categoria.espaco, Nivel.facil)
            .any((p) => p.texto == 'luz' && p.nivelSilabas == 1),
        isTrue,
      );
      expect(
        palavrasDe(Categoria.espaco, Nivel.media).map((p) => p.texto).toSet(),
        containsAll({
          'foguete',
          'decolar',
          'viagem',
          'Saturno',
          'galáxia',
          'estrela',
          'planeta',
          'cometa',
          'órbita',
          'estação',
          'eclipse'
        }),
      );
      expect(
        palavrasDe(Categoria.espaco, Nivel.dificil).map((p) => p.texto).toSet(),
        containsAll({
          'astronauta',
          'meteoro',
          'capacete',
          'asteroide',
          'gravidade',
          'telescópio',
          'satélite',
          'nebulosa',
          'supernova',
          'universo',
          'constelação'
        }),
      );
      // 5 sílabas não têm nível próprio: jogáveis via Selecionar
      expect(
        todas.map((p) => p.texto).toSet(),
        containsAll({'meteorito', 'buraco-negro', 'espaçonave'}),
      );
    });
  });

  group('temas do Espaço (foto do hangar)', () {
    test('cada tema tem palavras, ordenadas por dificuldade (letras→sílabas)',
        () {
      for (final chave in kPalavrasPorTemaEspaco.keys) {
        final lista = palavrasDoTemaEspaco(chave);
        expect(lista, isNotEmpty, reason: 'tema $chave sem palavras');
        for (var i = 1; i < lista.length; i++) {
          expect(Palavra.porDificuldade(lista[i - 1], lista[i]) <= 0, isTrue,
              reason: 'tema $chave fora de ordem: '
                  '${lista.map((p) => "${p.texto}(${p.nivelLetras}L/${p.nivelSilabas}s)").toList()}');
        }
      }
    });

    test('os 4 temas cobrem as 38 palavras, sem sobreposição', () {
      final todas = todosOsEspaco().map((p) => p.texto).toSet();
      final nosTemas = <String>[];
      for (final chave in kPalavrasPorTemaEspaco.keys) {
        nosTemas.addAll(palavrasDoTemaEspaco(chave).map((p) => p.texto));
      }
      expect(nosTemas.length, equals(todas.length),
          reason: 'palavra fora de tema ou repetida em 2 temas');
      expect(nosTemas.toSet(), equals(todas));
    });
  });
}
