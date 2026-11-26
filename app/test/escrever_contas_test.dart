import 'package:alfabetizacao/features/contas/escrever_contas_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tela "Escrever contas": aceita + − × ÷, recusa com mensagens claras e
/// mostra a ajuda com os quatro sinais.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpTela(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: EscreverContasScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> digitarEAdicionar(
      WidgetTester tester, String texto) async {
    await tester.enterText(find.byType(TextField), texto);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
  }

  testWidgets('ajuda cita os quatro sinais', (tester) async {
    await pumpTela(tester);
    expect(find.textContaining('12 + 7, 3 × 4, 10 ÷ 2'), findsWidgets);
  });

  testWidgets('adiciona × e ÷ escritos de jeitos diferentes',
      (tester) async {
    await pumpTela(tester);

    await digitarEAdicionar(tester, '3x4');
    expect(find.text('3 × 4'), findsOneWidget);

    await digitarEAdicionar(tester, '10/2');
    expect(find.text('10 ÷ 2'), findsOneWidget);

    await digitarEAdicionar(tester, '12 + 7');
    expect(find.text('12 + 7'), findsOneWidget);
  });

  testWidgets('divisão por zero mostra "Divisão por zero não existe"',
      (tester) async {
    await pumpTela(tester);

    await digitarEAdicionar(tester, '10÷0');
    expect(find.text('Divisão por zero não existe'), findsOneWidget);
    expect(find.text('10 ÷ 0'), findsNothing);
  });

  testWidgets('divisão com resto e formato ruim têm mensagem clara',
      (tester) async {
    await pumpTela(tester);

    await digitarEAdicionar(tester, '10÷3');
    expect(find.text('Use uma divisão exata, sem resto'), findsOneWidget);

    await digitarEAdicionar(tester, 'abc');
    expect(
        find.text(
            'Conta inválida. Use "+", "−", "×" ou "÷", sem resultado negativo.'),
        findsOneWidget);
  });
}
