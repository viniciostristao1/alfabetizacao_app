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

  test('ModoLeitura minúsculas: frase com 1ª letra maiúscula', () {
    // preserva nomes próprios dentro da frase
    expect(
      ModoLeitura.minuscula.aplicarFrase('Os anéis de Saturno são lindos'),
      'Os anéis de Saturno são lindos',
    );
    expect(
      ModoLeitura.minuscula.aplicarFrase('o davi sabe ler'),
      'O davi sabe ler',
    );
    expect(
      ModoLeitura.minuscula.aplicarFrase('A lua brilha à noite'),
      'A lua brilha à noite',
    );
    expect(ModoLeitura.minuscula.aplicarFrase(''), '');
    expect(ModoLeitura.maiuscula.aplicarFrase('A lua brilha à noite'),
        'A LUA BRILHA À NOITE');
    // palavra isolada continua toda minúscula
    expect(ModoLeitura.minuscula.aplicar('SATURNO'), 'saturno');
  });

  test('ConfigLeitura: padrão MAIÚSCULAS; salva e carrega', () async {
    expect(await ConfigLeitura.carregar(), ModoLeitura.maiuscula);
    await ConfigLeitura.salvar(ModoLeitura.minuscula);
    expect(await ConfigLeitura.carregar(), ModoLeitura.minuscula);
  });
}
