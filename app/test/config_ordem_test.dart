import 'package:alfabetizacao/models/regiao.dart';
import 'package:alfabetizacao/services/config_ordem.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  final todas = Regiao.values.map((r) => r.chave).toSet();

  group('ordem das regiões (ConfigOrdem)', () {
    test('sem nada salvo → ordem padrão (todas as regiões)', () async {
      final ordem = await ConfigOrdem.carregar();
      expect(ordem.toSet(), equals(todas));
      expect(ordem.length, todas.length);
    });

    test('salvar e carregar mantém a ordem escolhida', () async {
      await ConfigOrdem.salvar(['sul', 'africa', 'norte']);
      final ordem = await ConfigOrdem.carregar();
      expect(ordem.take(3).toList(), equals(['sul', 'africa', 'norte']));
      expect(ordem.toSet(), equals(todas)); // nenhuma some
    });

    test('região nova (não salva) é acrescentada, não perdida', () async {
      // ordem salva sem "australia"
      await ConfigOrdem.salvar(
          ['norte', 'artico', 'ceu', 'asia', 'africa', 'oceano', 'sul']);
      final ordem = await ConfigOrdem.carregar();
      expect(ordem, contains('australia'));
      expect(ordem.toSet(), equals(todas));
    });

    test('chave inválida salva é descartada', () async {
      await ConfigOrdem.salvar(['africa', 'inexistente', 'asia']);
      final ordem = await ConfigOrdem.carregar();
      expect(ordem, isNot(contains('inexistente')));
      expect(ordem.toSet(), equals(todas));
    });
  });
}
