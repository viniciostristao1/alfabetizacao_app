import 'package:alfabetizacao/features/estudo/estudo_screen.dart';
import 'package:alfabetizacao/models/categoria.dart';
import 'package:alfabetizacao/models/palavra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'modo imagem: Anterior desabilitado na 1ª, Próximo/Anterior navegam, Voltar sai',
      (tester) async {
    SharedPreferences.setMockInitialValues({'fundo_tela_v1': 'imagem'});
    tester.view.physicalSize = const Size(1600, 720);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EstudoScreen(
                      titulo: 'X',
                      palavras: const [
                        Palavra(['ca', 'sa'], Categoria.objetos),
                        Palavra(['bo', 'la'], Categoria.objetos),
                      ],
                      fundoImagem: 'assets/objetos/objetos_temas_foto.png',
                    ),
                  ),
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    // 1ª palavra: Anterior desabilitado (tocar não muda nada), Recomeçar idem.
    expect(find.text('1 / 2'), findsOneWidget);
    await tester.tap(find.text('Anterior'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('1 / 2'), findsOneWidget);

    // Próximo avança (tocável sobre o blur) e Anterior volta a funcionar.
    await tester.tap(find.text('Próximo'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('2 / 2'), findsOneWidget);
    await tester.tap(find.text('Anterior'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('1 / 2'), findsOneWidget);

    // Voltar fecha a tela.
    await tester.tap(find.text('Voltar'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Próximo'), findsNothing);
    expect(find.text('abrir'), findsOneWidget);
  });
}
