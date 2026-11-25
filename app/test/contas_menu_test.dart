import 'package:alfabetizacao/features/contas/conta_estudo_screen.dart';
import 'package:alfabetizacao/features/contas/contas_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A grade de Contas agora tem 9 cards (Soma 1/2, Sub 1/2, Mistas 1/2,
/// Multiplicação 1 dígito, Até 20, Escrever). Confere presença, cor única da
/// Multiplicação e navegação — em tamanho de celular deitado e de tablet.
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

  testWidgets('menu mostra os 9 cards, com Multiplicação em cor própria',
      (tester) async {
    await pumpMenu(tester, const Size(800, 360)); // celular deitado

    // Títulos com símbolo (+/−/+−/×) são RichText com 2 spans:
    // find.text não acha; é preciso textContaining com findRichText: true.
    Finder rico(String s) => find.textContaining(s, findRichText: true);
    expect(rico('Soma'), findsNWidgets(2));
    expect(rico('Subtração'), findsNWidgets(2));
    expect(rico('Mistas'), findsNWidgets(2));
    expect(rico('Multiplicação'), findsOneWidget);
    expect(find.text('1 dígito'), findsNWidgets(4)); // soma/sub/mistas/multi
    expect(find.text('🔟 Até 20'), findsOneWidget);
    expect(find.text('✏️ Escrever'), findsOneWidget);

    // Cor da Multiplicação: teal #009688, distinta das outras 5.
    final multi = tester.widget<Material>(
      find.ancestor(
        of: find.textContaining('Multiplicação', findRichText: true),
        matching: find.byType(Material),
      ).first,
    );
    expect(multi.color, const Color(0xFF009688));
    expect(multi.color, isNot(const Color(0xFF4CAF50))); // soma
    expect(multi.color, isNot(const Color(0xFFF44336))); // subtração
    expect(multi.color, isNot(const Color(0xFF2196F3))); // mistas
    expect(multi.color, isNot(const Color(0xFF9C27B0))); // até 20
    expect(multi.color, isNot(const Color(0xFFFF9800))); // escrever
  });

  testWidgets('tocar em Multiplicação abre o estudo com ×', (tester) async {
    await pumpMenu(tester, const Size(800, 360));

    final alvo = find.textContaining('Multiplicação', findRichText: true);
    await tester.scrollUntilVisible(alvo, 200);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();

    expect(find.byType(ContaEstudoScreen), findsOneWidget);
    expect(
        find.textContaining('Multiplicação · 1 dígito'), findsOneWidget);
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

    final alvo = find.textContaining('Multiplicação', findRichText: true);
    expect(alvo, findsOneWidget);

    await tester.scrollUntilVisible(alvo, 200);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();

    expect(find.byType(ContaEstudoScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ContaEstudoScreen),
        matching: find.textContaining('×'),
      ),
      findsWidgets,
    );
  });
}
