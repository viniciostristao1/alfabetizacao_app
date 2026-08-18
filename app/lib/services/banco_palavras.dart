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
  // Organizados por HABITAT (jogo do mapa). Dentro de cada habitat, a tela roda
  // do MENOS para o MAIS sílabas (ver palavrasDoHabitat). Sílabas de 2 a 5.
  // ❄️ Ártico
  Palavra(['fo', 'ca'], Categoria.animais, sub: 'aquatico', habitat: 'artico'),
  Palavra(['pin', 'guim'], Categoria.animais, sub: 'aquatico', habitat: 'artico'),
  Palavra(['mor', 'sa'], Categoria.animais, sub: 'aquatico', habitat: 'artico'),
  Palavra(['nar', 'val'], Categoria.animais, sub: 'aquatico', habitat: 'artico'),
  Palavra(['lo', 'bo'], Categoria.animais, sub: 'terrestre', habitat: 'artico'),
  Palavra(['re', 'na'], Categoria.animais, sub: 'terrestre', habitat: 'artico'),
  Palavra(['le', 'bre'], Categoria.animais, sub: 'terrestre', habitat: 'artico'),
  Palavra(['al', 'ce'], Categoria.animais, sub: 'terrestre', habitat: 'artico'),
  Palavra(['ra', 'po', 'sa'], Categoria.animais, sub: 'terrestre', habitat: 'artico'),
  Palavra(['ur', 'so', 'po', 'lar'], Categoria.animais,
      sub: 'terrestre', habitat: 'artico', texto: 'urso polar'),
  // 🦁 Savana
  Palavra(['le', 'ão'], Categoria.animais, sub: 'terrestre', habitat: 'savana'),
  Palavra(['ze', 'bra'], Categoria.animais, sub: 'terrestre', habitat: 'savana'),
  Palavra(['chi', 'ta'], Categoria.animais, sub: 'terrestre', habitat: 'savana'),
  Palavra(['gi', 'ra', 'fa'], Categoria.animais, sub: 'terrestre', habitat: 'savana'),
  Palavra(['bú', 'fa', 'lo'], Categoria.animais, sub: 'terrestre', habitat: 'savana'),
  Palavra(['ga', 'ze', 'la'], Categoria.animais, sub: 'terrestre', habitat: 'savana'),
  Palavra(['hi', 'e', 'na'], Categoria.animais, sub: 'terrestre', habitat: 'savana'),
  Palavra(['a', 'ves', 'truz'], Categoria.animais, sub: 'terrestre', habitat: 'savana'),
  Palavra(['e', 'le', 'fan', 'te'], Categoria.animais, sub: 'terrestre', habitat: 'savana'),
  Palavra(['su', 'ri', 'ca', 'to'], Categoria.animais, sub: 'terrestre', habitat: 'savana'),
  Palavra(['an', 'tí', 'lo', 'pe'], Categoria.animais, sub: 'terrestre', habitat: 'savana'),
  Palavra(['hi', 'po', 'pó', 'ta', 'mo'], Categoria.animais,
      sub: 'terrestre', habitat: 'savana'),
  Palavra(['ri', 'no', 'ce', 'ron', 'te'], Categoria.animais,
      sub: 'terrestre', habitat: 'savana'),
  // 🌴 Selva
  Palavra(['on', 'ça'], Categoria.animais, sub: 'terrestre', habitat: 'selva'),
  Palavra(['co', 'bra'], Categoria.animais, sub: 'terrestre', habitat: 'selva'),
  Palavra(['ti', 'gre'], Categoria.animais, sub: 'terrestre', habitat: 'selva'),
  Palavra(['pan', 'da'], Categoria.animais, sub: 'terrestre', habitat: 'selva'),
  Palavra(['ma', 'ca', 'co'], Categoria.animais, sub: 'terrestre', habitat: 'selva'),
  Palavra(['tu', 'ca', 'no'], Categoria.animais, sub: 'voador', habitat: 'selva'),
  Palavra(['go', 'ri', 'la'], Categoria.animais, sub: 'terrestre', habitat: 'selva'),
  Palavra(['pre', 'gui', 'ça'], Categoria.animais, sub: 'terrestre', habitat: 'selva'),
  Palavra(['ja', 'ca', 'ré'], Categoria.animais, sub: 'aquatico', habitat: 'selva'),
  Palavra(['i', 'gua', 'na'], Categoria.animais, sub: 'terrestre', habitat: 'selva'),
  Palavra(['le', 'o', 'par', 'do'], Categoria.animais, sub: 'terrestre', habitat: 'selva'),
  Palavra(['ta', 'man', 'du', 'á'], Categoria.animais, sub: 'terrestre', habitat: 'selva'),
  Palavra(['ca', 'ma', 'le', 'ão'], Categoria.animais, sub: 'terrestre', habitat: 'selva'),
  Palavra(['bor', 'bo', 'le', 'ta'], Categoria.animais, sub: 'voador', habitat: 'selva'),
  // 🐠 Aquático
  Palavra(['pei', 'xe'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico'),
  Palavra(['pol', 'vo'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico'),
  Palavra(['rai', 'a'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico'),
  Palavra(['or', 'ca'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico'),
  Palavra(['lu', 'la'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico'),
  Palavra(['os', 'tra'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico'),
  Palavra(['sal', 'mão'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico'),
  Palavra(['ba', 'lei', 'a'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico'),
  Palavra(['gol', 'fi', 'nho'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico'),
  Palavra(['tu', 'ba', 'rão'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico'),
  Palavra(['ca', 'ma', 'rão'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico'),
  Palavra(['tar', 'ta', 'ru', 'ga'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico'),
  Palavra(['ca', 'ran', 'gue', 'jo'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico'),
  Palavra(['cro', 'co', 'di', 'lo'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico'),
  Palavra(['á', 'gua', 'vi', 'va'], Categoria.animais,
      sub: 'aquatico', habitat: 'aquatico', texto: 'água-viva'),
  Palavra(['es', 'tre', 'la', 'do', 'mar'], Categoria.animais,
      sub: 'aquatico', habitat: 'aquatico', texto: 'estrela-do-mar'),
  // 🦅 Aves
  Palavra(['pom', 'ba'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['pa', 'to'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['ga', 'lo'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['pa', 'vão'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['par', 'dal'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['á', 'gui', 'a'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['a', 'ra', 'ra'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['co', 'ru', 'ja'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['gai', 'vo', 'ta'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['fla', 'min', 'go'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['ce', 'go', 'nha'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['ga', 'li', 'nha'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['u', 'ru', 'bu'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['bei', 'ja', 'flor'], Categoria.animais,
      sub: 'voador', habitat: 'aves', texto: 'beija-flor'),
  Palavra(['pa', 'pa', 'gai', 'o'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['ca', 'ná', 'ri', 'o'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['an', 'do', 'ri', 'nha'], Categoria.animais, sub: 'voador', habitat: 'aves'),
  Palavra(['pe', 'li', 'ca', 'no'], Categoria.animais, sub: 'voador', habitat: 'aves'),

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
  Palavra(['pra', 'to'], Categoria.objetos, sub: 'casa'),
  Palavra(['fa', 'ca'], Categoria.objetos, sub: 'casa'),
  Palavra(['gar', 'fo'], Categoria.objetos, sub: 'casa'),
  Palavra(['sa', 'co'], Categoria.objetos, sub: 'casa'),
  Palavra(['bo', 'ta'], Categoria.objetos, sub: 'casa'),
  Palavra(['fo', 'gão'], Categoria.objetos, sub: 'casa'),
  Palavra(['bal', 'de'], Categoria.objetos, sub: 'casa'),
  Palavra(['lá', 'pis'], Categoria.objetos, sub: 'casa'),
  Palavra(['co', 'la'], Categoria.objetos, sub: 'casa'),
  Palavra(['pen', 'te'], Categoria.objetos, sub: 'casa'),
  Palavra(['ro', 'da'], Categoria.objetos, sub: 'rua'),
  Palavra(['pla', 'ca'], Categoria.objetos, sub: 'rua'),
  Palavra(['mu', 'ro'], Categoria.objetos, sub: 'rua'),
  Palavra(['pon', 'te'], Categoria.objetos, sub: 'rua'),
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
  Palavra(['ca', 'ne', 'ta'], Categoria.objetos, sub: 'casa'),
  Palavra(['re', 'ló', 'gio'], Categoria.objetos, sub: 'casa'),
  Palavra(['vas', 'sou', 'ra'], Categoria.objetos, sub: 'casa'),
  Palavra(['chi', 'ne', 'lo'], Categoria.objetos, sub: 'casa'),
  Palavra(['te', 'cla', 'do'], Categoria.objetos, sub: 'casa'),
  Palavra(['co', 'ber', 'tor'], Categoria.objetos, sub: 'casa'),
  Palavra(['a', 'ba', 'jur'], Categoria.objetos, sub: 'casa'),
  Palavra(['es', 'pe', 'lho'], Categoria.objetos, sub: 'casa'),
  Palavra(['re', 'vis', 'ta'], Categoria.objetos, sub: 'casa'),
  Palavra(['ba', 'lan', 'ço'], Categoria.objetos, sub: 'rua'),
  Palavra(['bu', 'zi', 'na'], Categoria.objetos, sub: 'rua'),
  Palavra(['ca', 'mi', 'nhão'], Categoria.objetos, sub: 'rua'),
  Palavra(['ô', 'ni', 'bus'], Categoria.objetos, sub: 'rua'),
  // difícil (4 sílabas)
  Palavra(['bi', 'ci', 'cle', 'ta'], Categoria.objetos, sub: 'rua'),
  Palavra(['te', 'le', 'fo', 'ne'], Categoria.objetos, sub: 'casa'),
  Palavra(['ge', 'la', 'dei', 'ra'], Categoria.objetos, sub: 'casa'),
  Palavra(['ven', 'ti', 'la', 'dor'], Categoria.objetos, sub: 'casa'),
  Palavra(['tra', 'ves', 'sei', 'ro'], Categoria.objetos, sub: 'casa'),
  Palavra(['com', 'pu', 'ta', 'dor'], Categoria.objetos, sub: 'casa'),
  Palavra(['se', 'má', 'fo', 'ro'], Categoria.objetos, sub: 'rua'),
  Palavra(['as', 'pi', 'ra', 'dor'], Categoria.objetos, sub: 'casa'),
  Palavra(['te', 'le', 'vi', 'são'], Categoria.objetos, sub: 'casa'),
  Palavra(['ca', 'de', 'a', 'do'], Categoria.objetos, sub: 'casa'),
  Palavra(['pa', 'ti', 'ne', 'te'], Categoria.objetos, sub: 'rua'),
  Palavra(['ba', 'te', 'dei', 'ra'], Categoria.objetos, sub: 'casa'),

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
  Palavra(['fei', 'jão'], Categoria.alimentos),
  Palavra(['piz', 'za'], Categoria.alimentos),
  Palavra(['ba', 'la'], Categoria.alimentos),
  Palavra(['do', 'ce'], Categoria.alimentos),
  Palavra(['tor', 'ta'], Categoria.alimentos),
  Palavra(['so', 'pa'], Categoria.alimentos),
  Palavra(['mi', 'lho'], Categoria.alimentos),
  Palavra(['man', 'ga'], Categoria.alimentos),
  Palavra(['co', 'co'], Categoria.alimentos),
  Palavra(['fi', 'go'], Categoria.alimentos),
  Palavra(['ki', 'wi'], Categoria.alimentos),
  Palavra(['ca', 'fé'], Categoria.alimentos),
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
  Palavra(['a', 'mei', 'xa'], Categoria.alimentos),
  Palavra(['re', 'po', 'lho'], Categoria.alimentos),
  Palavra(['pe', 'pi', 'no'], Categoria.alimentos),
  Palavra(['pi', 'po', 'ca'], Categoria.alimentos),
  Palavra(['la', 'sa', 'nha'], Categoria.alimentos),
  Palavra(['a', 'çú', 'car'], Categoria.alimentos),
  Palavra(['sa', 'la', 'da'], Categoria.alimentos),
  Palavra(['ce', 'bo', 'la'], Categoria.alimentos),
  Palavra(['pi', 'men', 'ta'], Categoria.alimentos),
  Palavra(['sal', 'si', 'cha'], Categoria.alimentos),
  // difícil (4 sílabas)
  Palavra(['a', 'ba', 'ca', 'xi'], Categoria.alimentos),
  Palavra(['me', 'lan', 'ci', 'a'], Categoria.alimentos),
  Palavra(['a', 'ba', 'ca', 'te'], Categoria.alimentos),
  Palavra(['cho', 'co', 'la', 'te'], Categoria.alimentos),
  Palavra(['mor', 'ta', 'de', 'la'], Categoria.alimentos),
  Palavra(['a', 'bo', 'bri', 'nha'], Categoria.alimentos),
  Palavra(['a', 'bó', 'bo', 'ra'], Categoria.alimentos),
  Palavra(['man', 'di', 'o', 'ca'], Categoria.alimentos),
  Palavra(['ge', 'la', 'ti', 'na'], Categoria.alimentos),
  Palavra(['ta', 'pi', 'o', 'ca'], Categoria.alimentos),
  Palavra(['a', 'men', 'do', 'im'], Categoria.alimentos),
  Palavra(['pi', 'ru', 'li', 'to'], Categoria.alimentos),
  Palavra(['be', 'rin', 'je', 'la'], Categoria.alimentos),
  Palavra(['bri', 'ga', 'dei', 'ro'], Categoria.alimentos),
  Palavra(['ma', 'ra', 'cu', 'já'], Categoria.alimentos),

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

/// Animais de um habitat (jogo do mapa), **ordenados do MENOS para o MAIS
/// sílabas** — a criança começa pelos mais fáceis e vai passando. `sort` é
/// estável, então empates mantêm a ordem do banco.
List<Palavra> palavrasDoHabitat(String habitatChave) {
  final lista = bancoPalavras
      .where((p) => p.categoria == Categoria.animais && p.habitat == habitatChave)
      .toList();
  lista.sort((a, b) => a.nivelSilabas.compareTo(b.nivelSilabas));
  return lista;
}

/// Todos os animais do app (para a tela "Selecionar animais"), em ordem
/// alfabética (sem acento) para achar fácil na busca.
List<Palavra> todosOsAnimais() {
  final lista =
      bancoPalavras.where((p) => p.categoria == Categoria.animais).toList();
  lista.sort((a, b) => semAcento(a.texto).compareTo(semAcento(b.texto)));
  return lista;
}

/// Remove acentos e baixa a caixa — para busca "amigável" (ex.: "aguia" acha
/// "águia"). Cobre os acentos comuns do português.
String semAcento(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  const para = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';
  final b = StringBuffer();
  for (final c in s.toLowerCase().split('')) {
    final i = de.indexOf(c);
    b.write(i >= 0 ? para[i].toLowerCase() : c);
  }
  return b.toString();
}
