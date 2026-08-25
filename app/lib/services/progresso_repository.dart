import 'package:shared_preferences/shared_preferences.dart';

/// Gamificação (v1.0): XP + moedas + medalhas por habitat.
///
/// - **XP**: total que a criança JÁ ganhou — **nunca cai**; vira o NÍVEL dela
///   ([nivelDe]).
/// - **Moedas**: saldo que pode gastar (futuro "Prêmios") — sobe no acerto,
///   cai no erro (nunca fica negativo).
/// - **Medalha por habitat**: ouro/prata/bronze pela precisão (acertos ÷
///   total) ao jogar a fase no mapa-múndi; aparece no anel do mapa.
///
/// Tudo em `shared_preferences` (mesmo padrão de ProgressoFases/ConfigOrdem).
class ProgressoRepository {
  static const _chaveXp = 'xp_total_v1';
  static const _chaveMoedas = 'moedas_v1';
  static const _chaveAcertos = 'acertos_';
  static const _chaveErros = 'erros_';

  /// XP para subir de nível: nível = 1 + (xp ~/ xpPorNivel).
  static const xpPorNivel = 25;

  /// Bônus ao concluir uma fase — o "baú". Cada fase dá 1 nível (25 XP) + 10 moedas.
  static const bonusFase = 10;

  static String _habitatAcertos(String habitat) => '$_chaveAcertos$habitat';
  static String _habitatErros(String habitat) => '$_chaveErros$habitat';

  /// XP total acumulado (nunca diminui).
  static Future<int> xp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_chaveXp) ?? 0;
  }

  /// Saldo atual de moedas.
  static Future<int> moedas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_chaveMoedas) ?? 0;
  }

  /// Nível da criança a partir do XP acumulado.
  static int nivelDe(int xp) => 1 + xp ~/ xpPorNivel;

  /// Soma [pontos] nas moedas (acerto). XP só sobe ao concluir fase (baú) — 1 nível por fase.
  static Future<void> registrarAcerto(int pontos, {String? habitat}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveMoedas, (prefs.getInt(_chaveMoedas) ?? 0) + pontos);
    if (habitat != null) {
      await prefs.setInt(
          _habitatAcertos(habitat),
          (prefs.getInt(_habitatAcertos(habitat)) ?? 0) + 1);
    }
  }

  /// Desconta [pontos] das moedas (erro) — nunca abaixo de zero. XP não muda.
  /// Devolve quanto foi perdido de verdade (p/ o feedback "-X").
  static Future<int> registrarErro(int pontos, {String? habitat}) async {
    final prefs = await SharedPreferences.getInstance();
    final moedasAtual = prefs.getInt(_chaveMoedas) ?? 0;
    final perda = pontos.clamp(0, moedasAtual);
    await prefs.setInt(_chaveMoedas, moedasAtual - perda);
    if (habitat != null) {
      await prefs.setInt(
          _habitatErros(habitat),
          (prefs.getInt(_habitatErros(habitat)) ?? 0) + 1);
    }
    return perda;
  }

  /// Bônus da fase concluída (o "baú"): 1 nível (25 XP) + moedas extras.
  static Future<void> registrarBonusFase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveXp, (prefs.getInt(_chaveXp) ?? 0) + xpPorNivel);
    await prefs.setInt(
        _chaveMoedas, (prefs.getInt(_chaveMoedas) ?? 0) + bonusFase);
  }

  /// Bônus extra qualquer (ex.: sequência de acertos 🔥): só moedas (não sobe nível).
  /// Não conta acerto/erro — a medalha do habitat mede só a precisão.
  static Future<void> registrarBonus(int pontos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        _chaveMoedas, (prefs.getInt(_chaveMoedas) ?? 0) + pontos);
  }

  /// Define o saldo de moedas manualmente (pai/mãe, nas Configurações).
  /// Nunca fica negativo.
  static Future<void> salvarMoedas(int valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveMoedas, valor < 0 ? 0 : valor);
  }

  /// Define o XP total manualmente (pai/mãe, nas Configurações — o nível é
  /// derivado dele: nível = 1 + xp ~/ xpPorNivel). Nunca fica negativo.
  static Future<void> salvarXp(int valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveXp, valor < 0 ? 0 : valor);
  }

  /// Medalha do habitat pela precisão: 'ouro' (100%), 'prata' (≥80%),
  /// 'bronze' (≥60%), `null` se a fase nunca foi jogada (ou < 60%).
  static Future<String?> medalhaDe(String habitat) async {
    final prefs = await SharedPreferences.getInstance();
    final a = prefs.getInt(_habitatAcertos(habitat)) ?? 0;
    final e = prefs.getInt(_habitatErros(habitat)) ?? 0;
    if (a + e == 0) return null;
    final precisao = a / (a + e);
    if (precisao >= 1.0) return 'ouro';
    if (precisao >= 0.8) return 'prata';
    if (precisao >= 0.6) return 'bronze';
    return null;
  }
}
