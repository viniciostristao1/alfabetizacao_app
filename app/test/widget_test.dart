import 'package:alfabetizacao/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home mostra as 4 categorias', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AppPrimeirasPalavras()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Animais'), findsOneWidget);
    expect(find.text('Objetos'), findsOneWidget);
    expect(find.text('Alimentos'), findsOneWidget);
    expect(find.text('Nomes'), findsOneWidget);
  });

  testWidgets('tocar numa categoria abre a tela de níveis', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AppPrimeirasPalavras()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Animais'));
    await tester.pumpAndSettle();

    expect(find.text('Escolha o nível'), findsOneWidget);
    expect(find.text('Fácil'), findsOneWidget);
    expect(find.text('Média'), findsOneWidget);
    expect(find.text('Difícil'), findsOneWidget);
  });
}
