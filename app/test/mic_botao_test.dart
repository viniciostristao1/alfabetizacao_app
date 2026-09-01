import 'package:alfabetizacao/features/estudo/estudo_screen.dart';
import 'package:alfabetizacao/models/categoria.dart';
import 'package:alfabetizacao/models/palavra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Widget app() => const MaterialApp(
        home: EstudoScreen(
          titulo: '🐶  Animais · Fácil',
          palavras: [
            Palavra(['ca', 'va', 'lo'], Categoria.animais),
            Palavra(['bo', 'la'], Categoria.animais),
          ],
        ),
      );

  void telaPaisagem(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    // fonte de teste é "quadrada" → encolhe pra 5 botões não estourarem a linha
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  testWidgets('mic: botão "Falar" aparece no modo palavra inteira',
      (tester) async {
    SharedPreferences.setMockInitialValues({}); // padrão = MAIÚSCULAS
    telaPaisagem(tester);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Falar'), findsOneWidget);
    expect(find.text('Próximo'), findsOneWidget);
  });

  testWidgets('mic: botão some no modo "completar" (lá é por toque)',
      (tester) async {
    SharedPreferences.setMockInitialValues({'modo_leitura_v1': 'incompleta'});
    telaPaisagem(tester);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Falar'), findsNothing);
    expect(find.text('Próximo'), findsOneWidget); // os demais seguem lá
  });

  testWidgets('mic: botão some quando desligado nas Configurações',
      (tester) async {
    SharedPreferences.setMockInitialValues({'mic_ativado_v1': false});
    telaPaisagem(tester);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Falar'), findsNothing);
    expect(find.text('Próximo'), findsOneWidget);
  });
}
