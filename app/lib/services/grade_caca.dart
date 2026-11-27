import 'dart:math';

import '../models/categoria.dart';
import '../models/palavra.dart';
import 'banco_palavras.dart';

/// Posição de uma célula na grade (linha, coluna, 0-based).
class Pos {
  const Pos(this.r, this.c);

  final int r;
  final int c;

  @override
  bool operator ==(Object other) =>
      other is Pos && other.r == r && other.c == c;

  @override
  int get hashCode => Object.hash(r, c);

  @override
  String toString() => '($r,$c)';
}

/// Direção de palavra na grade (deslocamento por letra).
class Direcao {
  const Direcao(this.dr, this.dc);

  final int dr;
  final int dc;

  static const leste = Direcao(0, 1);
  static const sul = Direcao(1, 0);
  static const sudeste = Direcao(1, 1);
  static const sudoeste = Direcao(1, -1);
  static const oeste = Direcao(0, -1);
  static const norte = Direcao(-1, 0);
  static const noroeste = Direcao(-1, -1);
  static const nordeste = Direcao(-1, 1);

  /// Só para frente (fácil): esquerda-para-direita e cima-para-baixo.
  static final paraFrente2 = {leste, sul};

  /// Para frente com diagonais (médio): sem sentido inverso.
  static final paraFrente4 = {leste, sul, sudeste, sudoeste};

  /// Todas as 8 (difícil): inclui os inversos.
  static final todas8 = {
    leste,
    sul,
    sudeste,
    sudoeste,
    oeste,
    norte,
    noroeste,
    nordeste,
  };

  @override
  bool operator ==(Object other) =>
      other is Direcao && other.dr == dr && other.dc == dc;

  @override
  int get hashCode => Object.hash(dr, dc);
}

/// Uma palavra escondida: texto original (com acento, para a lista e a fala)
/// + forma da grade (sem acento, maiúscula, sem espaço/hífen) + células.
class PalavraEscondida {
  const PalavraEscondida({
    required this.texto,
    required this.grade,
    required this.celulas,
  });

  final String texto;
  final String grade;
  final List<Pos> celulas;
}

/// A grade pronta: letras por célula + palavras escondidas (com as células
/// exatas de cada uma — a prova de que todas estão acháveis).
class GradeCaca {
  const GradeCaca({required this.tamanho, required this.celulas, required this.escondidas});

  final int tamanho;
  final List<List<String>> celulas;
  final List<PalavraEscondida> escondidas;
}

/// Forma da palavra dentro da grade: sem acento, maiúscula, sem espaço/hífen.
/// (A lista mostra o texto original com acento; a comparação usa os dois
/// lados normalizados pelo [semAcento] já existente.)
String textoGradeDe(String texto) =>
    semAcento(texto).replaceAll(' ', '').replaceAll('-', '').toUpperCase();

/// Letras do preenchimento aleatório: A–Z sem K, W e Y (como revista BR).
/// Palavras do banco com K/W/Y entram normalmente (vêm do pool, não daqui).
const String kLetrasPreenchimento = 'ABCDEFGHIJLMNOPQRSTUVXZ';

/// Tamanho da grade por nível: fácil 6, médio 7, difícil 8.
int tamanhoParaNivel(Nivel nivel) => switch (nivel) {
      Nivel.facil => 6,
      Nivel.media => 7,
      Nivel.dificil => 8,
    };

/// Direções permitidas por nível.
Set<Direcao> direcoesParaNivel(Nivel nivel) => switch (nivel) {
      Nivel.facil => Direcao.paraFrente2,
      Nivel.media => Direcao.paraFrente4,
      Nivel.dificil => Direcao.todas8,
    };

/// Palavras por rodada: fácil 3, médio 4, difícil 5.
int nPalavrasParaNivel(Nivel nivel) => switch (nivel) {
      Nivel.facil => 3,
      Nivel.media => 4,
      Nivel.dificil => 5,
    };

/// Se a palavra pode entrar na grade de lado [tamanho]: sem espaço nem hífen
/// (a grade não tem célula de espaço/hífen) e com letras-grade <= tamanho.
bool serveParaGrade(Palavra p, int tamanho) {
  if (p.texto.contains(' ') || p.texto.contains('-')) return false;
  final g = textoGradeDe(p.texto);
  return g.length >= 2 && g.length <= tamanho;
}

/// Pool de um tema + nível para o caça-palavras (ordem de preferência, sem
/// embaralhar — o sorteio com semente acontece no [gerarGrade]).
///
/// Fácil: 1–2 sílabas que cabem em 6. Médio: 3 sílabas que cabem em 7.
/// Difícil: 4 sílabas que cabem em 8; se forem menos de 5 (caso do Futebol:
/// só CAMISETA e ATACANTE cabem), completa com as 3 sílabas mais longas que
/// cabem em 8, até chegar a 5 (decisão T004-a: Futebol difícil =
/// CAMISETA, ATACANTE, BANDEIRA, ZAGUEIRO, INGRESSO).
List<Palavra> palavrasParaCaca(Categoria tema, Nivel nivel) {
  List<Palavra> base() => switch (tema) {
        Categoria.animais => todosOsAnimais(),
        Categoria.objetos => todosOsObjetos(),
        Categoria.alimentos => todosOsAlimentos(),
        Categoria.nomes => todosOsNomes(),
        Categoria.espaco => todosOsEspaco(),
        Categoria.futebol => todosOsFutebol(),
        _ => const <Palavra>[],
      };
  final todas = base();
  final tam = tamanhoParaNivel(nivel);
  List<Palavra> de(int silabas) {
    final lista = todas
        .where((p) => p.nivelSilabas == silabas && serveParaGrade(p, tam))
        .toList();
    lista.sort(Palavra.porDificuldade);
    return lista;
  }

  switch (nivel) {
    case Nivel.facil:
      final lista = todas
          .where((p) =>
              (p.nivelSilabas == 1 || p.nivelSilabas == 2) &&
              serveParaGrade(p, tam))
          .toList();
      lista.sort(Palavra.porDificuldade);
      return lista;
    case Nivel.media:
      return de(3);
    case Nivel.dificil:
      final quatro = de(4);
      if (quatro.length >= nPalavrasParaNivel(nivel)) return quatro;
      // Completa com as 3 sílabas mais longas (que cabem em 8).
      final tres = de(3);
      tres.sort((a, b) {
        final la = textoGradeDe(a.texto).length;
        final lb = textoGradeDe(b.texto).length;
        if (la != lb) return lb.compareTo(la);
        return Palavra.porDificuldade(a, b);
      });
      final faltam = nPalavrasParaNivel(nivel) - quatro.length;
      return [...quatro, ...tres.take(faltam)];
  }
}

/// Gera a grade (função pura, determinística com [rng] com semente):
/// filtra o que cabe, embaralha, posiciona até [nPalavras] sem conflito
/// (célula vazia ou mesma letra) e preenche o resto com letras aleatórias.
GradeCaca gerarGrade(
  List<Palavra> candidatas, {
  required int tamanho,
  required Set<Direcao> direcoes,
  required int nPalavras,
  Random? rng,
}) {
  final r = rng ?? Random();
  // Ordem de tentativa: sorteia, mas coloca as maiores primeiro (cabe mais
  // palavra em grade pequena; determinístico com a semente).
  final comChave = candidatas
      .where((p) => serveParaGrade(p, tamanho))
      .map((p) => (p, r.nextDouble()))
      .toList()
    ..sort((a, b) {
      final la = textoGradeDe(a.$1.texto).length;
      final lb = textoGradeDe(b.$1.texto).length;
      if (la != lb) return lb.compareTo(la);
      return a.$2.compareTo(b.$2);
    });
  final ordemDirecoes = direcoes.toList()..shuffle(r);

  // Tenta o tabuleiro inteiro algumas vezes e fica com o melhor (mais
  // palavras). Determinístico com a semente (usa a sequência do rng).
  GradeCaca? melhor;
  for (var t = 0;
      t < 12 && (melhor == null || melhor.escondidas.length < nPalavras);
      t++) {
    final celulas =
        List.generate(tamanho, (_) => List.filled(tamanho, ''));
    final escondidas = <PalavraEscondida>[];
    for (final (p, _) in comChave) {
      if (escondidas.length >= nPalavras) break;
      final g = textoGradeDe(p.texto);
      var colocada = false;
      for (var tentativa = 0; tentativa < 300 && !colocada; tentativa++) {
        final d = ordemDirecoes[r.nextInt(ordemDirecoes.length)];
        final r0 = r.nextInt(tamanho);
        final c0 = r.nextInt(tamanho);
        final rf = r0 + d.dr * (g.length - 1);
        final cf = c0 + d.dc * (g.length - 1);
        if (rf < 0 || rf >= tamanho || cf < 0 || cf >= tamanho) continue;
        var conflito = false;
        for (var k = 0; k < g.length; k++) {
          final atual = celulas[r0 + d.dr * k][c0 + d.dc * k];
          if (atual.isNotEmpty && atual != g[k]) {
            conflito = true;
            break;
          }
        }
        if (conflito) continue;
        final poss = <Pos>[];
        for (var k = 0; k < g.length; k++) {
          celulas[r0 + d.dr * k][c0 + d.dc * k] = g[k];
          poss.add(Pos(r0 + d.dr * k, c0 + d.dc * k));
        }
        escondidas
            .add(PalavraEscondida(texto: p.texto, grade: g, celulas: poss));
        colocada = true;
      }
    }
    final atual =
        GradeCaca(tamanho: tamanho, celulas: celulas, escondidas: escondidas);
    if (melhor == null || atual.escondidas.length > melhor.escondidas.length) {
      melhor = atual;
    }
  }
  final celulas = melhor!.celulas;
  final escondidas = melhor.escondidas;

  // Preenche o resto com letras aleatórias (sem K/W/Y).
  for (var i = 0; i < tamanho; i++) {
    for (var j = 0; j < tamanho; j++) {
      if (celulas[i][j].isEmpty) {
        celulas[i][j] =
            kLetrasPreenchimento[r.nextInt(kLetrasPreenchimento.length)];
      }
    }
  }
  return GradeCaca(tamanho: tamanho, celulas: celulas, escondidas: escondidas);
}

/// Trava o arrasto em linha reta (como células de planilha): projeta o vetor
/// do dedo em cada direção permitida (vetor unitário) e escolhe o maior
/// avanço em células; em empate, o menor desvio perpendicular. Dedo parado
/// ou fora de direção válida devolve só a âncora.
List<Pos> normalizarArrasto(
    Pos ancora, double dr, double dc, Set<Direcao> permitidas) {
  Direcao? melhor;
  var melhorPassos = 0;
  var melhorDesvio = double.infinity;
  for (final d in permitidas) {
    final comp = sqrt(d.dr * d.dr + d.dc * d.dc);
    final ux = d.dr / comp;
    final uy = d.dc / comp;
    final proj = dr * ux + dc * uy;
    final passos = (proj + 1e-9).floor();
    if (passos <= 0) continue;
    final dx = dr - proj * ux;
    final dy = dc - proj * uy;
    final desvio = sqrt(dx * dx + dy * dy);
    if (passos > melhorPassos ||
        (passos == melhorPassos && desvio < melhorDesvio - 1e-9)) {
      melhor = d;
      melhorPassos = passos;
      melhorDesvio = desvio;
    }
  }
  if (melhor == null || melhorPassos <= 0) return [ancora];
  return [
    for (var k = 0; k <= melhorPassos; k++)
      Pos(ancora.r + melhor.dr * k, ancora.c + melhor.dc * k),
  ];
}

/// Confere o trecho arrastado: acerta se cobre EXATAMENTE uma escondida
/// (mesmo conjunto de células; ordem direta ou inversa vale — o inverso é
/// aceito em todos os níveis para não frustrar). Qualquer outro trecho
/// devolve nulo (o preview some, sem punir).
PalavraEscondida? conferirSelecao(
    List<Pos> trecho, List<PalavraEscondida> escondidas) {
  final alvo = trecho.toSet();
  for (final e in escondidas) {
    if (e.celulas.length != alvo.length) continue;
    if (e.celulas.toSet().containsAll(alvo)) return e;
  }
  return null;
}
