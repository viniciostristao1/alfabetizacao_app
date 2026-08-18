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

    // pintou sem exceção e os dois botões inferiores estão lá
    expect(tester.takeException(), isNull);
    expect(find.text('VOLTAR HABITAT'), findsOneWidget);
    expect(find.text('REINICIAR AVENTURA'), findsOneWidget);
  });
}
