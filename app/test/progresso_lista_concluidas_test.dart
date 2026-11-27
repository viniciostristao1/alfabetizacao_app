import 'package:alfabetizacao/services/progresso_alimentos_fases.dart';
import 'package:alfabetizacao/services/progresso_espaco_temas_fases.dart';
import 'package:alfabetizacao/services/progresso_fases.dart';
import 'package:alfabetizacao/services/progresso_futebol_posicoes.dart';
import 'package:alfabetizacao/services/progresso_lista_concluidas.dart';
import 'package:alfabetizacao/services/progresso_nomes_temas_fases.dart';
import 'package:alfabetizacao/services/progresso_objetos_temas_fases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Compatibilidade antigo↔novo da FASE C: cada fachada lê o formato antigo
/// (lista crua sob a mesma chave) e escreve no mesmo formato — a chave é
/// byte a byte a antiga, então o progresso salvo do Davi continua valendo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> compat({
    required String chave,
    required Future<List<String>> Function() carregar,
    required Future<void> Function(String) marcar,
    required Future<List<String>> Function() voltar,
    required Future<void> Function() reiniciar,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // antigo → novo: lista crua sob a chave é lida igual
    await prefs.setStringList(chave, ['a', 'b']);
    expect(await carregar(), ['a', 'b']);
    // novo → antigo: escrita pela fachada aparece crua igual
    await marcar('c');
    expect(prefs.getStringList(chave), ['a', 'b', 'c']);
    // idempotente
    await marcar('c');
    expect(prefs.getStringList(chave), ['a', 'b', 'c']);
    // voltarÚltima + reiniciar no mesmo formato
    expect(await voltar(), ['a', 'b']);
    expect(prefs.getStringList(chave), ['a', 'b']);
    await reiniciar();
    expect(prefs.containsKey(chave), isFalse);
    expect(await carregar(), isEmpty);
  }

  test('ProgressoFases compatível com o formato antigo', () => compat(
        chave: 'fases_concluidas_v1',
        carregar: ProgressoFases.carregar,
        marcar: ProgressoFases.marcarConcluido,
        voltar: ProgressoFases.voltarUltima,
        reiniciar: ProgressoFases.reiniciar,
      ));

  test('ProgressoAlimentosFases compatível com o formato antigo', () => compat(
        chave: 'fases_alimentos_concluidas_v1',
        carregar: ProgressoAlimentosFases.carregar,
        marcar: ProgressoAlimentosFases.marcarConcluido,
        voltar: ProgressoAlimentosFases.voltarUltima,
        reiniciar: ProgressoAlimentosFases.reiniciar,
      ));

  test('ProgressoEspacoTemasFases compatível com o formato antigo', () => compat(
        chave: 'fases_espaco_concluidas_v1',
        carregar: ProgressoEspacoTemasFases.carregar,
        marcar: ProgressoEspacoTemasFases.marcarConcluido,
        voltar: ProgressoEspacoTemasFases.voltarUltima,
        reiniciar: ProgressoEspacoTemasFases.reiniciar,
      ));

  test('ProgressoNomesTemasFases compatível com o formato antigo', () => compat(
        chave: 'fases_nomes_temas_concluidas_v1',
        carregar: ProgressoNomesTemasFases.carregar,
        marcar: ProgressoNomesTemasFases.marcarConcluido,
        voltar: ProgressoNomesTemasFases.voltarUltima,
        reiniciar: ProgressoNomesTemasFases.reiniciar,
      ));

  test('ProgressoObjetosTemasFases compatível com o formato antigo', () =>
      compat(
        chave: 'fases_objetos_temas_concluidas_v1',
        carregar: ProgressoObjetosTemasFases.carregar,
        marcar: ProgressoObjetosTemasFases.marcarConcluido,
        voltar: ProgressoObjetosTemasFases.voltarUltima,
        reiniciar: ProgressoObjetosTemasFases.reiniciar,
      ));

  test('ProgressoFutebolPosicoes compatível com o formato antigo', () async {
    const chave = 'fases_futebol_posicoes_concluidas_v1';
    final prefs = await SharedPreferences.getInstance();
    // antigo → novo
    await prefs.setStringList(chave, ['posicoes']);
    expect(await ProgressoFutebolPosicoes.carregar(), ['posicoes']);
    expect(await ProgressoFutebolPosicoes.concluido, isTrue);
    // novo → antigo (+ idempotente)
    await ProgressoFutebolPosicoes.reiniciar();
    expect(await ProgressoFutebolPosicoes.concluido, isFalse);
    await ProgressoFutebolPosicoes.marcarConcluido();
    expect(prefs.getStringList(chave), ['posicoes']);
    await ProgressoFutebolPosicoes.marcarConcluido();
    expect(prefs.getStringList(chave), ['posicoes']);
  });

  test('genérica guarda sob a chave recebida', () async {
    const loja = ProgressoListaConcluidas('chave_teste_x');
    final prefs = await SharedPreferences.getInstance();
    expect(await loja.carregar(), isEmpty);
    await loja.marcarConcluido('a');
    await loja.marcarConcluido('b');
    expect(prefs.getStringList('chave_teste_x'), ['a', 'b']);
    expect(await loja.voltarUltima(), ['a']);
    await loja.reiniciar();
    expect(prefs.containsKey('chave_teste_x'), isFalse);
  });
}
