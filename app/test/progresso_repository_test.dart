import 'package:alfabetizacao/services/progresso_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('acerto soma só moedas (XP só sobe com fase/baú)', () async {
    await ProgressoRepository.registrarAcerto(4);
    await ProgressoRepository.registrarAcerto(2);
    expect(await ProgressoRepository.xp(), 0);
    expect(await ProgressoRepository.moedas(), 6);
  });

  test('erro desconta moedas (nunca abaixo de zero) e não corta o XP',
      () async {
    await ProgressoRepository.registrarAcerto(4);
    expect(await ProgressoRepository.registrarErro(4), 4);
    expect(await ProgressoRepository.moedas(), 0);
    expect(await ProgressoRepository.xp(), 0);
    // com saldo zerado não perde mais nada
    expect(await ProgressoRepository.registrarErro(4), 0);
    expect(await ProgressoRepository.moedas(), 0);
  });

  test('nível = 1 + xp/25', () {
    expect(ProgressoRepository.nivelDe(0), 1);
    expect(ProgressoRepository.nivelDe(24), 1);
    expect(ProgressoRepository.nivelDe(25), 2);
    expect(ProgressoRepository.nivelDe(74), 3);
  });

  test('bônus de fase dá 1 nível (25 XP) + moedas', () async {
    await ProgressoRepository.registrarBonusFase();
    expect(await ProgressoRepository.xp(), ProgressoRepository.xpPorNivel);
    expect(await ProgressoRepository.moedas(), ProgressoRepository.bonusFase);
    expect(ProgressoRepository.nivelDe(await ProgressoRepository.xp()), 2);
  });

  test('medalha pela precisão do habitat', () async {
    expect(await ProgressoRepository.medalhaDe('savana'), isNull);

    await ProgressoRepository.registrarAcerto(2, habitat: 'savana');
    await ProgressoRepository.registrarAcerto(2, habitat: 'savana');
    expect(await ProgressoRepository.medalhaDe('savana'), 'ouro'); // 100%

    await ProgressoRepository.registrarErro(2, habitat: 'savana');
    expect(await ProgressoRepository.medalhaDe('savana'), 'bronze'); // 2/3 ≈ 67%

    await ProgressoRepository.registrarAcerto(2, habitat: 'savana');
    await ProgressoRepository.registrarAcerto(2, habitat: 'savana');
    expect(await ProgressoRepository.medalhaDe('savana'), 'prata'); // 4/5 = 80%

    // 50% de precisão = sem medalha
    await ProgressoRepository.registrarAcerto(2, habitat: 'artico');
    await ProgressoRepository.registrarErro(2, habitat: 'artico');
    expect(await ProgressoRepository.medalhaDe('artico'), isNull);
  });

  test('salvarMoedas/salvarXp definem valores (nunca negativos)', () async {
    await ProgressoRepository.salvarMoedas(120);
    expect(await ProgressoRepository.moedas(), 120);
    await ProgressoRepository.salvarMoedas(-5);
    expect(await ProgressoRepository.moedas(), 0);

    await ProgressoRepository.salvarXp(60);
    expect(await ProgressoRepository.xp(), 60);
    expect(ProgressoRepository.nivelDe(60), 3);
    await ProgressoRepository.salvarXp(-10);
    expect(await ProgressoRepository.xp(), 0);
  });

  test('estatísticas de um habitat não vazam para outro', () async {
    await ProgressoRepository.registrarAcerto(2, habitat: 'aves');
    expect(await ProgressoRepository.medalhaDe('selva'), isNull);
    expect(await ProgressoRepository.medalhaDe('aves'), 'ouro');
  });
}
