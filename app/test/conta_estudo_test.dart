import 'package:alfabetizacao/features/contas/bolinhas_conta.dart';
import 'package:alfabetizacao/features/contas/conta_estudo_screen.dart';
import 'package:alfabetizacao/models/conta.dart';
import 'package:alfabetizacao/services/progresso_repository.dart';
import 'package:alfabetizacao/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('acertar a conta dá moedas e avança para a próxima',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    const contas = [
      Conta(3, 4, true, 1), // 3 + 4 = 7  (+1)
      Conta(10, 5, true, 2), // 10 + 5 = 15 (+2)
    ];

    await tester.pumpWidget(
      const MaterialApp(home: ContaEstudoScreen(titulo: 'Teste', contas: contas)),
    );
    await tester.pump();

    // 1ª conta visível
    expect(find.textContaining('3 + 4'), findsOneWidget);

    // digita 7 e confere
    await tester.tap(find.text('7'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();

    // avançou para a 2ª conta e ganhou +1 moeda
    expect(find.textContaining('10 + 5'), findsOneWidget);
    expect(await ProgressoRepository.moedas(), 1);
  });

  testWidgets('errar mostra e limpa, sem pontuar', (tester) async {
    SharedPreferences.setMockInitialValues({});
    const contas = [Conta(3, 4, true, 1)];

    await tester.pumpWidget(
      const MaterialApp(home: ContaEstudoScreen(titulo: 'Teste', contas: contas)),
    );
    await tester.pump();

    await tester.tap(find.text('9')); // resposta errada
    await tester.pump();
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();

    // segue na mesma conta e sem moedas
    expect(find.textContaining('3 + 4'), findsOneWidget);
    expect(await ProgressoRepository.moedas(), 0);
  });

  testWidgets('botão bolinhas mostra a contagem abaixo da conta', (tester) async {
    SharedPreferences.setMockInitialValues({});
    const contas = [Conta(3, 4, true, 1)];

    await tester.pumpWidget(
      const MaterialApp(home: ContaEstudoScreen(titulo: 'Teste', contas: contas)),
    );
    await tester.pump();

    expect(find.byType(BolinhasConta), findsNothing);

    await tester.tap(find.byIcon(Icons.circle_outlined));
    await tester.pump();

    expect(find.byType(BolinhasConta), findsOneWidget);
    final green = tester
        .widgetList<BolinhaContagem>(find.byType(BolinhaContagem))
        .where((b) => b.cor == AppColors.acerto);
    expect(green.length, 7); // 3 + 4

    await tester.tap(find.byIcon(Icons.circle_outlined));
    await tester.pump();
    expect(find.byType(BolinhasConta), findsNothing);
  });

  testWidgets('conta com muitas bolinhas abre a janela central', (tester) async {
    SharedPreferences.setMockInitialValues({});
    const contas = [Conta(50, 40, true, 2)]; // 90 bolinhas > limite da faixa

    await tester.pumpWidget(
      const MaterialApp(home: ContaEstudoScreen(titulo: 'Teste', contas: contas)),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.circle_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(BolinhasConta), findsOneWidget);
    expect(find.text('Fechar'), findsOneWidget);

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(find.byType(BolinhasConta), findsNothing);
  });
}
