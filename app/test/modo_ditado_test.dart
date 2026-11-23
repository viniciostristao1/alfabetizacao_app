import 'package:alfabetizacao/features/estudo/estudo_screen.dart';
import 'package:alfabetizacao/models/categoria.dart';
import 'package:alfabetizacao/models/palavra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modo Ditado na EstudoScreen: fichas na ordem certa montam a palavra e
/// avançam; ficha errada não avança (nem penaliza).
Future<void> _abrirDitado(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({'modo_leitura_v1': 'ditado'});
  tester.view.physicalSize = const Size(1600, 720);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: EstudoScreen(
        titulo: 'X',
        palavras: const [
          Palavra(['ca', 'sa'], Categoria.objetos),
          Palavra(['bo', 'la'], Categoria.objetos),
        ],
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ditado: ficha errada não avança; ordem certa monta e passa',
      (tester) async {
    await _abrirDitado(tester);
    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('Ouvir'), findsOneWidget); // botão de repetir o ditado
    expect(find.text('V'), findsNothing); // sem V/X no ditado

    // errada primeiro ('SA' antes de 'CA'): continua na palavra 1.
    await tester.tap(find.text('SA').first);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('1 / 2'), findsOneWidget);

    // ordem certa: monta CASA e avança para a palavra 2.
    await tester.tap(find.text('CA').first);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('SA').first);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('2 / 2'), findsOneWidget);
  });
}
