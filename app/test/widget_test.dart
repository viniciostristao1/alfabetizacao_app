import 'package:alfabetizacao/features/config/config_screen.dart';
import 'package:alfabetizacao/main.dart';
import 'package:alfabetizacao/services/progresso_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abre o app num viewport de CELULAR em PAISAGEM (800×360 lógicos — o app
/// inteiro é deitado). Também zera as prefs (a home mostra a pontuação, lida
/// do shared_preferences).
Future<void> _pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(2400, 1080);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    const ProviderScope(child: AppPrimeirasPalavras()),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home mostra as categorias', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Animais'), findsOneWidget);
    expect(find.text('Objetos'), findsOneWidget);
    expect(find.text('Alimentos'), findsOneWidget);
    expect(find.text('Nomes'), findsOneWidget);
    expect(find.text('Escrever'), findsOneWidget);

    // pontuação sempre visível na home (moedas + nível)
    expect(find.text('🪙 0 · Nv 1'), findsOneWidget);

    // ...e colada ao lado ESQUERDO da engrenagem (configurações)
    final chip = tester.getRect(find.text('🪙 0 · Nv 1'));
    final engrenagem = tester.getRect(find.byIcon(Icons.settings_rounded));
    expect(chip.right, lessThan(engrenagem.left));
    expect(engrenagem.right, greaterThan(780)); // engrenagem na ponta direita
  });

  testWidgets('tocar em Objetos abre a tela de níveis', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Objetos'));
    await tester.pumpAndSettle();

    expect(find.text('Escolha o nível'), findsOneWidget);
    expect(find.text('Fácil'), findsOneWidget);
    expect(find.text('Média'), findsOneWidget);
    expect(find.text('Difícil'), findsOneWidget);
  });

  testWidgets('tocar em Animais abre o mapa de habitats', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Animais'));
    await tester.pumpAndSettle();

    expect(find.textContaining('ÁRTICO'), findsOneWidget);
    expect(find.textContaining('SAVANA'), findsOneWidget);
    expect(find.textContaining('AVES'), findsOneWidget);
    // moedas sempre visíveis no mapa de habitats (canto superior direito)
    expect(find.textContaining('🪙'), findsOneWidget);
  });

  testWidgets('tocar em Escrever abre a tela de palavras próprias',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpApp(tester);

    await tester.tap(find.text('Escrever'));
    await tester.pumpAndSettle();

    expect(find.text('Escreva uma palavra…'), findsOneWidget);
    expect(find.text('Confirmar'), findsOneWidget);
  });

  testWidgets('escrever: + adiciona palavra e Confirmar roda o estudo',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpApp(tester);

    await tester.tap(find.text('Escrever'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'gato');
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Gato'), findsOneWidget);
    expect(find.text('Confirmar (1)'), findsOneWidget);

    // Gira ANTES do Confirmar: a EstudoScreen abre em PAISAGEM (como no
    // celular) — o topo com V/X só cabe deitado.
    tester.view.physicalSize = const Size(2400, 1080);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirmar (1)'));
    await tester.pumpAndSettle();

    // EstudoScreen: palavra em caixa alta + título da lista do usuário.
    expect(find.text('GATO'), findsOneWidget);
    expect(find.text('✏️  Minhas palavras'), findsOneWidget);

    // "Início" (casinha) leva direto pra página inicial
    await tester.tap(find.text('Início'));
    await tester.pumpAndSettle();
    expect(find.text('JOGO DO DAVI'), findsOneWidget);
    expect(find.text('🪙 0 · Nv 1'), findsOneWidget);
  });

  testWidgets('estudo: V dá pontos e X tira (contador de moedas)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpApp(tester);
    await tester.tap(find.text('Escrever'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'gato');
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    // gira ANTES do Confirmar — tela de estudo em PAISAGEM, como no celular
    tester.view.physicalSize = const Size(2400, 1080);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirmar (1)'));
    await tester.pumpAndSettle();

    expect(find.text('🪙 0'), findsOneWidget);
    expect(find.text('Nv 1'), findsOneWidget);

    // V (acertou): palavra de 1 sílaba do usuário = 1 ponto.
    await tester.tap(find.text('V'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('🪙 1'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);

    // o feedback flutuante some sozinho
    await tester.pumpAndSettle();
    expect(find.text('+1'), findsNothing);

    // última palavra da categoria (1 palavra) → PARABÉNS! Fechar p/ continuar.
    expect(find.text('PARABÉNS! 🎉'), findsOneWidget);
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    // X (errou): perde o ponto e a palavra continua na tela.
    await tester.tap(find.text('X'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('🪙 0'), findsOneWidget);
    expect(find.text('-1'), findsOneWidget);
    expect(find.text('GATO'), findsOneWidget);
  });

  testWidgets('config: ajustar moedas e nível na engrenagem', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ConfigScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pontuação'), findsOneWidget);
    expect(find.text('Moedas'), findsOneWidget);
    expect(find.text('Nível'), findsOneWidget);

    // + nas moedas → saldo 1
    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await tester.pumpAndSettle();
    expect(await ProgressoRepository.moedas(), 1);

    // + no nível → XP 25 → Nv 2
    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pumpAndSettle();
    expect(await ProgressoRepository.xp(), 25);
    expect(find.text('Nv 2'), findsOneWidget);
  });
}
