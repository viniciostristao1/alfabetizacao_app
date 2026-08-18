import 'package:alfabetizacao/services/progresso_fases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('progresso das fases', () {
    test('marca (idempotente), carrega e reinicia', () async {
      expect(await ProgressoFases.carregar(), isEmpty);

      await ProgressoFases.marcarConcluido('artico');
      await ProgressoFases.marcarConcluido('savana');
      await ProgressoFases.marcarConcluido('artico'); // repetido = idempotente

      final c = await ProgressoFases.carregar();
      expect(c, containsAll(<String>['artico', 'savana']));
      expect(c.length, 2, reason: 'não pode duplicar o repetido');

      await ProgressoFases.reiniciar();
      expect(await ProgressoFases.carregar(), isEmpty,
          reason: 'reiniciar aventura tem de apagar tudo');
    });
  });
}
