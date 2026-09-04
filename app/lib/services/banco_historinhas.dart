import 'package:flutter/material.dart';

import '../models/livro.dart';

const List<Livro> bancoHistorinhas = [
  Livro(
    chave: 'gato_esperto',
    titulo: 'O Gato Esperto',
    emoji: '🐱',
    cor: Color(0xFFFBBF24),
    paginas: [
      'Era uma vez um gato laranja muito esperto.',
      'Ele morava em uma casa amarela com sua dona.',
      'Um dia, ele viu um rato pequenino na cozinha.',
      'O gato correu, mas o rato se escondeu rápido.',
      'No fim, eles viraram amigos e brincaram juntos o dia todo.',
    ],
  ),
  Livro(
    chave: 'pato_lagoa',
    titulo: 'O Pato na Lagoa',
    emoji: '🦆',
    cor: Color(0xFF5B9CFF),
    paginas: [
      'Numa lagoa azul morava um patinho amarelo.',
      'Ele nadava todo dia com sua mamãe pata.',
      'De repente, começou a chover muito forte.',
      'O patinho ficou com medo e chamou: Quá quá!',
      'A mamãe abraçou o patinho e a chuva passou.',
      'Então o sol voltou e eles nadaram felizes.',
    ],
  ),
  Livro(
    chave: 'sapo_feliz',
    titulo: 'O Sapo Feliz',
    emoji: '🐸',
    cor: Color(0xFF54C08A),
    paginas: [
      'O sapo verde pulava na beira do rio.',
      'Ele cantava alto: Croac croac!',
      'Os peixes vinham ouvir sua canção.',
      'Um dia, o sapo encontrou uma flor linda.',
      'Ele deu a flor para sua amiga tartaruga.',
      'E todos cantaram juntos até anoitecer.',
    ],
  ),
  Livro(
    chave: 'casa_vovo',
    titulo: 'A Casa da Vovó',
    emoji: '🏠',
    cor: Color(0xFFFF8A5B),
    paginas: [
      'Davi foi visitar a casa da vovó.',
      'A casa tinha cheiro de bolo quentinho.',
      'Vovó fez um bolo de chocolate delicioso.',
      'Davi comeu duas fatias e lambeu os dedos.',
      'Depois, vovó contou uma história antes de dormir.',
    ],
  ),
  Livro(
    chave: 'sol_lua',
    titulo: 'O Sol e a Lua',
    emoji: '🌙',
    cor: Color(0xFFB98BFF),
    paginas: [
      'O Sol brilhava forte durante o dia.',
      'Ele aquecia as crianças no parque.',
      'Quando o Sol foi dormir, a Lua apareceu.',
      'A Lua clareava a noite com suas estrelas.',
      'Sol e Lua eram amigos e nunca brigavam.',
      'Cada um tinha sua hora de brilhar no céu.',
    ],
  ),
  Livro(
    chave: 'tesouro_davi',
    titulo: 'Davi e o Tesouro',
    emoji: '🗝️',
    cor: Color(0xFFF472B6),
    paginas: [
      'Davi encontrou um mapa antigo no quarto.',
      'O mapa mostrava um tesouro no quintal.',
      'Ele cavou perto da árvore com sua pazinha.',
      'Dentro da caixa havia lápis de cor novos!',
      'Davi desenhou um arco-íris bem colorido.',
      'E guardou o mapa para a próxima aventura.',
    ],
  ),
  Livro(
    chave: 'coelho_cenoura',
    titulo: 'O Coelho e a Cenoura',
    emoji: '🐰',
    cor: Color(0xFF2DD4BF),
    paginas: [
      'O coelho branco adorava comer cenoura.',
      'Ele pulava pela horta todas as manhãs.',
      'Um dia, a cenoura gigante sumiu!',
      'O coelho procurou atrás do celeiro.',
      'Achou a cenoura com seus amigos coelhos.',
      'E dividiu com todos numa festa na horta.',
    ],
  ),
  Livro(
    chave: 'aviao_azul',
    titulo: 'O Avião Azul',
    emoji: '✈️',
    cor: Color(0xFF38BDF8),
    paginas: [
      'O avião azul voava alto no céu.',
      'Dentro dele, as crianças olhavam as nuvens.',
      'De repente, viram uma montanha branquinha.',
      'Era neve! Que frio gostoso lá em cima.',
      'O avião pousou e todos brincaram na neve.',
    ],
  ),
];

Livro? livroPorChave(String chave) {
  for (final l in bancoHistorinhas) {
    if (l.chave == chave) return l;
  }
  return null;
}
