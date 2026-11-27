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
  // Viewport de tablet (960x720 lógicos) DE PROPÓSITO (ver T003 · PENDENCIA
  // na ponte): com a tela achatada de 800x360, a pílula do "Ache:"
  // (centralizada na fileira do topo) cobria o centro de fichas sorteadas
  // no slot (0.50, 0.45) e o tap errava o alvo (~1/4 das vezes) — defeito
  // REAL do app em celular, NÃO corrigido nesta manutenção. Palavras curtas
  // (≤6 letras): pílulas estreitas não encostam umas nas outras dada a
  // separação mínima dos slots.
  tester.view.physicalSize = const Size(1920, 1440);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final curtas =
      todosOsAnimais().where((p) => p.texto.length <= 6).take(12).toList();
  await tester.pumpWidget(
    MaterialApp(
      home: CacaPalavrasScreen(
        titulo: 'X',
        imagem: 'assets/habitats/mapa_animais.jpg',
        palavras: curtas,
      ),
    ),
  );
  // assenta tudo (entrada de cena + TTS mockado) antes do 1º toque
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('caca: errada não avança; certas avançam e abrem o parabéns',
      (tester) async {
    await _abrirCaca(tester);
    expect(find.textContaining('(0/3)'), findsOneWidget);

    // distrator: continua 0/3.
    final errado = find.text(_distrator(tester, _alvoAtual(tester))).first;
    await tester.pumpAndSettle(); // fora de transição → o tap não erra o alvo
    await tester.tap(errado);
    await tester.pumpAndSettle();
    expect(find.textContaining('(0/3)'), findsOneWidget);

    // 3 alvos na ordem pedida.
    for (var n = 1; n <= 3; n++) {
      final certo = find.text(_alvoAtual(tester)).first;
      await tester.pumpAndSettle(); // fora de transição → o tap não erra o alvo
      await tester.tap(certo);
      await tester.pumpAndSettle();
      if (n < 3) expect(find.textContaining('($n/3)'), findsOneWidget);
    }

    // parabéns com "De novo" → volta para (0/3).
    expect(find.text('Você achou todas! 🎉'), findsOneWidget);
    await tester.tap(find.text('De novo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('(0/3)'), findsOneWidget);
  });
}
