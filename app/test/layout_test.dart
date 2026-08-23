import 'package:alfabetizacao/features/estudo/estudo_screen.dart';
import 'package:alfabetizacao/features/mapa_mundi/mapa_mundi_screen.dart';
import 'package:alfabetizacao/models/categoria.dart';
import 'package:alfabetizacao/models/palavra.dart';
import 'package:alfabetizacao/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'estudo: V/X bem no canto superior direito e quadrados arredondados '
      '(mesmo com notch)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = const FakeViewPadding(right: 44); // notch
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: EstudoScreen(
          titulo: '🐶  Animais · Fácil',
          palavras: [
            const Palavra(['ca', 'va', 'lo'], Categoria.animais),
            const Palavra(['e', 'le', 'fan', 'te'], Categoria.animais),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    final xBotao = tester.getRect(
      find.byWidgetPredicate((w) {
        final d = w is Container ? w.decoration : null;
        return d is BoxDecoration && d.color == AppColors.danger;
      }),
    );
    final vBotao = tester.getRect(
      find.byWidgetPredicate((w) {
        final d = w is Container ? w.decoration : null;
        return d is BoxDecoration && d.color == AppColors.acerto;
      }),
    );

    // no canto superior direito da TELA com folga (a borda/sombra não é
    // cortada): right 12 → 800 - 12 = 788
    expect(xBotao.right, 788); // 800 - 12
    expect(xBotao.top, 10);

    // quadrados de 40×40
    expect(xBotao.width, 40);
    expect(xBotao.height, 40);
    expect(vBotao.width, 40);
    expect(vBotao.height, 40);

    // LADO A LADO: mesma linha (mesmo top) e V colado à esquerda do X
    expect(vBotao.top, xBotao.top);
    expect(vBotao.right + 8, xBotao.left);

    // forma: QUADRADO com cantos arredondados (não círculo)
    final xBox = tester.widget<Container>(
      find.byWidgetPredicate((w) {
        final d = w is Container ? w.decoration : null;
        return d is BoxDecoration && d.color == AppColors.danger;
      }),
    );
    final deco = xBox.decoration! as BoxDecoration;
    expect(deco.shape, BoxShape.rectangle);
    expect(deco.borderRadius, BorderRadius.circular(8));
  });

  testWidgets('mapa: os 5 botões numa fileira só, sem se sobreporem',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    // Texto menor (a fonte de teste é "quadrada" — sem isso os botões ficam
    // largos demais e encostam; no celular real a fonte é mais estreita).
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const MaterialApp(home: MapaMundiScreen()));
    // SEM pumpAndSettle: o anel da próxima fase fica PULSANDO para sempre
    // (animação contínua de guia visual) — pump com duração fixa resolve.
    await tester.pump(const Duration(milliseconds: 500));

    // moedas sempre visíveis no mapa-múndi (canto superior direito)
    expect(find.textContaining('🪙'), findsOneWidget);

    Rect botao(String texto) => tester.getRect(
          find
              .ancestor(
                of: find.text(texto),
                matching: find.byType(Material),
              )
              .first,
        );

    final voltar = botao('VOLTAR HABITAT');
    final reiniciar = botao('REINICIAR AVENTURA');
    final iniciar = botao('INICIAR JOGO');
    final inicio = botao('VOLTAR INÍCIO');
    final colecao = botao('COLEÇÃO');

    // nenhum fica sobre o outro (todos os vizinhos)
    expect(voltar.overlaps(reiniciar), isFalse);
    expect(reiniciar.overlaps(inicio), isFalse);
    expect(inicio.overlaps(colecao), isFalse);
    expect(colecao.overlaps(iniciar), isFalse);

    // TODOS na mesma linha (mesmo top) e na metade de baixo da tela
    expect(iniciar.top, voltar.top);
    expect(inicio.top, voltar.top);
    expect(reiniciar.top, voltar.top);
    expect(colecao.top, voltar.top);
    expect(voltar.bottom, lessThanOrEqualTo(360));
    expect(iniciar.bottom, lessThanOrEqualTo(360));
    expect(inicio.bottom, lessThanOrEqualTo(360));
    expect(colecao.bottom, lessThanOrEqualTo(360));

    // ordem na fileira: voltar → reiniciar → início → coleção → iniciar
    expect(voltar.center.dx, lessThan(reiniciar.center.dx));
    expect(reiniciar.center.dx, lessThan(inicio.center.dx));
    expect(inicio.center.dx, lessThan(colecao.center.dx));
    expect(colecao.center.dx, lessThan(iniciar.center.dx));

    // a fileira inteira cabe na largura da tela
    expect(voltar.left, greaterThanOrEqualTo(0));
    expect(iniciar.right, lessThanOrEqualTo(800));
  });

  testWidgets('mapa: fases sem emoji de bicho (só os anéis)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: MapaMundiScreen()));
    // SEM pumpAndSettle: o anel da próxima fase fica PULSANDO para sempre
    // (animação contínua de guia visual) — pump com duração fixa resolve.
    await tester.pump(const Duration(milliseconds: 500));

    // nenhum emoji de categoria/animal na tela do mapa
    expect(find.text('❄️'), findsNothing);
    expect(find.text('🐮'), findsNothing);
    expect(find.text('🐠'), findsNothing);
    expect(find.text('🌴'), findsNothing);
    expect(find.text('🦁'), findsNothing);
    expect(find.text('🦅'), findsNothing);
    expect(find.text('🐧'), findsNothing);
  });
}
