import 'package:flutter/material.dart';

import '../models/livro.dart';

const List<Livro> bancoHistorinhas = [
  Livro(
    chave: 'gato_esperto',
    titulo: 'O Gato Esperto',
    emoji: '🐱',
    cor: Color(0xFFFBBF24),
    paginas: [
      'Era uma vez um gato laranja. Ele era muito esperto. Morava em uma casa amarela.',
      'Um dia ele viu um rato. O rato era bem pequenino. Estava na cozinha.',
      'O gato correu atrás dele. O rato se escondeu rápido. Ficou atrás do armário.',
      'O gato esperou com paciência. O rato saiu bem devagar. Os dois se olharam.',
      'No fim eles viraram amigos. Brincaram juntos o dia todo. E dormiram juntinhos.',
    ],
  ),
  Livro(
    chave: 'pato_lagoa',
    titulo: 'O Pato na Lagoa',
    emoji: '🦆',
    cor: Color(0xFF5B9CFF),
    paginas: [
      'Numa lagoa azul morava um patinho. Ele era amarelo e fofinho. Nadava com sua mamãe.',
      'Todo dia eles nadavam juntos. Davam voltas na lagoa. As águas eram calmas.',
      'De repente o céu escureceu. Começou a chover muito forte. O vento balançou as plantas.',
      'O patinho ficou com medo. Chamou bem alto: Quá quá! A mamãe nadou até ele.',
      'Ela abraçou o patinho. A chuva passou devagar. O sol voltou e eles nadaram felizes.',
    ],
  ),
  Livro(
    chave: 'sapo_feliz',
    titulo: 'O Sapo Feliz',
    emoji: '🐸',
    cor: Color(0xFF54C08A),
    paginas: [
      'Na beira do rio morava um sapo. Ele era verde e alegre. Pulava o dia todo.',
      'O sapo cantava bem alto. Cantava Croac croac sem parar. Os peixes vinham ouvir.',
      'Um dia ele encontrou uma flor. A flor era linda e cheirosa. Estava perto da pedra.',
      'Ele levou a flor de presente. Deu para sua amiga tartaruga. Ela ficou muito feliz.',
      'Todos cantaram juntos então. O rio ficou cheio de música. E cantaram até anoitecer.',
    ],
  ),
  Livro(
    chave: 'casa_vovo',
    titulo: 'A Casa da Vovó',
    emoji: '🏠',
    cor: Color(0xFFFF8A5B),
    paginas: [
      'Davi foi visitar a vovó. A casa dela é bem aconchegante. Fica perto do jardim.',
      'Ao entrar sentiu um cheirinho. Era bolo quentinho no forno. Deixou a casa perfumada.',
      'Vovó fez bolo de chocolate. A cobertura era bem cremosa. Davi ficou com água na boca.',
      'Ele comeu duas fatias grandes. Lambeu os dedos com vontade. E pediu mais um pedaço.',
      'Depois vovó contou uma história. Era sobre um castelo encantado. Davi dormiu sorrindo.',
    ],
  ),
  Livro(
    chave: 'sol_lua',
    titulo: 'O Sol e a Lua',
    emoji: '🌙',
    cor: Color(0xFFB98BFF),
    paginas: [
      'O Sol brilha forte de dia. Ele aquece todo o parque. As crianças brincam felizes.',
      'O Sol ilumina as flores. Deixa tudo bem colorido. Todos gostam do seu calor.',
      'Quando o Sol vai dormir, a Lua aparece. Ela clareia a noite escura. Traz suas estrelas.',
      'A Lua brilha com calma. Ela cuida de quem dorme. E conta histórias silenciosas.',
      'Sol e Lua são grandes amigos. Cada um tem sua hora. E nunca brigam no céu.',
    ],
  ),
  Livro(
    chave: 'tesouro_davi',
    titulo: 'Davi e o Tesouro',
    emoji: '🗝️',
    cor: Color(0xFFF472B6),
    paginas: [
      'Davi achou um mapa antigo. Estava guardado no armário. Tinha um X marcado.',
      'O mapa mostrava um tesouro. Ficava no quintal da casa. Perto da árvore grande.',
      'Ele pegou sua pazinha azul. Cavou bem fundo na terra. E cantou enquanto cavava.',
      'Dentro da caixa havia lápis. Eram lápis de cor novos. Todos bem apontados e coloridos.',
      'Davi desenhou um arco-íris. Usou todas as cores lindas. E guardou o mapa para outra aventura.',
    ],
  ),
  Livro(
    chave: 'coelho_cenoura',
    titulo: 'O Coelho e a Cenoura',
    emoji: '🐰',
    cor: Color(0xFF2DD4BF),
    paginas: [
      'O coelho branco amava cenoura. Comia toda manhã bem cedo. Pulava feliz na horta.',
      'Ele corria entre as folhas. Cheirava tudo com seu nariz. E escolhia a maior cenoura.',
      'Um dia a cenoura gigante sumiu. O coelho ficou muito triste. Procurou por todo lado.',
      'Ele olhou atrás do celeiro. Perguntou para os amigos. Todos ajudaram a procurar.',
      'Acharam a cenoura escondida. Estava atrás das abóboras. Dividiram numa festa na horta.',
    ],
  ),
  Livro(
    chave: 'aviao_azul',
    titulo: 'O Avião Azul',
    emoji: '✈️',
    cor: Color(0xFF38BDF8),
    paginas: [
      'O avião azul voava bem alto. Ele cortava o céu clarinho. Deixava um rastro branco.',
      'Dentro dele as crianças olhavam. Viam nuvens como algodão. Tudo parecia pequeno lá embaixo.',
      'De repente viram uma montanha. Ela era toda branquinha. Estava coberta de neve.',
      'Que frio gostoso lá em cima! As crianças bateram palmas. Queriam tocar na neve.',
      'O avião pousou com cuidado. Todos brincaram na neve fofa. E fizeram um boneco bem grande.',
    ],
  ),
];

Livro? livroPorChave(String chave) {
  for (final l in bancoHistorinhas) {
    if (l.chave == chave) return l;
  }
  return null;
}
