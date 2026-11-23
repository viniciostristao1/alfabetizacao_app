import 'package:alfabetizacao/features/caca_palavras/caca_palavras_screen.dart';
import 'package:alfabetizacao/services/banco_palavras.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Caça-palavras: mostra "Ache: X", tocar a ficha certa avança (0/3 → 1/3),
/// ficha errada não avança; achar as 3 abre o parabéns com "De novo".
String _alvoAtual(WidgetTester tester) {
  final header = tester
      .widgetList<Text>(find.byType(Text))
      .firstWhere((t) => (t.data ?? '').startsWith('🔎 Ache:'));
  return header.data!.split('Ache: ')[1].split(' (')[0];
}

/// Uma ficha qualquer que NÃO seja o alvo (distrator visível).
String _distrator(WidgetTester tester, String alvo) {
  final ficha = tester.widgetList<Text>(find.byType(Text)).firstWhere((t) {
    final d = t.data ?? '';
    return d.isNotEmpty &&
        d == d.toUpperCase() &&
        d != alvo &&
        !d.contains('🪙') &&
        !d.startsWith('🔎') &&
        d != 'SAIR' &&
        d != 'NOVA CAÇADA' &&
        !d.startsWith('★');
  });
  return ficha.data!;
}

Future<void> _abrirCaca(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(1600, 720);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: CacaPalavrasScreen(
        titulo: 'X',
        imagem: 'assets/habitats/mapa_animais.jpg',
        palavras: todosOsAnimais().take(12).toList(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('caca: errada não avança; certas avançam e abrem o parabéns',
      (tester) async {
    await _abrirCaca(tester);
    expect(find.textContaining('(0/3)'), findsOneWidget);

    // distrator: continua 0/3.
    await tester.tap(find.text(_distrator(tester, _alvoAtual(tester))).first);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('(0/3)'), findsOneWidget);

    // 3 alvos na ordem pedida.
    for (var n = 1; n <= 3; n++) {
      await tester.tap(find.text(_alvoAtual(tester)).first);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      if (n < 3) expect(find.textContaining('($n/3)'), findsOneWidget);
    }

    // parabéns com "De novo" → volta para (0/3).
    expect(find.text('Você achou todas! 🎉'), findsOneWidget);
    await tester.tap(find.text('De novo'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('(0/3)'), findsOneWidget);
  });
}
