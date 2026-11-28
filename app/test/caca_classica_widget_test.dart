import 'dart:math';

import 'package:alfabetizacao/features/caca_palavras/caca_classica_screen.dart';
import 'package:alfabetizacao/features/caca_palavras/caca_menu_screen.dart';
import 'package:alfabetizacao/main.dart';
import 'package:alfabetizacao/models/categoria.dart';
import 'package:alfabetizacao/models/palavra.dart';
import 'package:alfabetizacao/services/grade_caca.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Palavra> _pool() => [
      const Palavra(['ga', 'to'], Categoria.futebol),
      const Palavra(['bo', 'la'], Categoria.futebol),
      const Palavra(['sol'], Categoria.futebol),
    ];

Future<void> _pumpClassica(WidgetTester tester,
    {required int seed, Size size = const Size(800, 360)}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: CacaClassicaScreen(
        titulo: 'Caça-palavras · Futebol · Fácil',
        tema: Categoria.futebol,
        nivel: Nivel.facil,
        candidatas: _pool(),
        seed: seed,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

GradeCaca _esperada(int seed) => gerarGrade(_pool(),
    tamanho: 6,
    direcoes: Direcao.paraFrente2,
    nPalavras: 3,
    rng: Random(seed));

Offset _centro(WidgetTester tester, Rect grade, int tamanho, int r, int c) {
  final cel = grade.width / tamanho;
  return grade.topLeft + Offset((c + 0.5) * cel, (r + 0.5) * cel);
}

Future<void> _arrastar(
    WidgetTester tester, List<Pos> celulas, int tamanho) async {
  final grade = tester.getRect(find.byKey(const Key('caca-grade')));
  final g = await tester.startGesture(_centro(tester, grade, tamanho, celulas.first.r, celulas.first.c));
  for (final p in celulas.skip(1)) {
    await g.moveTo(_centro(tester, grade, tamanho, p.r, p.c));
    await tester.pump(const Duration(milliseconds: 50));
  }
  await g.up();
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('caca classica 800x360: certa marca e conta, errada some',
      (tester) async {
    const seed = 4;
    await _pumpClassica(tester, seed: seed);
    expect(find.textContaining('(0/3)'), findsOneWidget);

    final esperada = _esperada(seed);
    final alvo = esperada.escondidas.first;

    // Trecho errado (duas células fora de qualquer palavra): some sem contar.
    final fora = [
      const Pos(5, 5),
      const Pos(5, 4),
    ];
    final cobreAlgo = conferirSelecao(fora, esperada.escondidas) != null;
    if (!cobreAlgo) {
      await _arrastar(tester, fora, 6);
      expect(find.textContaining('(0/3)'), findsOneWidget);
    }

    // Palavra certa: marca, risca a lista (riscado + verde, sem marcador)
    // e soma moedas.
    await _arrastar(tester, alvo.celulas, 6);
    expect(find.textContaining('(1/3)'), findsOneWidget);
    final riscada =
        tester.widget<Text>(find.text(alvo.texto.toUpperCase()));
    expect(riscada.style?.decoration, TextDecoration.lineThrough);

    // A mesma de novo: sem efeito (sem somar).
    final moedasAntes = find.textContaining('🪙').evaluate().isNotEmpty;
    expect(moedasAntes, isTrue);
    await _arrastar(tester, alvo.celulas, 6);
    expect(find.textContaining('(1/3)'), findsOneWidget);

    // Completa a rodada: abre o diálogo com Nova caçada/Sair.
    for (final e in esperada.escondidas.skip(1)) {
      await _arrastar(tester, e.celulas, 6);
    }
    expect(find.text('Você achou todas!'), findsOneWidget);
    expect(find.text('Nova caçada'), findsOneWidget);
    expect(find.text('Sair'), findsOneWidget);

    // Nova caçada reseta para (0/N).
    await tester.tap(find.text('Nova caçada'));
    await tester.pumpAndSettle();
    expect(find.textContaining('(0/'), findsOneWidget);
  });

  testWidgets('caca classica 864x411: certa marca e completa', (tester) async {
    const seed = 9;
    await _pumpClassica(tester,
        seed: seed, size: const Size(864, 411));
    expect(find.textContaining('(0/3)'), findsOneWidget);
    final esperada = _esperada(seed);
    for (final e in esperada.escondidas) {
      await _arrastar(tester, e.celulas, 6);
    }
    expect(find.text('Você achou todas!'), findsOneWidget);
  });

  testWidgets('caca dificil 8x8 em 800x360: celula ~37px e arrasto marca',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: CacaClassicaScreen(
          titulo: 'Caça-palavras · Futebol · Difícil',
          tema: Categoria.futebol,
          nivel: Nivel.dificil,
          seed: 2,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('(0/5)'), findsOneWidget);

    // Célula ~37px (lado ~296/8): área de toque de criança, letra ~19px
    // sempre por cima da cor (filha do quadrado, nunca coberta).
    final grade = tester.getRect(find.byKey(const Key('caca-grade')));
    final cel = grade.width / 8;
    expect(cel, inInclusiveRange(33.0, 41.0));

    // Arrastar a 1a palavra marca e conta mesmo em 37px.
    final esperada = gerarGrade(
        palavrasParaCaca(Categoria.futebol, Nivel.dificil),
        tamanho: 8,
        direcoes: Direcao.todas8,
        nPalavras: 5,
        rng: Random(2));
    final primeira =
        esperada.escondidas.first.grade.characters.first;
    final letra = tester.getRect(find.text(primeira).first);
    expect(letra.width, greaterThan(5));
    expect(letra.height, greaterThan(5));
    await _arrastar(tester, esperada.escondidas.first.celulas, 8);
    expect(find.textContaining('(1/5)'), findsOneWidget);
  });

  testWidgets('nova cacada nao repete as palavras da rodada anterior',
      (tester) async {
    final pool = [
      const Palavra(['ga', 'to'], Categoria.futebol),
      const Palavra(['bo', 'la'], Categoria.futebol),
      const Palavra(['sol'], Categoria.futebol),
      const Palavra(['lu', 'a'], Categoria.espaco),
      const Palavra(['gol'], Categoria.futebol),
      const Palavra(['mar'], Categoria.espaco),
    ];
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: CacaClassicaScreen(
          titulo: 'Caça',
          tema: Categoria.futebol,
          nivel: Nivel.facil,
          candidatas: pool,
          seed: 4,
        ),
      ),
    );
    await tester.pumpAndSettle();

    Set<String> rodada() => {
          for (final p in pool)
            if (find.text(p.texto.toUpperCase()).evaluate().isNotEmpty)
              p.texto,
        };
    final antes = rodada();
    expect(antes.length, 3);

    await tester.tap(find.text('NOVA CAÇADA'));
    await tester.pumpAndSettle();
    expect(find.textContaining('(0/3)'), findsOneWidget);
    final depois = rodada();
    expect(depois.length, 3);
    // Pool 6, rodada 3, memória exclui as 3 anteriores: disjuntas.
    expect(depois.intersection(antes), isEmpty);
  });

  testWidgets('menu: 6 temas + 3 niveis + JOGAR abre o jogo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: CacaMenuScreen()),
    );
    await tester.pumpAndSettle();

    for (final nome in [
      'Animais',
      'Objetos',
      'Alimentos',
      'Nomes',
      'Espaço',
      'Futebol'
    ]) {
      expect(find.text(nome), findsOneWidget);
    }
    expect(find.text('Fácil'), findsOneWidget);
    expect(find.text('Média'), findsOneWidget);
    expect(find.text('Difícil'), findsOneWidget);

    await tester.tap(find.text('Futebol'));
    await tester.pump();
    await tester.tap(find.text('Média'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('caca-jogar')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Futebol'), findsWidgets);
    expect(find.textContaining('(0/4)'), findsOneWidget);
  });

  testWidgets('home: card novo rola e abre o menu', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(2400, 1080);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ProviderScope(child: AppPrimeirasPalavras()),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Caça-Palavras'), 300);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Caça-Palavras'));
    await tester.pumpAndSettle();
    expect(find.text('JOGAR'), findsOneWidget);
  });
}
