import 'package:flutter/material.dart';

import '../models/livro.dart';

const List<Livro> bancoHistorinhas = [
  Livro(
    chave: 'gato_esperto',
    titulo: 'O Gato Esperto',
    emoji: '🐱',
    cor: Color(0xFFFBBF24),
    paginas: [
      'Era uma vez um gato laranja. Ele era muito esperto. Morava em uma casa amarela. Gostava de dormir ao sol. E de olhar pela janela.',
      'Um dia ele viu um rato na cozinha. O rato era bem pequenino. Tinha bigodes longos. Corria rápido pelo chão. Procurava um pedaço de queijo.',
      'O gato correu atrás dele. O rato se escondeu rápido. Ficou atrás do armário. O gato esperou com paciência. Sem fazer nenhum barulho.',
      'O rato saiu bem devagar. Olhou para um lado e para o outro. Viu o gato parado. Os dois se olharam nos olhos. E ficaram em silêncio.',
      'No fim eles viraram amigos. Brincaram juntos o dia todo. Correram pela casa toda. Dividiram o queijo da cozinha. E dormiram juntinhos no tapete.',
    ],
  ),
  Livro(
    chave: 'pato_lagoa',
    titulo: 'O Pato na Lagoa',
    emoji: '🦆',
    cor: Color(0xFF5B9CFF),
    paginas: [
      'Numa lagoa azul morava um patinho. Ele era amarelo e fofinho. Nadava todo dia com sua mamãe. Gostava de bater as asinhas. E de mergulhar a cabeça na água.',
      'Toda manhã eles davam voltas. Nadavam em círculos na lagoa. As águas eram calmas e brilhantes. Os peixes passavam por baixo. E acenavam com as nadadeiras.',
      'De repente o céu escureceu. Veio um vento bem forte. As plantas balançaram muito. Começou a chover sem parar. A lagoa ficou toda agitada.',
      'O patinho ficou com muito medo. Chamou bem alto: Quá quá! Sua voz saiu tremida. A mamãe nadou rápido até ele. E o abraçou bem forte com as asas.',
      'A chuva passou devagarinho. O vento foi embora calmo. O sol voltou a brilhar no céu. A lagoa ficou calma outra vez. E os dois nadaram felizes até a margem.',
    ],
  ),
  Livro(
    chave: 'sapo_feliz',
    titulo: 'O Sapo Feliz',
    emoji: '🐸',
    cor: Color(0xFF54C08A),
    paginas: [
      'Na beira do rio morava um sapo. Ele era verde e muito alegre. Pulava o dia todo de pedra em pedra. Gostava de tomar sol na margem. E de cantar para os amigos.',
      'O sapo cantava bem alto. Cantava Croac croac sem parar. Sua voz ecoava pelo rio. Os peixes vinham ouvir de perto. E batiam palmas com as nadadeiras.',
      'Um dia ele encontrou uma flor. A flor era linda e muito cheirosa. Tinha pétalas amarelas e brancas. Estava perto de uma pedra grande. O sapo ficou encantado com ela.',
      'Ele colheu a flor com cuidado. Levou de presente para a tartaruga. Ela era sua melhor amiga. A tartaruga ficou muito feliz. E agradeceu com um abraço apertado.',
      'Então todos cantaram juntos. O sapo, a tartaruga e os peixes. O rio ficou cheio de música alegre. Cantaram até o sol se pôr. E dormiram felizes sob as estrelas.',
    ],
  ),
  Livro(
    chave: 'casa_vovo',
    titulo: 'A Casa da Vovó',
    emoji: '🏠',
    cor: Color(0xFFFF8A5B),
    paginas: [
      'Davi foi visitar a casa da vovó. A casa dela é bem aconchegante. Fica perto de um jardim florido. Tem cortinas brancas na janela. E um tapete macio na sala.',
      'Ao entrar Davi sentiu um cheirinho. Era bolo quentinho saindo do forno. O perfume tomou a casa toda. Vovó estava na cozinha sorrindo. E acenou para ele com carinho.',
      'Vovó fez bolo de chocolate delicioso. A cobertura era cremosa e brilhante. Tinha confeitos coloridos por cima. Davi ficou com água na boca. E não via a hora de provar.',
      'Ele comeu duas fatias bem grandes. Lambeu os dedos com muita vontade. Pediu mais um pedaço para a vovó. Ela riu e serviu com alegria. E os dois brindaram com suco.',
      'Depois vovó contou uma história. Era sobre um castelo encantado e um dragão. Davi ouviu com os olhos brilhando. Abraçou a vovó com força. E dormiu sorrindo no sofá.',
    ],
  ),
  Livro(
    chave: 'sol_lua',
    titulo: 'O Sol e a Lua',
    emoji: '🌙',
    cor: Color(0xFFB98BFF),
    paginas: [
      'O Sol brilha forte durante o dia. Ele aquece todo o parque com carinho. As crianças correm e brincam felizes. As flores abrem suas pétalas. E tudo fica mais colorido.',
      'O Sol ilumina cada cantinho. Deixa o céu bem azul e lindo. Aquece a areia da praia. Faz as árvores brilharem. E todos gostam do seu calor gostoso.',
      'Quando o Sol vai dormir tranquilo, a Lua aparece no céu. Ela clareia a noite escura com calma. Traz suas estrelas brilhantes junto. Todas piscam como luzinhas. E deixam a noite mágica.',
      'A Lua brilha suave e calma. Ela cuida de quem está dormindo. Conta histórias silenciosas no céu. Embala os sonhos das crianças. E vigia a noite com carinho.',
      'Sol e Lua são grandes amigos. Cada um tem sua hora de brilhar. Nunca brigam lá no céu. Se revezam com alegria. E deixam o mundo sempre iluminado.',
    ],
  ),
  Livro(
    chave: 'tesouro_davi',
    titulo: 'Davi e o Tesouro',
    emoji: '🗝️',
    cor: Color(0xFFF472B6),
    paginas: [
      'Davi achou um mapa muito antigo. Estava guardado no fundo do armário. Tinha um X marcado com tinta vermelha. Parecia um tesouro de pirata. E Davi ficou muito curioso.',
      'O mapa mostrava o quintal da casa. O X ficava perto da árvore grande. Bem ao lado do balanço amarelo. Davi pegou seu chapéu de aventureiro. E correu para o quintal sorrindo.',
      'Ele pegou sua pazinha azul favorita. Cavou bem fundo na terra fofa. Cantou uma música enquanto cavava. As mãos ficaram sujas de terra. Mas ele não parou de cavar.',
      'Dentro da caixa havia uma surpresa. Eram lápis de cor novinhos em folha. Todos bem apontados e muito coloridos. Tinha vermelho, azul e amarelo. Davi pulou de alegria.',
      'Com os lápis ele desenhou um arco-íris. Usou todas as cores mais lindas. Mostrou para a mamãe e o papai. Eles colaram na geladeira com orgulho. E Davi guardou o mapa para outra aventura.',
    ],
  ),
  Livro(
    chave: 'coelho_cenoura',
    titulo: 'O Coelho e a Cenoura',
    emoji: '🐰',
    cor: Color(0xFF2DD4BF),
    paginas: [
      'O coelho branco amava comer cenoura. Comia toda manhã bem cedinho. Pulava feliz pela horta verde. Cheirava cada folha com carinho. E escolhia sempre a maior.',
      'Ele corria entre as folhas frescas. Mexia o nariz sem parar. Procurava a cenoura mais crocante. As abelhas zumbiam por perto. E o sol brilhava na horta.',
      'Um dia a cenoura gigante sumiu. Era a maior de todas as cenouras. O coelho ficou muito triste e preocupado. Procurou por todos os cantos. Mas não achou em lugar nenhum.',
      'Ele olhou atrás do celeiro velho. Perguntou para o pato e a galinha. Todos os amigos ajudaram a procurar. Olharam debaixo das folhas. E seguiram as pistas no chão.',
      'Acharam a cenoura bem escondida. Estava atrás das abóboras grandes. Era tão grande que precisaram de ajuda. Levaram juntos para a clareira. E fizeram uma festa linda na horta.',
    ],
  ),
  Livro(
    chave: 'aviao_azul',
    titulo: 'O Avião Azul',
    emoji: '✈️',
    cor: Color(0xFF38BDF8),
    paginas: [
      'O avião azul voava bem alto no céu. Ele cortava as nuvens com alegria. Deixava um rastro branco e comprido. As pessoas lá de baixo acenavam. E o piloto sorria da janela.',
      'Dentro dele as crianças olhavam pela janela. Viam nuvens que pareciam algodão doce. Tudo lá embaixo parecia bem pequenino. As casas eram como brinquedos. E os rios pareciam fitas azuis.',
      'De repente viram uma montanha enorme. Ela era toda branquinha e brilhante. Estava coberta de neve fofinha. O topo tocava o céu azul. E brilhava com o sol forte.',
      'Que frio gostoso lá em cima da montanha! As crianças bateram palmas animadas. Queriam tocar na neve branquinha. O piloto avisou que iam pousar. E todos colocaram o casaco quentinho.',
      'O avião pousou com cuidado na neve. Todos desceram bem devagarinho. Brincaram na neve fofa e gelada. Fizeram um boneco de neve bem grande. E riram muito até a hora de voltar.',
    ],
  ),
];

Livro? livroPorChave(String chave) {
  for (final l in bancoHistorinhas) {
    if (l.chave == chave) return l;
  }
  return null;
}
