import 'package:alfabetizacao/features/contas/bolinhas_conta.dart';
import 'package:alfabetizacao/models/conta.dart';
import 'package:alfabetizacao/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> montar(WidgetTester tester, Conta conta) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BolinhasConta(
            conta: conta,
            contraste: Colors.white,
            diametro: 22,
          ),
        ),
      ),
    );
  }

  int contarCor(WidgetTester tester, Color cor) => tester
      .widgetList<BolinhaContagem>(find.byType(BolinhaContagem))
      .where((b) => b.cor == cor)
      .length;

  testWidgets('soma: verdes dos dois números, com o sinal + no meio',
      (tester) async {
    await montar(tester, const Conta(3, 4, true, 1));
    expect(contarCor(tester, AppColors.acerto), 7);
    expect(contarCor(tester, AppColors.danger), 0);
    expect(find.text('+'), findsOneWidget);
  });

  testWidgets('subtração: as últimas b bolinhas ficam vermelhas',
      (tester) async {
    await montar(tester, const Conta(7, 3, false, 1));
    expect(contarCor(tester, AppColors.acerto), 4);
    expect(contarCor(tester, AppColors.danger), 3);
  });

  testWidgets('subtração sem resto: todas vermelhas', (tester) async {
    await montar(tester, const Conta(5, 5, false, 1));
    expect(contarCor(tester, AppColors.acerto), 0);
    expect(contarCor(tester, AppColors.danger), 5);
  });

  test('totalBolinhas: soma a+b, subtração a', () {
    expect(totalBolinhas(const Conta(3, 4, true, 1)), 7);
    expect(totalBolinhas(const Conta(9, 2, false, 1)), 9);
    expect(totalBolinhas(const Conta(12, 7, true, 2)), 19);
  });

  test('totalBolinhas: multiplicação a×b', () {
    expect(totalBolinhas(const Conta(3, 4, true, 1, true)), 12);
    expect(totalBolinhas(const Conta(9, 9, true, 1, true)), 81);
    expect(totalBolinhas(const Conta(1, 1, true, 1, true)), 1);
    expect(totalBolinhas(const Conta(15, 15, true, 2, true)), 225);
  });

  testWidgets('multiplicação: a×b bolinhas verdes', (tester) async {
    await montar(tester, const Conta(3, 4, true, 1, true));
    expect(contarCor(tester, AppColors.acerto), 12);
    expect(contarCor(tester, AppColors.danger), 0);
  });

  testWidgets('janela central mostra a conta, as bolinhas e fecha',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => mostrarBolinhasDialogo(
                context,
                const Conta(12, 7, true, 2),
                Colors.white,
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('12 + 7 = 19'), findsOneWidget);
    expect(find.byType(BolinhaContagem), findsNWidgets(19));

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(find.byType(BolinhaContagem), findsNothing);
  });

  testWidgets('15×15: 225 bolinhas no diálogo, sem estouro e rápido',
      (tester) async {
    const conta = Conta(15, 15, true, 2, true); // 15 × 15 = 225
    expect(totalBolinhas(conta), 225);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  mostrarBolinhasDialogo(context, conta, Colors.white),
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );

    final cronometro = Stopwatch()..start();
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    cronometro.stop();
    debugPrint('225 bolinhas: dialogo em ${cronometro.elapsedMilliseconds} ms');

    expect(find.text('15 × 15 = 225'), findsOneWidget);
    expect(find.byType(BolinhaContagem), findsNWidgets(225));
    expect(contarCor(tester, AppColors.acerto), 225);
    // Sem estouro de layout (o diálogo tem rolagem) ...
    expect(tester.takeException(), isNull);
    // ... e renderização aceitável (generoso p/ o tester em software).
    expect(cronometro.elapsedMilliseconds, lessThan(20000));

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(find.byType(BolinhaContagem), findsNothing);
  });
}
