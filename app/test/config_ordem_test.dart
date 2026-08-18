import 'package:alfabetizacao/models/habitat.dart';
import 'package:alfabetizacao/services/config_ordem.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  final todas = Habitat.values.map((h) => h.chave).toSet();

  group('ordem das fases (ConfigOrdem)', () {
    test('sem nada salvo → ordem padrão (todas as fases)', () async {
      final ordem = await ConfigOrdem.carregar();
      expect(ordem.toSet(), equals(todas));
      expect(ordem.length, todas.length);
    });

    test('salvar e carregar mantém a ordem escolhida', () async {
      await ConfigOrdem.salvar(['aves', 'artico', 'savana']);
      final ordem = await ConfigOrdem.carregar();
      // as 3 primeiras respeitam o salvo…
      expect(ordem.take(3).toList(), equals(['aves', 'artico', 'savana']));
      // …e nenhuma fase some (as não-salvas entram no fim).
      expect(ordem.toSet(), equals(todas));
    });

    test('fase nova (não salva) é acrescentada, não perdida', () async {
      // Simula um usuário antigo cuja ordem salva não tinha "fazenda".
      await ConfigOrdem.salvar(['artico', 'aves', 'savana', 'selva', 'aquatico']);
      final ordem = await ConfigOrdem.carregar();
      expect(ordem, contains('fazenda'));
      expect(ordem.toSet(), equals(todas));
    });

    test('chave inválida salva é descartada', () async {
      await ConfigOrdem.salvar(['artico', 'inexistente', 'aves']);
      final ordem = await ConfigOrdem.carregar();
      expect(ordem, isNot(contains('inexistente')));
      expect(ordem.toSet(), equals(todas));
    });
  });
}
