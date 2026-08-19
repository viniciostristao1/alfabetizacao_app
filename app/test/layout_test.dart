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

  testWidgets('mapa: botões de baixo não se sobrepõem', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: MapaMundiScreen()));
    await tester.pumpAndSettle();

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

    // nenhum fica sobre o outro
    expect(voltar.overlaps(reiniciar), isFalse);
    expect(reiniciar.overlaps(iniciar), isFalse);
    expect(iniciar.overlaps(inicio), isFalse);

    // TODOS lado a lado na MESMA linha (mesmo top) e na metade de baixo
    expect(iniciar.top, voltar.top);
    expect(inicio.top, voltar.top);
    expect(reiniciar.top, voltar.top);
    expect(voltar.bottom, lessThanOrEqualTo(360));
    expect(iniciar.bottom, lessThanOrEqualTo(360));
    expect(inicio.bottom, lessThanOrEqualTo(360));
  });

  testWidgets('mapa: fases sem emoji de bicho (só os anéis)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: MapaMundiScreen()));
    await tester.pumpAndSettle();

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
