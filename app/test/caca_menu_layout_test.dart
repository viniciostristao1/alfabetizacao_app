import 'package:alfabetizacao/features/caca_palavras/caca_menu_screen.dart';
import 'package:alfabetizacao/models/categoria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpMenu(WidgetTester tester, Size size, double escala) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(escala)),
        child: const CacaMenuScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('menu sem cortes nos tamanhos principais', () {
    const tamanhos = [
      Size(800, 360),
      Size(864, 411),
      Size(640, 360),
      Size(960, 720),
      Size(360, 800),
    ];
    for (final tamanho in tamanhos) {
      for (final escala in [1.0, 1.3]) {
        testWidgets(
            'menu ${tamanho.width.toInt()}x${tamanho.height.toInt()} escala $escala: tudo visível, sem overflow',
            (tester) async {
          await _pumpMenu(tester, tamanho, escala);
          expect(tester.takeException(), isNull);

          for (final nome in [
            'Animais',
            'Objetos',
            'Alimentos',
            'Nomes',
            'Espaço',
            'Futebol',
            'Fácil',
            'Média',
            'Difícil',
          ]) {
            expect(find.text(nome), findsOneWidget,
                reason: '$nome cortado em $tamanho x$escala');
          }
          expect(find.byKey(const Key('caca-resumo')), findsOneWidget);
          expect(find.byKey(const Key('caca-jogar')), findsOneWidget);

          // Nenhum cartão além da tela (corte sem rolagem).
          for (final c in Categoria.values) {
            if (![
              Categoria.animais,
              Categoria.objetos,
              Categoria.alimentos,
              Categoria.nomes,
              Categoria.espaco,
              Categoria.futebol,
            ].contains(c)) {
              continue;
            }
            final r = tester.getRect(find.byKey(Key('caca-tema-${c.name}')));
            expect(r.top, greaterThanOrEqualTo(-0.5),
                reason: '${c.name} acima da tela');
            expect(r.bottom,
                lessThanOrEqualTo(tamanho.height + 0.5),
                reason: '${c.name} cortado embaixo em $tamanho x$escala');
          }
        });
      }
    }
  });

  testWidgets('seleção: um estilo só, sem cinza fantasma', (tester) async {
    await _pumpMenu(tester, const Size(800, 360), 1.0);

    // Toca em Objetos e solta: só ele fica marcado; os demais iguais.
    await tester.tap(find.byKey(const Key('caca-tema-objetos')));
    await tester.pumpAndSettle();

    Material cor(Key k) => tester.widget<Material>(find.descendant(
        of: find.byKey(k), matching: find.byType(Material)));
    final sel = cor(const Key('caca-tema-objetos'));
    expect(sel.color, Categoria.objetos.cor.withValues(alpha: 0.35));

    final outros = [
      Categoria.animais,
      Categoria.alimentos,
      Categoria.nomes,
      Categoria.espaco,
      Categoria.futebol,
    ].map((c) => cor(Key('caca-tema-${c.name}')).color).toSet();
    // Todos os não-selecionados com exatamente a mesma cor.
    expect(outros.length, 1);
    expect(outros.single, Colors.white.withValues(alpha: 0.07));

    // Resumo acompanha a escolha.
    expect(find.textContaining('Objetos · Fácil'), findsOneWidget);
  });
}
