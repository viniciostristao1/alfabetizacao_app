import 'package:alfabetizacao/models/modo_leitura.dart';
import 'package:alfabetizacao/services/config_leitura.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('ModoLeitura aplica o caixa certo', () {
    expect(ModoLeitura.maiuscula.aplicar('bola'), 'BOLA');
    expect(ModoLeitura.minuscula.aplicar('BOLA'), 'bola');
  });

  test('ConfigLeitura: padrão MAIÚSCULAS; salva e carrega', () async {
    expect(await ConfigLeitura.carregar(), ModoLeitura.maiuscula);
    await ConfigLeitura.salvar(ModoLeitura.minuscula);
    expect(await ConfigLeitura.carregar(), ModoLeitura.minuscula);
  });
}
