import 'package:alfabetizacao/features/contas/conta_estudo_screen.dart';
import 'package:alfabetizacao/features/contas/contas_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A grade de Contas agora tem 12 cards (Soma 1/2, Sub 1/2, Mistas 1/2,
/// 2 à 7 fácil, 8 a 15 Médio, ÷ até 20 fácil, ÷ até 100 difícil, Até 20,
/// Escrever). Confere presença, cores das multiplicações e divisões e
/// navegação — em celular deitado e tablet.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpMenu(WidgetTester tester, Size size) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: ContasMenuScreen()));
    await tester.pumpAndSettle();
  }

  // Títulos com símbolo (+/−/+−/×/÷) são RichText com 2 spans:
  // find.text não acha; é preciso textContaining com findRichText: true.
  Finder rico(String s) => find.textContaining(s, findRichText: true);

  testWidgets('menu mostra os 12 cards, com as cores de × e ÷',
      (tester) async {
    await pumpMenu(tester, const Size(800, 360)); // celular deitado

    expect(rico('Soma'), findsNWidgets(2));
    expect(rico('Subtração'), findsNWidgets(2));
    expect(rico('Mistas'), findsNWidgets(2));
    expect(rico('2 à 7'), findsOneWidget);
    expect(rico('8 a 15'), findsOneWidget);
    expect(rico('÷ até 20'), findsOneWidget);
    expect(rico('÷ até 100'), findsOneWidget);
    expect(find.text('1 dígito'), findsNWidgets(3)); // soma/sub/mistas
    expect(find.text('fácil'), findsNWidgets(2)); // mult + divisão
    expect(find.text('Médio'), findsOneWidget);
    expect(find.text('difícil'), findsOneWidget);
    expect(find.text('🔟 Até 20'), findsOneWidget);
    expect(find.text('✏️ Escrever'), findsOneWidget);

    // Fácil mantém o teal #009688.
    final facil = tester.widget<Material>(
      find
          .ancestor(
            of: rico('2 à 7'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(facil.color, const Color(0xFF009688));

    // Médio usa o rosa #E91E63, distinto das outras 6.
    final medio = tester.widget<Material>(
      find
          .ancestor(
            of: rico('8 a 15'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(medio.color, const Color(0xFFE91E63));
    expect(medio.color, isNot(const Color(0xFF4CAF50))); // soma
    expect(medio.color, isNot(const Color(0xFFF44336))); // subtração
    expect(medio.color, isNot(const Color(0xFF2196F3))); // mistas
    expect(medio.color, isNot(const Color(0xFF009688))); // fácil
    expect(medio.color, isNot(const Color(0xFF9C27B0))); // até 20
    expect(medio.color, isNot(const Color(0xFFFF9800))); // escrever

    // Divisão fácil usa o marrom #795548, distinto das outras 9.
    final divF = tester.widget<Material>(
      find
          .ancestor(
            of: rico('÷ até 20'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(divF.color, const Color(0xFF795548));
    for (final outra in [
      Color(0xFF4CAF50),
      Color(0xFFF44336),
      Color(0xFF2196F3),
      Color(0xFF009688),
      Color(0xFFE91E63),
      Color(0xFF9C27B0),
      Color(0xFFFF9800),
    ]) {
      expect(divF.color, isNot(outra));
    }

    // Divisão difícil usa o índigo #3F51B5, distinto das outras 10.
    final divD = tester.widget<Material>(
      find
          .ancestor(
            of: rico('÷ até 100'),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(divD.color, const Color(0xFF3F51B5));
    for (final outra in [
      Color(0xFF4CAF50),
      Color(0xFFF44336),
      Color(0xFF2196F3),
      Color(0xFF009688),
      Color(0xFFE91E63),
      Color(0xFF9C27B0),
      Color(0xFFFF9800),
      Color(0xFF795548),
    ]) {
      expect(divD.color, isNot(outra));
    }
  });

  testWidgets('tocar em ÷ até 20 abre o estudo fácil com ÷', (tester) async {
    await pumpMenu(tester, const Size(800, 360));

    final alvo = rico('÷ até 20');
    await tester.scrollUntilVisible(alvo, 200);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();

    expect(find.byType(ContaEstudoScreen), findsOneWidget);
    expect(find.textContaining('÷ até 20 • fácil'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ContaEstudoScreen),
        matching: find.textContaining('÷'),
      ),
      findsWidgets,
    );
  });

  testWidgets('tocar em ÷ até 100 abre o estudo difícil com ÷',
      (tester) async {
    await pumpMenu(tester, const Size(800, 360));

    final alvo = rico('÷ até 100');
    await tester.scrollUntilVisible(alvo, 200);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();

    expect(find.byType(ContaEstudoScreen), findsOneWidget);
    expect(find.textContaining('÷ até 100 • difícil'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ContaEstudoScreen),
        matching: find.textContaining('÷'),
      ),
      findsWidgets,
    );
  });

  testWidgets('grade funciona no tablet deitado (1280×800)', (tester) async {
    await pumpMenu(tester, const Size(1280, 800));

    expect(rico('2 à 7'), findsOneWidget);
    expect(rico('8 a 15'), findsOneWidget);
    expect(rico('÷ até 20'), findsOneWidget);
    expect(rico('÷ até 100'), findsOneWidget);

    final alvo = rico('÷ até 100');
    await tester.scrollUntilVisible(alvo, 200);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();

    expect(find.byType(ContaEstudoScreen), findsOneWidget);
    expect(find.textContaining('÷ até 100 • difícil'), findsOneWidget);
  });
}
