import 'banco_palavras.dart' show semAcento;

/// Compara a palavra-alvo com o que a criança **falou** (Modo Microfone).
///
/// É **lógica pura** (sem plugin), então dá pra testar no `flutter test` sem
/// aparelho — o wrapper do microfone ([Voz], em `voz.dart`) só chama daqui.
///
/// A comparação é **tolerante** de propósito: o reconhecedor de voz é treinado
/// em voz adulta e a voz de criança erra mais. Os parâmetros abaixo ([kTolerancia]
/// e [kExigeMesmaInicial]) existem para **calibrar no aparelho** com a voz do
/// Davi (voz de criança pode pedir mais folga; um leitor mais avançado, menos).

/// Quantas letras de diferença o reconhecedor pode errar e ainda contar acerto.
/// `0` = exige a palavra exata. Ajustar no aparelho.
const int kTolerancia = 1;

/// Se `true`, só perdoa a diferença quando a **1ª letra bate** — evita aceitar
/// "pato" no lugar de "gato" (ambos ficam a 1 letra de distância). Ajustar no
/// aparelho.
const bool kExigeMesmaInicial = true;

/// Normaliza para comparar: sem acento, minúsculo e só letras/números — tira
/// espaço e hífen (cobre "urso polar" → "ursopolar", "beija-flor" → "beijaflor").
String _normalizar(String s) =>
    semAcento(s).replaceAll(RegExp('[^a-z0-9]'), '');

/// Distância de edição (Levenshtein) entre [a] e [b] — nº mínimo de trocas,
/// inserções ou remoções de letra para ir de uma à outra.
int levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var anterior = List<int>.generate(b.length + 1, (i) => i);
  var atual = List<int>.filled(b.length + 1, 0);
  for (var i = 0; i < a.length; i++) {
    atual[0] = i + 1;
    for (var j = 0; j < b.length; j++) {
      final custo = a[i] == b[j] ? 0 : 1;
      final del = atual[j] + 1;
      final ins = anterior[j + 1] + 1;
      final sub = anterior[j] + custo;
      atual[j + 1] = del < ins
          ? (del < sub ? del : sub)
          : (ins < sub ? ins : sub);
    }
    final tmp = anterior;
    anterior = atual;
    atual = tmp;
  }
  return anterior[b.length];
}

/// Um único candidato falado ([dito]) bate com o alvo já normalizado?
bool _bate(String alvoNorm, String dito, int tolerancia) =>
    _casa(alvoNorm, _normalizar(dito), tolerancia);

/// Casa um alvo já normalizado com UMA palavra dita já normalizada.
/// (Versão posicional do [_bate], para a comparação de frases.)
bool _casa(String alvoNorm, String ditoNorm, int tolerancia) {
  if (ditoNorm.isEmpty || alvoNorm.isEmpty) return false;
  if (ditoNorm == alvoNorm) return true;
  if (tolerancia <= 0) return false;
  if ((ditoNorm.length - alvoNorm.length).abs() > tolerancia) return false;
  if (kExigeMesmaInicial && ditoNorm[0] != alvoNorm[0]) return false;
  return levenshtein(ditoNorm, alvoNorm) <= tolerancia;
}

/// Palavras curtas (artigos, monossílabos): errar/faltar no máximo 1 por frase
/// não reprova — a criança não pode perder por causa de "o"/"é"/"da".
bool _curta(String norm) => norm.length < 3;

/// A criança acertou a palavra [alvo]? [ditas] são as transcrições que o motor
/// devolveu (a principal + as alternativas). Cada uma pode ser uma **frase**
/// ("o gato", "urso polar"), então testamos a frase inteira **e cada palavra**
/// dela — assim um artigo grudado ("o gato") não estraga o acerto.
bool reconheceu(
  String alvo,
  Iterable<String> ditas, {
  int tolerancia = kTolerancia,
}) {
  final alvoNorm = _normalizar(alvo);
  if (alvoNorm.isEmpty) return false;
  for (final dita in ditas) {
    if (_bate(alvoNorm, dita, tolerancia)) return true;
    for (final palavra in dita.split(RegExp(r'\s+'))) {
      if (_bate(alvoNorm, palavra, tolerancia)) return true;
    }
  }
  return false;
}

/// A criança acertou a FRASE [frase] no Modo Frases? [palavraTema] é a palavra
/// de origem (obrigatória — falar só ela não vale).
///
/// Regra (ordem exigida, como na leitura): todas as palavras com 3+ letras
/// precisam casar, EM SEQUÊNCIA, com a tolerância de pronúncia; no máximo 1
/// palavra curta (<3 letras) pode faltar/errar. Se a frase não tem nenhuma
/// palavra com 3+ letras, TODAS precisam casar (sem folga). Palavra repetida
/// conta cada ocorrência (o casamento é posicional, não por conjunto).
bool reconheceuFrase(
  String frase,
  String palavraTema,
  Iterable<String> ditas, {
  int tolerancia = kTolerancia,
}) {
  final alvos = frase
      .split(RegExp(r'\s+'))
      .map(_normalizar)
      .where((s) => s.isNotEmpty)
      .toList();
  if (alvos.isEmpty) return false;
  final tema = _normalizar(palavraTema);
  if (tema.isEmpty) return false;
  final soCurtas = alvos.every(_curta);
  for (final dita in ditas) {
    final ditas = dita
        .split(RegExp(r'\s+'))
        .map(_normalizar)
        .where((s) => s.isNotEmpty)
        .toList();
    var i = 0;
    var faltasCurtas = 0;
    var temTema = false;
    var ok = true;
    for (final alvo in alvos) {
      var j = i;
      while (j < ditas.length && !_casa(alvo, ditas[j], tolerancia)) {
        j++;
      }
      if (j < ditas.length) {
        if (alvo == tema) temTema = true;
        i = j + 1;
      } else if (_curta(alvo) && !soCurtas && faltasCurtas < 1) {
        faltasCurtas++;
      } else {
        ok = false;
        break;
      }
    }
    if (ok && temTema) return true;
  }
  return false;
}

/// Quais palavras da [frase] NÃO foram ditas em [dita] (para o "faltou: ...").
/// Mesma ordem e tolerância de [reconheceuFrase]; devolve na forma exibida.
List<String> palavrasFaltando(
  String frase,
  String dita, {
  int tolerancia = kTolerancia,
}) {
  final visiveis =
      frase.split(RegExp(r'\s+')).where((s) => s.trim().isNotEmpty).toList();
  final alvos = visiveis.map(_normalizar).toList();
  final ditas = dita
      .split(RegExp(r'\s+'))
      .map(_normalizar)
      .where((s) => s.isNotEmpty)
      .toList();
  final soCurtas = alvos.every(_curta);
  final faltam = <String>[];
  var i = 0;
  var faltasCurtas = 0;
  for (var n = 0; n < alvos.length; n++) {
    var j = i;
    while (j < ditas.length && !_casa(alvos[n], ditas[j], tolerancia)) {
      j++;
    }
    if (j < ditas.length) {
      i = j + 1;
    } else if (_curta(alvos[n]) && !soCurtas && faltasCurtas < 1) {
      faltasCurtas++;
    } else {
      faltam.add(visiveis[n]);
    }
  }
  return faltam;
}
