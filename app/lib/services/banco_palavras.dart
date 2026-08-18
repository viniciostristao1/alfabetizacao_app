import '../models/categoria.dart';
import '../models/palavra.dart';

/// Banco de palavras do app (curado, offline, sem dependência externa).
///
/// Como editar: cada palavra é uma lista de SÍLABAS. O nível (fácil/média/
/// difícil) é o número de sílabas — então basta a quantidade de itens da lista
/// bater com o nível desejado. A subcategoria (`sub`) é opcional e já vem
/// preenchida para o futuro (aquatico/terrestre/voador, menino/menina, casa/rua).
///
/// Um teste (`test/banco_palavras_test.dart`) garante que toda palavra tem 2, 3
/// ou 4 sílabas, sem vazios e sem duplicatas.
const List<Palavra> bancoPalavras = [
  // ─────────────────────────── ANIMAIS ───────────────────────────
  // fácil (2 sílabas)
  Palavra(['ga', 'to'], Categoria.animais, sub: 'terrestre'),
  Palavra(['pa', 'to'], Categoria.animais, sub: 'aquatico'),
  Palavra(['va', 'ca'], Categoria.animais, sub: 'terrestre'),
  Palavra(['ra', 'to'], Categoria.animais, sub: 'terrestre'),
  Palavra(['lo', 'bo'], Categoria.animais, sub: 'terrestre'),
  Palavra(['ur', 'so'], Categoria.animais, sub: 'terrestre'),
  Palavra(['pei', 'xe'], Categoria.animais, sub: 'aquatico'),
  Palavra(['fo', 'ca'], Categoria.animais, sub: 'aquatico'),
  Palavra(['ga', 'lo'], Categoria.animais, sub: 'terrestre'),
  Palavra(['por', 'co'], Categoria.animais, sub: 'terrestre'),
  Palavra(['co', 'bra'], Categoria.animais, sub: 'terrestre'),
  Palavra(['sa', 'po'], Categoria.animais, sub: 'terrestre'),
  // média (3 sílabas)
  Palavra(['ca', 'va', 'lo'], Categoria.animais, sub: 'terrestre'),
  Palavra(['ga', 'li', 'nha'], Categoria.animais, sub: 'terrestre'),
  Palavra(['ma', 'ca', 'co'], Categoria.animais, sub: 'terrestre'),
  Palavra(['co', 'e', 'lho'], Categoria.animais, sub: 'terrestre'),
  Palavra(['gi', 'ra', 'fa'], Categoria.animais, sub: 'terrestre'),
  Palavra(['a', 'be', 'lha'], Categoria.animais, sub: 'voador'),
  Palavra(['ba', 'lei', 'a'], Categoria.animais, sub: 'aquatico'),
  Palavra(['for', 'mi', 'ga'], Categoria.animais, sub: 'terrestre'),
  Palavra(['co', 'ru', 'ja'], Categoria.animais, sub: 'voador'),
  Palavra(['ca', 'chor', 'ro'], Categoria.animais, sub: 'terrestre'),
  // difícil (4 sílabas)
  Palavra(['bor', 'bo', 'le', 'ta'], Categoria.animais, sub: 'voador'),
  Palavra(['tar', 'ta', 'ru', 'ga'], Categoria.animais, sub: 'terrestre'),
  Palavra(['cro', 'co', 'di', 'lo'], Categoria.animais, sub: 'aquatico'),
  Palavra(['e', 'le', 'fan', 'te'], Categoria.animais, sub: 'terrestre'),
  Palavra(['pas', 'sa', 'ri', 'nho'], Categoria.animais, sub: 'voador'),
  Palavra(['jo', 'a', 'ni', 'nha'], Categoria.animais, sub: 'voador'),
  Palavra(['di', 'nos', 'sau', 'ro'], Categoria.animais, sub: 'terrestre'),

  // ─────────────────────────── OBJETOS ───────────────────────────
  // fácil (2 sílabas)
  Palavra(['bo', 'la'], Categoria.objetos, sub: 'casa'),
  Palavra(['co', 'po'], Categoria.objetos, sub: 'casa'),
  Palavra(['me', 'sa'], Categoria.objetos, sub: 'casa'),
  Palavra(['ca', 'ma'], Categoria.objetos, sub: 'casa'),
  Palavra(['va', 'so'], Categoria.objetos, sub: 'casa'),
  Palavra(['li', 'vro'], Categoria.objetos, sub: 'casa'),
  Palavra(['cha', 've'], Categoria.objetos, sub: 'casa'),
  Palavra(['por', 'ta'], Categoria.objetos, sub: 'casa'),
  Palavra(['car', 'ro'], Categoria.objetos, sub: 'rua'),
  Palavra(['mo', 'to'], Categoria.objetos, sub: 'rua'),
  // média (3 sílabas)
  Palavra(['ca', 'dei', 'ra'], Categoria.objetos, sub: 'casa'),
  Palavra(['pa', 'ne', 'la'], Categoria.objetos, sub: 'casa'),
  Palavra(['ja', 'ne', 'la'], Categoria.objetos, sub: 'casa'),
  Palavra(['bo', 'ne', 'ca'], Categoria.objetos, sub: 'casa'),
  Palavra(['ca', 'der', 'no'], Categoria.objetos, sub: 'casa'),
  Palavra(['te', 'sou', 'ra'], Categoria.objetos, sub: 'casa'),
  Palavra(['sa', 'pa', 'to'], Categoria.objetos, sub: 'casa'),
  Palavra(['mar', 'te', 'lo'], Categoria.objetos, sub: 'casa'),
  Palavra(['gar', 'ra', 'fa'], Categoria.objetos, sub: 'casa'),
  Palavra(['cor', 'ti', 'na'], Categoria.objetos, sub: 'casa'),
  // difícil (4 sílabas)
  Palavra(['bi', 'ci', 'cle', 'ta'], Categoria.objetos, sub: 'rua'),
  Palavra(['te', 'le', 'fo', 'ne'], Categoria.objetos, sub: 'casa'),
  Palavra(['ge', 'la', 'dei', 'ra'], Categoria.objetos, sub: 'casa'),
  Palavra(['ven', 'ti', 'la', 'dor'], Categoria.objetos, sub: 'casa'),
  Palavra(['tra', 'ves', 'sei', 'ro'], Categoria.objetos, sub: 'casa'),
  Palavra(['com', 'pu', 'ta', 'dor'], Categoria.objetos, sub: 'casa'),
  Palavra(['se', 'má', 'fo', 'ro'], Categoria.objetos, sub: 'rua'),

  // ────────────────────────── ALIMENTOS ──────────────────────────
  // fácil (2 sílabas)
  Palavra(['bo', 'lo'], Categoria.alimentos),
  Palavra(['su', 'co'], Categoria.alimentos),
  Palavra(['quei', 'jo'], Categoria.alimentos),
  Palavra(['ar', 'roz'], Categoria.alimentos),
  Palavra(['o', 'vo'], Categoria.alimentos),
  Palavra(['u', 'va'], Categoria.alimentos),
  Palavra(['pe', 'ra'], Categoria.alimentos),
  Palavra(['lei', 'te'], Categoria.alimentos),
  Palavra(['car', 'ne'], Categoria.alimentos),
  Palavra(['ma', 'çã'], Categoria.alimentos),
  // média (3 sílabas)
  Palavra(['ba', 'na', 'na'], Categoria.alimentos),
  Palavra(['la', 'ran', 'ja'], Categoria.alimentos),
  Palavra(['to', 'ma', 'te'], Categoria.alimentos),
  Palavra(['ce', 'nou', 'ra'], Categoria.alimentos),
  Palavra(['ba', 'ta', 'ta'], Categoria.alimentos),
  Palavra(['sor', 've', 'te'], Categoria.alimentos),
  Palavra(['bis', 'coi', 'to'], Categoria.alimentos),
  Palavra(['goi', 'a', 'ba'], Categoria.alimentos),
  Palavra(['man', 'tei', 'ga'], Categoria.alimentos),
  Palavra(['bo', 'la', 'cha'], Categoria.alimentos),
  // difícil (4 sílabas)
  Palavra(['a', 'ba', 'ca', 'xi'], Categoria.alimentos),
  Palavra(['me', 'lan', 'ci', 'a'], Categoria.alimentos),
  Palavra(['a', 'ba', 'ca', 'te'], Categoria.alimentos),
  Palavra(['cho', 'co', 'la', 'te'], Categoria.alimentos),
  Palavra(['mor', 'ta', 'de', 'la'], Categoria.alimentos),
  Palavra(['a', 'bo', 'bri', 'nha'], Categoria.alimentos),

  // ──────────────────────────── NOMES ────────────────────────────
  // fácil (2 sílabas)
  Palavra(['Da', 'vi'], Categoria.nomes, sub: 'menino'),
  Palavra(['En', 'zo'], Categoria.nomes, sub: 'menino'),
  Palavra(['Ben', 'to'], Categoria.nomes, sub: 'menino'),
  Palavra(['Pe', 'dro'], Categoria.nomes, sub: 'menino'),
  Palavra(['Hu', 'go'], Categoria.nomes, sub: 'menino'),
  Palavra(['Cai', 'o'], Categoria.nomes, sub: 'menino'),
  Palavra(['A', 'na'], Categoria.nomes, sub: 'menina'),
  Palavra(['La', 'ra'], Categoria.nomes, sub: 'menina'),
  Palavra(['Cla', 'ra'], Categoria.nomes, sub: 'menina'),
  Palavra(['Du', 'da'], Categoria.nomes, sub: 'menina'),
  Palavra(['Bi', 'a'], Categoria.nomes, sub: 'menina'),
  Palavra(['Ma', 'ju'], Categoria.nomes, sub: 'menina'),
  // média (3 sílabas)
  Palavra(['Ga', 'bri', 'el'], Categoria.nomes, sub: 'menino'),
  Palavra(['Ra', 'fa', 'el'], Categoria.nomes, sub: 'menino'),
  Palavra(['Lo', 'ren', 'zo'], Categoria.nomes, sub: 'menino'),
  Palavra(['Fe', 'li', 'pe'], Categoria.nomes, sub: 'menino'),
  Palavra(['Ri', 'car', 'do'], Categoria.nomes, sub: 'menino'),
  Palavra(['So', 'fi', 'a'], Categoria.nomes, sub: 'menina'),
  Palavra(['A', 'li', 'ce'], Categoria.nomes, sub: 'menina'),
  Palavra(['He', 'le', 'na'], Categoria.nomes, sub: 'menina'),
  Palavra(['Be', 'a', 'triz'], Categoria.nomes, sub: 'menina'),
  Palavra(['Ma', 'ri', 'a'], Categoria.nomes, sub: 'menina'),
  // difícil (4 sílabas)
  Palavra(['Le', 'o', 'nar', 'do'], Categoria.nomes, sub: 'menino'),
  Palavra(['E', 'ma', 'nu', 'el'], Categoria.nomes, sub: 'menino'),
  Palavra(['O', 'tá', 'vi', 'o'], Categoria.nomes, sub: 'menino'),
  Palavra(['E', 'du', 'ar', 'do'], Categoria.nomes, sub: 'menino'),
  Palavra(['Va', 'len', 'ti', 'na'], Categoria.nomes, sub: 'menina'),
  Palavra(['I', 'sa', 'be', 'la'], Categoria.nomes, sub: 'menina'),
  Palavra(['Ma', 'nu', 'e', 'la'], Categoria.nomes, sub: 'menina'),
  Palavra(['Ce', 'cí', 'li', 'a'], Categoria.nomes, sub: 'menina'),
];

/// Palavras de uma categoria + nível (na ordem do banco).
List<Palavra> palavrasDe(Categoria categoria, Nivel nivel) => bancoPalavras
    .where((p) => p.categoria == categoria && p.nivelSilabas == nivel.silabas)
    .toList(growable: false);

/// Quantas palavras existem numa categoria + nível (para mostrar no card).
int contarPalavras(Categoria categoria, Nivel nivel) =>
    palavrasDe(categoria, nivel).length;
