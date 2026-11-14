import 'package:alfabetizacao/services/banco_frases.dart';
import 'package:alfabetizacao/services/banco_palavras.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('banco de frases (Modo Frases)', () {
    test('toda palavra do banco tem frase', () {
      for (final p in bancoPalavras) {
        expect(
          fraseDe(p),
          isNotNull,
          reason: '"${p.texto}" (${chaveFrase(p)}) sem frase',
        );
      }
    });

    test('sem chaves sobrando no mapa', () {
      final chaves = bancoPalavras.map(chaveFrase).toSet();
      for (final k in kFrases.keys) {
        expect(chaves.contains(k), isTrue, reason: 'frase órfã: $k');
      }
    });

    test('sem frases vazias nem duplicadas', () {
      final frases = kFrases.values.toList();
      for (final f in frases) {
        expect(f.trim(), isNotEmpty);
        expect(f, equals(f.trim()));
      }
      expect(
        frases.toSet().length,
        equals(frases.length),
        reason: 'frase duplicada no Modo Frases',
      );
    });

    test('frase contém a palavra-alvo', () {
      for (final p in bancoPalavras) {
        final frase = semAcento(fraseDe(p)!);
        // pedaços da palavra (separa espaço/hífen — cobre "urso polar",
        // "água-viva", "estrela-do-mar" e compostos "Ana Clara")
        final pedacos = semAcento(p.texto)
            .split(RegExp(r'[ \-]+'))
            .where((t) => t.length >= 3)
            .toList();
        expect(pedacos, isNotEmpty, reason: '"${p.texto}" sem pedaço válido');
        expect(
          pedacos.any(frase.contains),
          isTrue,
          reason: '"${fraseDe(p)}" não contém "${p.texto}"',
        );
      }
    });

    test('frases curtas (3 a 7 palavras, leitura de criança)', () {
      for (final e in kFrases.entries) {
        final n = e.value.trim().split(RegExp(r'\s+')).length;
        expect(
          n >= 3 && n <= 7,
          isTrue,
          reason: '"${e.value}" tem $n palavras (fora de 3–7)',
        );
      }
    });
  });
}
