import 'package:alfabetizacao/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Abre o app num viewport de CELULAR (360×800 lógicos) — a home tem 5 cards
/// (3 linhas) e no viewport padrão de teste o último card nem é construído.
Future<void> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
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

    await tester.tap(find.text('Confirmar (1)'));
    await tester.pumpAndSettle();

    // EstudoScreen: palavra em caixa alta + título da lista do usuário.
    expect(find.text('GATO'), findsOneWidget);
    expect(find.text('✏️  Minhas palavras'), findsOneWidget);
  });

  testWidgets('estudo: V dá pontos e X tira (contador de moedas)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpApp(tester);
    await tester.tap(find.text('Escrever'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'gato');
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar (1)'));
    await tester.pumpAndSettle();

    // tela de estudo em PAISAGEM, como no celular (para o topo caber)
    tester.view.physicalSize = const Size(2400, 1080);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
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

    // X (errou): perde o ponto e a palavra continua na tela.
    await tester.tap(find.text('X'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('🪙 0'), findsOneWidget);
    expect(find.text('-1'), findsOneWidget);
    expect(find.text('GATO'), findsOneWidget);
  });
}
