import 'package:alfabetizacao/models/estudo_opcoes.dart';
import 'package:alfabetizacao/services/config_fundo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('ConfigFundo: padrão PRETO; salva e carrega cada fundo', () async {
    expect(await ConfigFundo.carregar(), FundoTela.preto);
    for (final f in FundoTela.values) {
      await ConfigFundo.salvar(f);
      expect(await ConfigFundo.carregar(), f);
    }
  });

  test('ConfigFundo: valor inválido salvo cai no PRETO', () async {
    SharedPreferences.setMockInitialValues({'fundo_tela_v1': 'roxo'});
    expect(await ConfigFundo.carregar(), FundoTela.preto);
  });
}
