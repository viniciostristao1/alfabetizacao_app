import 'package:alfabetizacao/models/modo_jogo.dart';
import 'package:alfabetizacao/services/config_modo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('ConfigModo: padrão Palavra; salva e carrega', () async {
    expect(await ConfigModo.carregar(), ModoJogo.palavra);
    await ConfigModo.salvar(ModoJogo.frase);
    expect(await ConfigModo.carregar(), ModoJogo.frase);
    await ConfigModo.salvar(ModoJogo.palavra);
    expect(await ConfigModo.carregar(), ModoJogo.palavra);
  });
}
