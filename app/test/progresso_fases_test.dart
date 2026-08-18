import 'package:alfabetizacao/services/progresso_fases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('progresso das fases', () {
    test('marca (idempotente, mantendo a ordem), carrega e reinicia', () async {
      expect(await ProgressoFases.carregar(), isEmpty);

      await ProgressoFases.marcarConcluido('artico');
      await ProgressoFases.marcarConcluido('aves');
      await ProgressoFases.marcarConcluido('artico'); // repetido = idempotente

      final c = await ProgressoFases.carregar();
      expect(c, equals(['artico', 'aves']), reason: 'ordem de conclusão');

      await ProgressoFases.reiniciar();
      expect(await ProgressoFases.carregar(), isEmpty);
    });

    test('voltarUltima desfaz só a última fase concluída', () async {
      await ProgressoFases.marcarConcluido('artico');
      await ProgressoFases.marcarConcluido('aves');

      final r1 = await ProgressoFases.voltarUltima();
      expect(r1, equals(['artico']), reason: 'tira só a última (aves)');
      expect(await ProgressoFases.carregar(), equals(['artico']));

      final r2 = await ProgressoFases.voltarUltima();
      expect(r2, isEmpty);

      // idempotente quando já está vazio
      expect(await ProgressoFases.voltarUltima(), isEmpty);
    });
  });
}
