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

  test('totalBolinhas: divisão = dividendo', () {
    expect(totalBolinhas(const Conta(12, 3, true, 1, false, true)), 12);
    expect(totalBolinhas(const Conta(100, 2, true, 2, false, true)), 100);
  });

  testWidgets('zero bolinhas: 0÷5 e 0×7 não mostram nada nem estouram',
      (tester) async {
    await montar(tester, const Conta(0, 5, true, 1, false, true));
    expect(find.byType(BolinhaContagem), findsNothing);
    expect(tester.takeException(), isNull);

    await montar(tester, const Conta(0, 7, true, 1, true));
    expect(find.byType(BolinhaContagem), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('multiplicação em dois tons: a escuras + resto claras',
      (tester) async {
    await montar(tester, const Conta(3, 4, true, 1, true));
    expect(contarCor(tester, kGrupoEscuro), 3);
    expect(contarCor(tester, kGrupoClaro), 9);
    expect(contarCor(tester, AppColors.acerto), 0);
    expect(contarCor(tester, AppColors.danger), 0);
    // Líder escura abre cada fileira (posições 0, 4 e 8 = 3 grupos de 4).
    final bolinhas = tester
        .widgetList<BolinhaContagem>(find.byType(BolinhaContagem))
        .toList();
    expect(bolinhas.length, 12);
    for (var i = 0; i < 12; i++) {
      expect(bolinhas[i].cor, i % 4 == 0 ? kGrupoEscuro : kGrupoClaro);
    }
  });

  testWidgets('divisão: divisor fileiras do quociente, líder escura',
      (tester) async {
    await montar(tester, const Conta(12, 3, true, 1, false, true));
    expect(contarCor(tester, kGrupoEscuro), 3);
    expect(contarCor(tester, kGrupoClaro), 9);
    final bolinhas = tester
        .widgetList<BolinhaContagem>(find.byType(BolinhaContagem))
        .toList();
    expect(bolinhas.length, 12);
    for (var i = 0; i < 12; i++) {
      expect(bolinhas[i].cor, i % 4 == 0 ? kGrupoEscuro : kGrupoClaro);
    }
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
    expect(contarCor(tester, kGrupoEscuro), 15);
    expect(contarCor(tester, kGrupoClaro), 210);
    // Sem estouro de layout (o diálogo tem rolagem) ...
    expect(tester.takeException(), isNull);
    // ... e renderização aceitável (generoso p/ o tester em software).
    expect(cronometro.elapsedMilliseconds, lessThan(20000));

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(find.byType(BolinhaContagem), findsNothing);
  });

  testWidgets('100÷2: 100 bolinhas no diálogo, sem estouro e rápido',
      (tester) async {
    const conta = Conta(100, 2, true, 2, false, true); // 100 ÷ 2 = 50
    expect(totalBolinhas(conta), 100);

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
    debugPrint('100 bolinhas: dialogo em ${cronometro.elapsedMilliseconds} ms');

    expect(find.text('100 ÷ 2 = 50'), findsOneWidget);
    expect(find.byType(BolinhaContagem), findsNWidgets(100));
    expect(contarCor(tester, kGrupoEscuro), 2);
    expect(contarCor(tester, kGrupoClaro), 98);
    // Sem estouro de layout (o diálogo tem scroll) ...
    expect(tester.takeException(), isNull);
    // ... e renderização aceitável (generoso p/ o tester em software).
    expect(cronometro.elapsedMilliseconds, lessThan(20000));

    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(find.byType(BolinhaContagem), findsNothing);
  });
}
