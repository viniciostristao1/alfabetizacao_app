import 'package:alfabetizacao/features/estudo/estudo_screen.dart';
import 'package:alfabetizacao/features/mapa_mundi/mapa_mundi_screen.dart';
import 'package:alfabetizacao/models/categoria.dart';
import 'package:alfabetizacao/models/palavra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mapa-múndi renderiza (painter não estoura) e tem os botões',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: MapaMundiScreen()));
    await tester.pump(); // resolve o carregar() do progresso

    // pintou sem exceção e os botões estão lá
    expect(tester.takeException(), isNull);
    expect(find.text('VOLTAR HABITAT'), findsOneWidget);
    expect(find.text('REINICIAR AVENTURA'), findsOneWidget);
    expect(find.text('INICIAR JOGO'), findsOneWidget);
  });

  testWidgets('INICIAR JOGO abre a primeira fase da ordem configurada',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    // Texto menor (fonte de teste é "quadrada" — botões largos encostariam;
    // no celular real a fonte é mais estreita).
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const MaterialApp(home: MapaMundiScreen()));
    await tester.pump(const Duration(milliseconds: 400)); // carrega progresso

    // SEM pumpAndSettle: o anel da próxima fase fica PULSANDO para sempre
    // (animação contínua de guia visual) — pumps com duração fixa resolvem.
    await tester.tap(find.text('INICIAR JOGO'));
    await tester.pump(); // processa o toque (carrega a ordem e abre a fase)
    await tester.pump(const Duration(milliseconds: 400)); // transição da fase

    // 1ª fase da ordem PADRÃO por região = América do Norte (fase 1).
    expect(find.textContaining('Fase 1'), findsOneWidget);
    expect(find.textContaining('América do Norte'), findsOneWidget);
  });

  testWidgets('CONTINUAR JOGO abre a próxima fase não concluída (de onde parou)',
      (tester) async {
    // América do Norte (1ª fase) já concluída → o jogo deve CONTINUAR no
    // Ártico (2ª fase), não voltar do zero.
    SharedPreferences.setMockInitialValues({
      'fases_concluidas_v1': <String>['norte'],
    });
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const MaterialApp(home: MapaMundiScreen()));
    await tester.pump(const Duration(milliseconds: 400)); // carrega progresso

    // com progresso, o botão vira CONTINUAR JOGO (não INICIAR)
    expect(find.text('CONTINUAR JOGO'), findsOneWidget);

    await tester.tap(find.text('CONTINUAR JOGO'));
    await tester.pump(); // processa o toque (carrega a ordem e abre a fase)
    await tester.pump(const Duration(milliseconds: 400)); // transição da fase

    // 2ª fase da ordem PADRÃO = Ártico (fase 2) — de onde parou.
    expect(find.textContaining('Fase 2'), findsOneWidget);
    expect(find.textContaining('Ártico'), findsOneWidget);
  });

  testWidgets(
      'fim de fase: baú fecha com o toque e JOGAR AGORA vai pra próxima fase',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;

    // fase Ártico com 1 palavra: concluir → baú → tocar → card → JOGAR AGORA
    await tester.pumpWidget(
      MaterialApp(
        home: EstudoScreen(
          titulo: '🐻‍❄️  Fase 2 · Ártico',
          palavras: [
            const Palavra(['ur', 'so'], Categoria.animais),
          ],
          manterPaisagemAoSair: true,
          habitatConcluivel: 'artico',
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400)); // carrega gamificação

    // completa a fase (V na última palavra) → aparece o BAÚ FECHADO
    await tester.tap(find.text('V'));
    await tester.pump(const Duration(milliseconds: 400));

    // fechado: sem JOGAR AGORA ainda, com a dica de tocar
    expect(find.text('Toque no baú para abrir! 🗝️'), findsOneWidget);
    expect(find.text('JOGAR AGORA'), findsNothing);

    // toca no baú → abre → o card da próxima fase "sai" + JOGAR AGORA
    final bauFinder = find.byKey(const Key('bau'));
    await tester.tapAt(tester.getCenter(bauFinder));
    await tester.pump(); // inicia a abertura (1º frame seta o startTime)
    await tester.pump(const Duration(milliseconds: 800)); // abre a tampa
    await tester.pump(); // rebuild: card + botões aparecem

    // card compacto: "NOVA FASE! 🔓" + o nome da próxima fase (Céu)
    expect(find.text('NOVA FASE! 🔓'), findsOneWidget);
    expect(find.text('JOGAR AGORA'), findsOneWidget);

    // JOGAR AGORA → abre a próxima fase da ordem (Fase 3 · Céu)
    await tester.tap(find.text('JOGAR AGORA'));
    await tester.pump(); // fecha o diálogo e troca de tela
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Fase 3'), findsOneWidget);
    expect(find.textContaining('Céu'), findsOneWidget);
  });
}
