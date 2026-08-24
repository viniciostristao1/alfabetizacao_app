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
  // DUAS classificações independentes por bicho:
  //  • habitat = jogo do mapa de habitats (artico/savana/selva/aquatico/aves/fazenda);
  //  • regiao  = mapa-múndi por CONTINENTE — onde o bicho vive (norte/sul/africa/
  //    asia/australia/artico/oceano/ceu). Ex.: tigre habitat 'selva' mas regiao 'asia';
  //    alce habitat 'artico' mas regiao 'norte' (EUA). Ver palavrasDoHabitat/palavrasDaRegiao.
  // Dentro de cada grupo a tela roda do MENOS ao MAIS sílabas. Sílabas de 2 a 5.
  // ❄️ Ártico (habitat) → Ártico/América do Norte (região)
  Palavra(['fo', 'ca'], Categoria.animais, sub: 'aquatico', habitat: 'artico', regiao: 'artico'),
  Palavra(['pin', 'guim'], Categoria.animais, sub: 'aquatico', habitat: 'artico', regiao: 'artico'),
  Palavra(['mor', 'sa'], Categoria.animais, sub: 'aquatico', habitat: 'artico', regiao: 'artico'),
  Palavra(['nar', 'val'], Categoria.animais, sub: 'aquatico', habitat: 'artico', regiao: 'artico'),
  Palavra(['lo', 'bo'], Categoria.animais, sub: 'terrestre', habitat: 'artico', regiao: 'norte'),
  Palavra(['re', 'na'], Categoria.animais, sub: 'terrestre', habitat: 'artico', regiao: 'artico'),
  Palavra(['le', 'bre'], Categoria.animais, sub: 'terrestre', habitat: 'artico', regiao: 'norte'),
  Palavra(['al', 'ce'], Categoria.animais, sub: 'terrestre', habitat: 'artico', regiao: 'norte'),
  Palavra(['ra', 'po', 'sa'], Categoria.animais, sub: 'terrestre', habitat: 'artico', regiao: 'norte'),
  Palavra(['ur', 'so', 'po', 'lar'], Categoria.animais,
      sub: 'terrestre', habitat: 'artico', regiao: 'artico', texto: 'urso polar'),
  // 🦁 Savana (habitat) → África (região); canguru vai pra Austrália
  Palavra(['le', 'ão'], Categoria.animais, sub: 'terrestre', habitat: 'savana', regiao: 'africa'),
  Palavra(['ze', 'bra'], Categoria.animais, sub: 'terrestre', habitat: 'savana', regiao: 'africa'),
  Palavra(['chi', 'ta'], Categoria.animais, sub: 'terrestre', habitat: 'savana', regiao: 'africa'),
  Palavra(['gi', 'ra', 'fa'], Categoria.animais, sub: 'terrestre', habitat: 'savana', regiao: 'africa'),
  Palavra(['bú', 'fa', 'lo'], Categoria.animais, sub: 'terrestre', habitat: 'savana', regiao: 'africa'),
  Palavra(['ga', 'ze', 'la'], Categoria.animais, sub: 'terrestre', habitat: 'savana', regiao: 'africa'),
  Palavra(['hi', 'e', 'na'], Categoria.animais, sub: 'terrestre', habitat: 'savana', regiao: 'africa'),
  Palavra(['a', 'ves', 'truz'], Categoria.animais, sub: 'terrestre', habitat: 'savana', regiao: 'africa'),
  Palavra(['can', 'gu', 'ru'], Categoria.animais, sub: 'terrestre', habitat: 'savana', regiao: 'australia'),
  Palavra(['e', 'le', 'fan', 'te'], Categoria.animais, sub: 'terrestre', habitat: 'savana', regiao: 'africa'),
  Palavra(['su', 'ri', 'ca', 'to'], Categoria.animais, sub: 'terrestre', habitat: 'savana', regiao: 'africa'),
  Palavra(['an', 'tí', 'lo', 'pe'], Categoria.animais, sub: 'terrestre', habitat: 'savana', regiao: 'africa'),
  Palavra(['hi', 'po', 'pó', 'ta', 'mo'], Categoria.animais,
      sub: 'terrestre', habitat: 'savana', regiao: 'africa'),
  Palavra(['ri', 'no', 'ce', 'ron', 'te'], Categoria.animais,
      sub: 'terrestre', habitat: 'savana', regiao: 'africa'),
  // 🌴 Selva (habitat) → dividida por continente real (região)
  Palavra(['on', 'ça'], Categoria.animais, sub: 'terrestre', habitat: 'selva', regiao: 'sul'),
  Palavra(['co', 'bra'], Categoria.animais, sub: 'terrestre', habitat: 'selva', regiao: 'sul'),
  Palavra(['ti', 'gre'], Categoria.animais, sub: 'terrestre', habitat: 'selva', regiao: 'asia'),
  Palavra(['pan', 'da'], Categoria.animais, sub: 'terrestre', habitat: 'selva', regiao: 'asia'),
  Palavra(['ma', 'ca', 'co'], Categoria.animais, sub: 'terrestre', habitat: 'selva', regiao: 'sul'),
  Palavra(['tu', 'ca', 'no'], Categoria.animais, sub: 'voador', habitat: 'selva', regiao: 'ceu'),
  Palavra(['go', 'ri', 'la'], Categoria.animais, sub: 'terrestre', habitat: 'selva', regiao: 'africa'),
  Palavra(['pre', 'gui', 'ça'], Categoria.animais, sub: 'terrestre', habitat: 'selva', regiao: 'sul'),
  Palavra(['ja', 'ca', 'ré'], Categoria.animais, sub: 'aquatico', habitat: 'selva', regiao: 'sul'),
  Palavra(['i', 'gua', 'na'], Categoria.animais, sub: 'terrestre', habitat: 'selva', regiao: 'sul'),
  Palavra(['le', 'o', 'par', 'do'], Categoria.animais, sub: 'terrestre', habitat: 'selva', regiao: 'asia'),
  Palavra(['ta', 'man', 'du', 'á'], Categoria.animais, sub: 'terrestre', habitat: 'selva', regiao: 'sul'),
  Palavra(['ca', 'ma', 'le', 'ão'], Categoria.animais, sub: 'terrestre', habitat: 'selva', regiao: 'africa'),
  Palavra(['bor', 'bo', 'le', 'ta'], Categoria.animais, sub: 'voador', habitat: 'selva', regiao: 'sul'),
  // 🐠 Aquático (habitat) → Oceano (região)
  Palavra(['pei', 'xe'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano'),
  Palavra(['pol', 'vo'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano'),
  Palavra(['rai', 'a'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano'),
  Palavra(['or', 'ca'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano'),
  Palavra(['lu', 'la'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano'),
  Palavra(['os', 'tra'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano'),
  Palavra(['sal', 'mão'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano'),
  Palavra(['ba', 'lei', 'a'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano'),
  Palavra(['gol', 'fi', 'nho'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano'),
  Palavra(['tu', 'ba', 'rão'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano'),
  Palavra(['ca', 'ma', 'rão'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano'),
  Palavra(['tar', 'ta', 'ru', 'ga'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano'),
  Palavra(['ca', 'ran', 'gue', 'jo'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano'),
  Palavra(['cro', 'co', 'di', 'lo'], Categoria.animais, sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano'),
  Palavra(['á', 'gua', 'vi', 'va'], Categoria.animais,
      sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano', texto: 'água-viva'),
  Palavra(['es', 'tre', 'la', 'do', 'mar'], Categoria.animais,
      sub: 'aquatico', habitat: 'aquatico', regiao: 'oceano', texto: 'estrela-do-mar'),
  // 🦅 Aves (habitat) → Céu (região)
  Palavra(['pom', 'ba'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['pa', 'to'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['ga', 'lo'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['pa', 'vão'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['par', 'dal'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['á', 'gui', 'a'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['a', 'ra', 'ra'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['co', 'ru', 'ja'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['gai', 'vo', 'ta'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['fla', 'min', 'go'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['ce', 'go', 'nha'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['ga', 'li', 'nha'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['u', 'ru', 'bu'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['bei', 'ja', 'flor'], Categoria.animais,
      sub: 'voador', habitat: 'aves', regiao: 'ceu', texto: 'beija-flor'),
  Palavra(['pa', 'pa', 'gai', 'o'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['ca', 'ná', 'ri', 'o'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['an', 'do', 'ri', 'nha'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  Palavra(['pe', 'li', 'ca', 'no'], Categoria.animais, sub: 'voador', habitat: 'aves', regiao: 'ceu'),
  // 🐮 Fazenda (habitat) → América do Norte (região)
  Palavra(['va', 'ca'], Categoria.animais, sub: 'terrestre', habitat: 'fazenda', regiao: 'norte'),
  Palavra(['por', 'co'], Categoria.animais, sub: 'terrestre', habitat: 'fazenda', regiao: 'norte'),
  Palavra(['bur', 'ro'], Categoria.animais, sub: 'terrestre', habitat: 'fazenda', regiao: 'norte'),
  Palavra(['ca', 'bra'], Categoria.animais, sub: 'terrestre', habitat: 'fazenda', regiao: 'norte'),
  Palavra(['bo', 'de'], Categoria.animais, sub: 'terrestre', habitat: 'fazenda', regiao: 'norte'),
  Palavra(['gan', 'so'], Categoria.animais, sub: 'terrestre', habitat: 'fazenda', regiao: 'norte'),
  Palavra(['ga', 'to'], Categoria.animais, sub: 'terrestre', habitat: 'fazenda', regiao: 'norte'),
  Palavra(['pô', 'nei'], Categoria.animais, sub: 'terrestre', habitat: 'fazenda', regiao: 'norte'),
  Palavra(['ca', 'va', 'lo'], Categoria.animais, sub: 'terrestre', habitat: 'fazenda', regiao: 'norte'),
  Palavra(['o', 've', 'lha'], Categoria.animais, sub: 'terrestre', habitat: 'fazenda', regiao: 'norte'),
  Palavra(['co', 'e', 'lho'], Categoria.animais, sub: 'terrestre', habitat: 'fazenda', regiao: 'norte'),
  Palavra(['ca', 'chor', 'ro'], Categoria.animais, sub: 'terrestre', habitat: 'fazenda', regiao: 'norte'),
  Palavra(['car', 'nei', 'ro'], Categoria.animais, sub: 'terrestre', habitat: 'fazenda', regiao: 'norte'),
  Palavra(['be', 'zer', 'ro'], Categoria.animais, sub: 'terrestre', habitat: 'fazenda', regiao: 'norte'),
  // ✨ Só-região (sem célula de habitat) — enchem Ásia e Austrália no mapa-múndi
  // 🐼 Ásia
  Palavra(['ca', 'me', 'lo'], Categoria.animais, sub: 'terrestre', regiao: 'asia'),
  Palavra(['o', 'ran', 'go', 'tan', 'go'], Categoria.animais, sub: 'terrestre', regiao: 'asia'),
  // 🦘 Austrália
  Palavra(['co', 'a', 'la'], Categoria.animais, sub: 'terrestre', regiao: 'australia'),
  Palavra(['e', 'mu'], Categoria.animais, sub: 'terrestre', regiao: 'australia'),
  Palavra(['din', 'go'], Categoria.animais, sub: 'terrestre', regiao: 'australia'),
  Palavra(['or', 'ni', 'to', 'rrin', 'co'], Categoria.animais, sub: 'aquatico', regiao: 'australia'),

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

  // ───────────────────────── TEMAS (CIDADE) ─────────────────────────
  // Palavras dos lugares da foto dos Temas (Objetos → Temas). Vivem na categoria
  // `objetos` só por herança de banco: NÃO entram nos níveis normais (palavrasDe
  // filtra `tema == null`) — são jogadas apenas no estudo do tema (palavrasDoTema).
  // 🏠 Casa
  Palavra(['so', 'fá'], Categoria.objetos, tema: 'casa'),
  Palavra(['pi', 'a'], Categoria.objetos, tema: 'casa'),
  Palavra(['bu', 'le'], Categoria.objetos, tema: 'casa'),
  Palavra(['len', 'çol'], Categoria.objetos, tema: 'casa'),
  Palavra(['col', 'chão'], Categoria.objetos, tema: 'casa'),
  Palavra(['quar', 'to'], Categoria.objetos, tema: 'casa'),
  Palavra(['sa', 'la'], Categoria.objetos, tema: 'casa'),
  Palavra(['rou', 'pa'], Categoria.objetos, tema: 'casa'),
  Palavra(['to', 'a', 'lha'], Categoria.objetos, tema: 'casa'),
  Palavra(['lâm', 'pa', 'da'], Categoria.objetos, tema: 'casa'),
  Palavra(['chu', 'vei', 'ro'], Categoria.objetos, tema: 'casa'),
  Palavra(['pi', 'ja', 'ma'], Categoria.objetos, tema: 'casa'),
  Palavra(['ta', 'pe', 'te'], Categoria.objetos, tema: 'casa'),
  Palavra(['co', 'zi', 'nha'], Categoria.objetos, tema: 'casa'),
  Palavra(['ga', 'ra', 'gem'], Categoria.objetos, tema: 'casa'),
  Palavra(['sa', 'ca', 'da'], Categoria.objetos, tema: 'casa'),
  Palavra(['cô', 'mo', 'da'], Categoria.objetos, tema: 'casa'),
  Palavra(['ba', 'nhei', 'ra'], Categoria.objetos, tema: 'casa'),
  Palavra(['guar', 'da', 'rou', 'pa'], Categoria.objetos, tema: 'casa', texto: 'guarda-roupa'),
  Palavra(['in', 'ter', 'rup', 'tor'], Categoria.objetos, tema: 'casa'),
  Palavra(['es', 'cor', 're', 'dor'], Categoria.objetos, tema: 'casa'),
  Palavra(['por', 'ta', 're', 'tra', 'to'], Categoria.objetos, tema: 'casa', texto: 'porta-retrato'),
  // 🏛️ Museu
  Palavra(['qua', 'dro'], Categoria.objetos, tema: 'museu'),
  Palavra(['te', 'la'], Categoria.objetos, tema: 'museu'),
  Palavra(['fós', 'sil'], Categoria.objetos, tema: 'museu'),
  Palavra(['mu', 'seu'], Categoria.objetos, tema: 'museu'),
  Palavra(['ar', 'te'], Categoria.objetos, tema: 'museu'),
  Palavra(['bron', 'ze'], Categoria.objetos, tema: 'museu'),
  Palavra(['pin', 'tu', 'ra'], Categoria.objetos, tema: 'museu'),
  Palavra(['es', 'tá', 'tua'], Categoria.objetos, tema: 'museu'),
  Palavra(['mol', 'du', 'ra'], Categoria.objetos, tema: 'museu'),
  Palavra(['vi', 'tri', 'ne'], Categoria.objetos, tema: 'museu'),
  Palavra(['es', 'cul', 'tor'], Categoria.objetos, tema: 'museu'),
  Palavra(['es', 'cul', 'tu', 'ra'], Categoria.objetos, tema: 'museu'),
  Palavra(['ga', 'le', 'ri', 'a'], Categoria.objetos, tema: 'museu'),
  Palavra(['di', 'nos', 'sau', 'ro'], Categoria.objetos, tema: 'museu'),
  Palavra(['ce', 'râ', 'mi', 'ca'], Categoria.objetos, tema: 'museu'),
  Palavra(['pi', 'râ', 'mi', 'de'], Categoria.objetos, tema: 'museu'),
  // 🏫 Escola
  Palavra(['ré', 'gua'], Categoria.objetos, tema: 'escola'),
  Palavra(['au', 'la'], Categoria.objetos, tema: 'escola'),
  Palavra(['pro', 'va'], Categoria.objetos, tema: 'escola'),
  Palavra(['qua', 'dro'], Categoria.objetos, tema: 'escola'),
  Palavra(['sa', 'la'], Categoria.objetos, tema: 'escola'),
  Palavra(['pá', 'tio'], Categoria.objetos, tema: 'escola'),
  Palavra(['lou', 'sa'], Categoria.objetos, tema: 'escola'),
  Palavra(['a', 'lu', 'no'], Categoria.objetos, tema: 'escola'),
  Palavra(['bor', 'ra', 'cha'], Categoria.objetos, tema: 'escola'),
  Palavra(['es', 'to', 'jo'], Categoria.objetos, tema: 'escola'),
  Palavra(['mo', 'chi', 'la'], Categoria.objetos, tema: 'escola'),
  Palavra(['lan', 'chei', 'ra'], Categoria.objetos, tema: 'escola'),
  Palavra(['car', 'tei', 'ra'], Categoria.objetos, tema: 'escola'),
  Palavra(['can', 'ti', 'na'], Categoria.objetos, tema: 'escola'),
  Palavra(['re', 'crei', 'o'], Categoria.objetos, tema: 'escola'),
  Palavra(['pro', 'fes', 'so', 'ra'], Categoria.objetos, tema: 'escola'),
  Palavra(['di', 're', 'to', 'ra'], Categoria.objetos, tema: 'escola'),
  Palavra(['ta', 'bu', 'a', 'da'], Categoria.objetos, tema: 'escola'),
  Palavra(['a', 'pon', 'ta', 'dor'], Categoria.objetos, tema: 'escola'),
  Palavra(['me', 'ren', 'dei', 'ra'], Categoria.objetos, tema: 'escola'),
  // ☕ Cafeteria
  Palavra(['ca', 'fé'], Categoria.objetos, tema: 'cafeteria'),
  Palavra(['bo', 'lo'], Categoria.objetos, tema: 'cafeteria'),
  Palavra(['pas', 'tel'], Categoria.objetos, tema: 'cafeteria'),
  Palavra(['pu', 'dim'], Categoria.objetos, tema: 'cafeteria'),
  Palavra(['gar', 'çom'], Categoria.objetos, tema: 'cafeteria'),
  Palavra(['crois', 'sant'], Categoria.objetos, tema: 'cafeteria'),
  Palavra(['xí', 'ca', 'ra'], Categoria.objetos, tema: 'cafeteria'),
  Palavra(['ca', 'ne', 'ca'], Categoria.objetos, tema: 'cafeteria'),
  Palavra(['fa', 'ti', 'a'], Categoria.objetos, tema: 'cafeteria'),
  Palavra(['co', 'a', 'dor'], Categoria.objetos, tema: 'cafeteria'),
  Palavra(['co', 'xi', 'nha'], Categoria.objetos, tema: 'cafeteria'),
  Palavra(['chan', 'ti', 'lly'], Categoria.objetos, tema: 'cafeteria', texto: 'chantilly'),
  Palavra(['es', 'pres', 'so'], Categoria.objetos, tema: 'cafeteria'),
  Palavra(['san', 'du', 'í', 'che'], Categoria.objetos, tema: 'cafeteria'),
  Palavra(['cap', 'puc', 'ci', 'no'], Categoria.objetos, tema: 'cafeteria'),
  Palavra(['ca', 'fe', 'tei', 'ra'], Categoria.objetos, tema: 'cafeteria'),
  // 🚒 Bombeiros
  Palavra(['fo', 'go'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['cha', 'mas'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['ca', 'mi', 'nhão'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['es', 'ca', 'da'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['si', 're', 'ne'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['hi', 'dran', 'te'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['fu', 'ma', 'ça'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['res', 'ga', 'te'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['bom', 'bei', 'ro'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['co', 'ra', 'gem'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['man', 'guei', 'ra'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['ca', 'pa', 'ce', 'te'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['in', 'cên', 'di', 'o'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['ex', 'tin', 'tor'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['sal', 'va', 'men', 'to'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['pron', 'ti', 'dão'], Categoria.objetos, tema: 'bombeiros'),
  Palavra(['sal', 'va', 'vi', 'das'], Categoria.objetos, tema: 'bombeiros', texto: 'salva-vidas'),
];

/// Todas as sílabas do banco em CAIXA ALTA (pool de distratores do modo
/// "completar a sílaba que falta").
List<String> poolSilabasMaiusculas() {
  final set = <String>{};
  for (final p in bancoPalavras) {
    for (final s in p.silabas) {
      set.add(s.toUpperCase());
    }
  }
  return set.toList();
}

/// Palavras de uma categoria + nível, ordenadas por dificuldade (menos letras
/// primeiro; ver [Palavra.porDificuldade]).
///
/// Palavras de TEMA da cidade (`tema != null`) ficam de fora: elas NÃO rodam nos
/// níveis normais de Objetos — só no estudo do tema ([palavrasDoTema]).
List<Palavra> palavrasDe(Categoria categoria, Nivel nivel) {
  final lista = bancoPalavras
      .where((p) =>
          p.categoria == categoria &&
          p.tema == null &&
          p.nivelSilabas == nivel.silabas)
      .toList();
  lista.sort(Palavra.porDificuldade);
  return lista;
}

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
  lista.sort(Palavra.porDificuldade);
  return lista;
}

/// Animais de VÁRIOS habitats juntos, ordenados do menos ao mais sílabas.
/// Usado pela célula "Aves e Fazenda" do mapa de habitats (a Fazenda não tem
/// célula própria na grade, então entra junto das Aves).
List<Palavra> palavrasDosHabitats(List<String> chaves) {
  final lista = bancoPalavras
      .where((p) =>
          p.categoria == Categoria.animais && chaves.contains(p.habitat))
      .toList();
  lista.sort(Palavra.porDificuldade);
  return lista;
}

/// Animais de uma REGIÃO do mapa-múndi (onde o bicho vive: 'africa', 'asia'…),
/// ordenados do menos ao mais sílabas. É a classificação geográfica, diferente
/// do habitat (ver palavrasDoHabitat).
List<Palavra> palavrasDaRegiao(String regiaoChave) {
  final lista = bancoPalavras
      .where((p) => p.categoria == Categoria.animais && p.regiao == regiaoChave)
      .toList();
  lista.sort(Palavra.porDificuldade);
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

/// Palavras de um TEMA da cidade (foto dos Temas: 'casa' | 'museu' | 'escola' |
/// 'cafeteria' | 'bombeiros'), ordenadas do MENOS para o MAIS sílabas — a
/// criança começa pelas mais fáceis e vai passando (mesma ideia dos habitats).
List<Palavra> palavrasDoTema(String temaChave) {
  final lista = bancoPalavras
      .where((p) => p.tema == temaChave)
      .toList();
  lista.sort(Palavra.porDificuldade);
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
