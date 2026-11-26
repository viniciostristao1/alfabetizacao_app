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

  testWidgets('multiplicação fácil: resposta certa aceita (+1 moeda), errada recusa',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    const contas = [Conta(3, 4, true, 1, true)]; // 3 × 4 = 12

    await tester.pumpWidget(
      const MaterialApp(
          home: ContaEstudoScreen(titulo: '🧮  2 à 7 • fácil', contas: contas)),
    );
    await tester.pump();

    expect(find.textContaining('3 × 4'), findsOneWidget);

    // errada primeiro: 13 não avança nem pontua (11 daria ambiguidade no
    // find.text('1'): após digitar "1", a resposta exibida e a tecla têm o
    // mesmo texto; com dígitos distintos o alvo do tap é único)
    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();
    expect(find.textContaining('3 × 4'), findsOneWidget);
    expect(await ProgressoRepository.moedas(), 0);

    // certa: 12 avança (fim → diálogo de parabéns) e dá +1
    await tester.tap(find.byIcon(Icons.backspace_rounded));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.backspace_rounded));
    await tester.pump();
    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();
    expect(await ProgressoRepository.moedas(), 1);
    expect(find.textContaining('Você acertou 1 de 1'), findsOneWidget);
  });

  testWidgets('multiplicação médio: 14×15=210 aceita (+2 moedas), 200 recusa',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    const contas = [Conta(14, 15, true, 2, true)]; // 14 × 15 = 210

    await tester.pumpWidget(
      const MaterialApp(
          home: ContaEstudoScreen(titulo: '🧮  8 a 15 • Médio', contas: contas)),
    );
    await tester.pump();

    expect(find.textContaining('14 × 15'), findsOneWidget);

    // errada primeiro: 200 não avança nem pontua
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();
    expect(find.textContaining('14 × 15'), findsOneWidget);
    expect(await ProgressoRepository.moedas(), 0);

    // certa: 210 avança (fim → diálogo de parabéns) e dá +2
    await tester.tap(find.byIcon(Icons.backspace_rounded));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.backspace_rounded));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.backspace_rounded));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();
    expect(await ProgressoRepository.moedas(), 2);
    expect(find.textContaining('Você acertou 1 de 1'), findsOneWidget);
  });

  testWidgets('divisão fácil: 12÷3=4 aceita (+1 moeda), 5 recusa',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    const contas = [Conta(12, 3, true, 1, false, true)]; // 12 ÷ 3 = 4

    await tester.pumpWidget(
      const MaterialApp(
          home: ContaEstudoScreen(titulo: '🧮  ÷ até 20 • fácil', contas: contas)),
    );
    await tester.pump();

    expect(find.textContaining('12 ÷ 3'), findsOneWidget);

    // errada primeiro: 5 não avança nem pontua
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();
    expect(find.textContaining('12 ÷ 3'), findsOneWidget);
    expect(await ProgressoRepository.moedas(), 0);

    // certa: 4 avança (fim → diálogo de parabéns) e dá +1
    await tester.tap(find.byIcon(Icons.backspace_rounded));
    await tester.pump();
    await tester.tap(find.text('4'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();
    expect(await ProgressoRepository.moedas(), 1);
    expect(find.textContaining('Você acertou 1 de 1'), findsOneWidget);
  });

  testWidgets('divisão difícil: 100÷4=25 aceita (+2 moedas), 26 recusa',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    const contas = [Conta(100, 4, true, 2, false, true)]; // 100 ÷ 4 = 25

    await tester.pumpWidget(
      const MaterialApp(
          home:
              ContaEstudoScreen(titulo: '🧮  ÷ até 100 • difícil', contas: contas)),
    );
    await tester.pump();

    expect(find.textContaining('100 ÷ 4'), findsOneWidget);

    // errada primeiro: 26 não avança nem pontua
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('6'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();
    expect(find.textContaining('100 ÷ 4'), findsOneWidget);
    expect(await ProgressoRepository.moedas(), 0);

    // certa: 25 avança (fim → diálogo de parabéns) e dá +2
    await tester.tap(find.byIcon(Icons.backspace_rounded));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.backspace_rounded));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();
    expect(await ProgressoRepository.moedas(), 2);
    expect(find.textContaining('Você acertou 1 de 1'), findsOneWidget);
  });
}
