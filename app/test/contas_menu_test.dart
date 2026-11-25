import 'package:alfabetizacao/features/contas/conta_estudo_screen.dart';
import 'package:alfabetizacao/features/contas/contas_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A grade de Contas agora tem 10 cards (Soma 1/2, Sub 1/2, Mistas 1/2,
/// 2 à 7 fácil, 8 a 15 Médio, Até 20, Escrever). Confere presença, cores das
/// duas multiplicações e navegação — em celular deitado e tablet.
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

  // Títulos com símbolo (+/−/+−/×) são RichText com 2 spans:
  // find.text não acha; é preciso textContaining com findRichText: true.
  Finder rico(String s) => find.textContaining(s, findRichText: true);

  testWidgets('menu mostra os 10 cards, com as cores das multiplicações',
      (tester) async {
    await pumpMenu(tester, const Size(800, 360)); // celular deitado

    expect(rico('Soma'), findsNWidgets(2));
    expect(rico('Subtração'), findsNWidgets(2));
    expect(rico('Mistas'), findsNWidgets(2));
    expect(rico('2 à 7'), findsOneWidget);
    expect(rico('8 a 15'), findsOneWidget);
    expect(find.text('1 dígito'), findsNWidgets(3)); // soma/sub/mistas
    expect(find.text('fácil'), findsOneWidget);
    expect(find.text('Médio'), findsOneWidget);
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
  });

  testWidgets('tocar em 2 à 7 abre o estudo fácil com ×', (tester) async {
    await pumpMenu(tester, const Size(800, 360));

    final alvo = rico('2 à 7');
    await tester.scrollUntilVisible(alvo, 200);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();

    expect(find.byType(ContaEstudoScreen), findsOneWidget);
    expect(find.textContaining('2 à 7 • fácil'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ContaEstudoScreen),
        matching: find.textContaining('×'),
      ),
      findsWidgets,
    );
  });

  testWidgets('tocar em 8 a 15 abre o estudo médio com ×', (tester) async {
    await pumpMenu(tester, const Size(800, 360));

    final alvo = rico('8 a 15');
    await tester.scrollUntilVisible(alvo, 200);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();

    expect(find.byType(ContaEstudoScreen), findsOneWidget);
    expect(find.textContaining('8 a 15 • Médio'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ContaEstudoScreen),
        matching: find.textContaining('×'),
      ),
      findsWidgets,
    );
  });

  testWidgets('grade funciona no tablet deitado (1280×800)', (tester) async {
    await pumpMenu(tester, const Size(1280, 800));

    expect(rico('2 à 7'), findsOneWidget);
    expect(rico('8 a 15'), findsOneWidget);

    final alvo = rico('8 a 15');
    await tester.scrollUntilVisible(alvo, 200);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();

    expect(find.byType(ContaEstudoScreen), findsOneWidget);
    expect(find.textContaining('8 a 15 • Médio'), findsOneWidget);
  });
}
