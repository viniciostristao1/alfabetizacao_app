import 'package:alfabetizacao/services/config_mic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('ConfigMic: padrão LIGADO e tolerância 1', () async {
    expect(await ConfigMic.ativado(), isTrue);
    expect(await ConfigMic.tolerancia(), 1);
  });

  test('ConfigMic: salva e carrega ativado', () async {
    await ConfigMic.salvarAtivado(false);
    expect(await ConfigMic.ativado(), isFalse);
    await ConfigMic.salvarAtivado(true);
    expect(await ConfigMic.ativado(), isTrue);
  });

  test('ConfigMic: tolerância salva e é limitada a 0..2', () async {
    await ConfigMic.salvarTolerancia(2);
    expect(await ConfigMic.tolerancia(), 2);
    await ConfigMic.salvarTolerancia(0);
    expect(await ConfigMic.tolerancia(), 0);
    await ConfigMic.salvarTolerancia(9); // acima do máximo → clampa em 2
    expect(await ConfigMic.tolerancia(), 2);
    await ConfigMic.salvarTolerancia(-3); // abaixo → clampa em 0
    expect(await ConfigMic.tolerancia(), 0);
  });
}
