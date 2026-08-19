import 'package:alfabetizacao/features/mapa_mundi/mapa_mundi_screen.dart';
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
    await tester.pumpAndSettle();

    await tester.tap(find.text('INICIAR JOGO'));
    await tester.pumpAndSettle();

    // 1ª fase da ordem PADRÃO por região = América do Norte (fase 1).
    expect(find.textContaining('Fase 1'), findsOneWidget);
    expect(find.textContaining('América do Norte'), findsOneWidget);
  });
}
