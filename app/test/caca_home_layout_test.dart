import 'package:alfabetizacao/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Home sem a frase e sem rolagem no normal (T007): as 11 categorias cabem
/// inteiras na tela deitada; a rolagem segue existindo como segurança.
void main() {
  // Retrato 360x800: o app trava paisagem no main, então a Home nunca
  // abre em retrato no aparelho (o menu cobre o retrato defensivo).
  const tamanhos = [
    Size(800, 360),
    Size(864, 411),
    Size(640, 360),
    Size(960, 720),
  ];
  const nomes = [
    'Animais',
    'Objetos',
    'Alimentos',
    'Nomes',
    'Espaço',
    'Contas',
    'Escrever',
    'Historinhas',
    'Jogo da Velha',
    'Futebol',
    'Caça-Palavras',
  ];

  for (final tamanho in tamanhos) {
    for (final escala in [1.0, 1.3]) {
      testWidgets(
          'home ${tamanho.width.toInt()}x${tamanho.height.toInt()} x$escala: 11 visíveis, sem frase, sem corte',
          (tester) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = tamanho;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            child: MediaQuery(
              data: MediaQueryData(
                  textScaler: TextScaler.linear(escala)),
              child: const AppPrimeirasPalavras(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Sem a frase (removida na T007) e SEM rolar: tudo visível.
        expect(find.text('Escolha um tema'), findsNothing);
        for (final nome in nomes) {
          expect(find.text(nome), findsOneWidget,
              reason: '$nome cortado em $tamanho x$escala');
        }

        // Nenhum cartão além da tela.
        for (final nome in nomes) {
          final r = tester.getRect(find.text(nome).first);
          expect(r.top, greaterThanOrEqualTo(-0.5), reason: nome);
          expect(r.bottom,
              lessThanOrEqualTo(tamanho.height + 0.5),
              reason: '$nome cortado embaixo em $tamanho x$escala');
        }
      });
    }
  }
}
