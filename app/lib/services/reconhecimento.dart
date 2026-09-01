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
bool _bate(String alvoNorm, String dito, int tolerancia) {
  final c = _normalizar(dito);
  if (c.isEmpty || alvoNorm.isEmpty) return false;
  if (c == alvoNorm) return true;
  if (tolerancia <= 0) return false;
  if ((c.length - alvoNorm.length).abs() > tolerancia) return false;
  if (kExigeMesmaInicial && c[0] != alvoNorm[0]) return false;
  return levenshtein(c, alvoNorm) <= tolerancia;
}

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
