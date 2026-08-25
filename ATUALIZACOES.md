# Atualizações — Primeiras Palavras

Mudanças visíveis para o usuário. Topo = mais recente.

## v0.46.0 (2026-08-25)
- **Baú em cubo 90° com tampa visível 🧊🧰:** o baú agora aparece em perspectiva de cubo (frente + lateral a 90°): corpo com face lateral distinta à direita, interior com parede lateral e friso dourado em L, e **tampa dupla** (frente + lateral de 90°) que abre uniformemente para trás com `cos/sin` — dá para ver claramente a espessura da tampa, a dobradiça traseira e o interior enquanto levanta, sem inclinar só de um lado. Mantém moedas elípticas 3D e animação lenta.

## v0.45.0 (2026-08-25)
- **Baú refeito com realismo ✨🧰:** moedas agora são elipses douradas em 3D vistas de cima (com espessura lateral e brilho), não mais círculos frontais que pareciam "olhos"; pilha em 4 fileiras com joias incrustadas, brilho mais nítido e sombra interna. Tampa com dobradiça simétrica abre uniformemente para trás (perspectiva com `cos/sin` do ângulo até 110°) sem inclinar só de um lado, e corpo com veios/contraste mais nítido, bordas douradas com luz e rebites com reflexo. Animação mais lenta e fluida (`1100ms` + curva `easeInOutCubic`).


## v0.44.0 (2026-08-24)
- **Mapa-múndi novo em alta qualidade 🌍✨:** ao clicar em Animais → Mapa-múndi,
  a imagem foi trocada pela nova 1679×937 (mesma arte, mais nítida). **Círculos
  clicáveis mantidos exatamente nas mesmas posições** e a imagem ocupa a tela
  toda no fundo (`BoxFit.fill`).

## v0.43.0 (2026-08-24)
- **Novo mapa dos Animais 🗺️🦁 + coleção sem MAPA:** ao clicar em Animais, a
  imagem 1536×1024 com 6 cenários (Ártico/Savana/Selva/Aquático/Fazenda/Mapa)
  aparece exatamente como enviada (sem cortes, 3×2). Na **Coleção de animais**
  o botão "MAPA" foi removido — ficam só **ALIMENTOS 🍎** e **OBJETOS 🧸**.

## v0.42.0 (2026-08-24)
- **Coleções interligadas 3 vias 🔄🐾🍎🧸:** cada coleção agora tem 2 botões para
  as outras: **Animais ↔ Alimentos ↔ Objetos** (ex.: Alimentos tem 🧸 e 🐾;
  Objetos tem 🍎 e 🐾; Animais tem 🍎 e 🧸) — navegação direta sem voltar.

## v0.41.0 (2026-08-24)
- **Coleções cruzadas 🔄🍎🧸:** dentro da **Coleção de Alimentos** o botão
  "FAZENDA" virou **"OBJETOS" 🧸** (vai direto para a coleção de Objetos); na
  **Coleção de Objetos** o botão "TEMAS" virou **"ALIMENTOS" 🍎** — navegação
  direta entre coleções, sem precisar voltar.

## v0.40.0 (2026-08-24)
- **Moedas nos Temas + coleções na Home 🪙🏠:** **Objetos → Temas** e
  **Alimentos → Temas** agora mostram **🪙 moedas · Nv** no topo direito (igual
  Animais/Objetos). Na **Home** entraram 2 ícones novos ao lado da patinha:
  **🍎 Alimentos** e **🧸 Objetos** — abrem suas coleções saborosa/de brinquedos.

## v0.39.0 (2026-08-24)
- **Nível só no baú (1 por fase) + moedas no topo 🪙⬆️:** nível não sobe mais a
  cada palavra — só quando **conclui a fase e toca no baú** (mapa-múndi, Temas
  Objetos e Temas Alimentos: cada baú = +1 nível = 25 XP). Ao clicar em
  **Animais** e **Objetos** (e Alimentos) o topo direito agora mostra
  **🪙 moedas · Nv** sempre visível.

## v0.38.0 (2026-08-24)
- **Temas Alimentos agora com palavras da rotina 🍎🥬:** Mercado/Pomar/Horta/Roça/
  Arrozal trocados de exóticos (jabuticaba, seriguela, gergelim…) para **familiares**
  como nos níveis: **maçã, pera, uva, banana, ovo, leite, carne, arroz, feijão,
  peixe, tomate, cenoura** — começam curtas e conhecidas, depois as mais longas.

## v0.37.0 (2026-08-24)
- **Coleção de objetos 🧸🎮 + baú e caminhos nos Temas 🏛️➖:** coleção deixou de
  ser 🍎 e agora é de brinquedos: 🧸 Brinquedo, 🎮 Videogame, 🎒 Mochila,
  ⚽ Bola, 🚲 Bicicleta + bônus 🎁 Presente. Fases concluídas nos **Temas
  Objetos se ligam com linha neon** e, na última palavra, abre o **baú → JOGAR
  AGORA** na próxima fase (igual Alimentos/mapa-múndi). Símbolo da coleção
  trocado para 🧸.

## v0.36.0 (2026-08-24)
- **Caminhos nos Alimentos + anéis ajustados + botões Objetos 💍➖🎮:** CAJU e
  SOJA desceram mais um pouco (plantação). Fases concluídas nos Alimentos agora
  se **ligam com linha neon** (igual animais). Em **Objetos → Temas** (cidade)
  entraram os 5 botões inferiores: **VOLTAR ALIMENTOS · REINICIAR AVENTURA ·
  VOLTAR INÍCIO · COLEÇÃO 🍎 · INICIAR JOGO** (branco).

## v0.35.0 (2026-08-24)
- **Coleção de alimentos saborosos 🍎🍕 + baú nas fases 🧰:** a COLEÇÃO dos
  Alimentos deixou de mostrar bichos e agora mostra **comidas**: 🍕 Pizza,
  🍣 Sushi, 🍔 Hambúrguer, 🍝 Macarrão, 🍦 Iogurte e bônus 🍫 Chocolate.
  Ao acertar a **última palavra** de um tema, abre o **baú** — toque para abrir
  e **JOGAR AGORA** já cai na próxima fase (igual ao mapa-múndi). Anéis agora
  indicam progresso (apagado → próximo pulsando → concluído aceso).

## v0.34.0 (2026-08-24)
- **Alimentos Temas: anéis mais baixos + botões embaixo 🎮🍎:** CAJU (Pomar) e
  SOJA (Roça) desceram mais um pouco (fora das montanhas, na plantação). Na
  parte inferior entraram 5 botões iguais ao mapa-múndi: **VOLTAR ALIMENTOS ·
  REINICIAR AVENTURA · VOLTAR INÍCIO · COLEÇÃO 🍎 · INICIAR JOGO** (branco).

## v0.33.0 (2026-08-24)
- **Anéis também nos Temas dos Objetos 💍🏙️ + ajuste Alimentos:** a foto da
  cidade (Temas Objetos) agora também tem os anéis pulsantes nas 5 faixas.
  Nos Alimentos, os anéis de **CAJU (Pomar)** e **SOJA (Roça)** desceram das
  montanhas para a plantação — ficam no contexto certo.

## v0.32.0 (2026-08-24)
- **Anéis nos Temas dos Alimentos 💍🌾:** cada fase clicável da foto da fazenda
  agora tem o **anel/círculo do mapa-múndi** (neon, pulsando) no centro da área
  — igual ao dos animais. A criança vê onde tocar: Mercado, Pomar, Horta, Roça
  e Arrozal.

## v0.31.0 (2026-08-24)
- **Temas dos Alimentos com foto da fazenda 🌾🏪:** o botão "Temas" nos Alimentos
  agora abre a foto da fazenda (mercado, rio, plantação) em tela cheia, sem
  título nem bordas. **5 temas com botões invisíveis:** 🏪 Mercado, 🍎 Pomar,
  🥬 Horta, 🌾 Roça e 🍚 Arrozal — cada um com 12 palavras (60 novas) para o
  Davi estudar. Renomeado "Todos" → "Temas".

## v0.30.0 (2026-08-24)
- **Alimentos em tela cheia com foto nova 🍎🎮:** ao tocar em **Alimentos** abre
  agora a foto enviada (4 cenas: Fácil/Médio/Difícil + Todos) em tela cheia,
  sem título nem bordas — padrão do Objetos/Temas. O botão largo abaixo abre
  todas as palavras de Alimentos.

## v0.29.0 (2026-08-24)
- **Temas também 100% tela cheia 🎮:** o título "Temas" saiu, igual ao menu
  Objetos — a foto da cidade agora ocupa a tela toda sem barra superior,
  com botão de voltar flutuante discreto.

## v0.28.0 (2026-08-24)
- **Objetos sem título, 100% tela cheia 🎮:** o cabeçalho "🧸 Objetos" saiu — as 4
  cenas agora ocupam de fato a tela toda, sem margem superior. Botão de voltar
  discreto (◀ no canto) mantém a navegação com cara de jogo.

## v0.27.0 (2026-08-24)
- **Objetos em tela cheia 🎮:** o menu **Objetos** perdeu as bordas e o padding — as
  4 cenas (Fácil/Médio/Difícil/Temas) agora ocupam a tela toda em modo jogo,
  sem moldura. A legenda foi para dentro da imagem com degradê, dando cara de
  jogo imersivo.

## v0.26.0 (2026-08-24)
- **Foto dos Temas em tela cheia 🖼️📱:** a foto da cidade agora preenche quase
  a tela inteira (em vez de aparecer pequena no meio). As faixas clicáveis
  (casa, museu, escola, cafeteria, bombeiros) acompanham a imagem na nova
  posição, calculada pela matemática do corte — nada quebra em telas de
  tamanhos diferentes.

## v0.25.0 (2026-08-24)
- **Foto dos Temas clicável 🖱️🏙️:** ao abrir os **Temas** (em Objetos), a foto
  da cidade aparece inteira e cada palavra dela é um botão invisível: **casa,
  museu, escola, cafeteria e bombeiros** (da esquerda para a direita). Tocar
  num lugar abre o estudo das palavras daquele tema (cadeira, aluno, café,
  bombeiro…) — são palavras novas, fora dos níveis normais de Objetos.

## v0.24.1 (2026-08-24)
- **Foto dos Temas corrigida 🖼️:** agora abre a imagem certa (a que foi
  enviada depois) — antes o botão abria uma foto antiga.

## v0.24.0 (2026-08-24)
- **Temas abre a foto dos objetos 🖼️:** tocar em **Temas** (cena larga de
  baixo nos Objetos) agora abre a imagem que você adicionou, em tela cheia,
  com zoom e pano.

## v0.23.0 (2026-08-24)
- **Objetos com foto de cenas 🏙️:** tocar em **Objetos** abre uma tela com
  quatro cenas ilustradas. As **três de cima** são os níveis de sempre —
  **Fácil · Médio · Difícil** (com a legenda embaixo de cada) — e rodam
  exatamente como antes. A **cena larga de baixo** é o botão **Temas** (o que
  ele faz será definido depois).
- **Baú do fim de fase não corta mais em cima 🧰:** o card "NOVA FASE!" que sai
  do baú ficava cortado no topo da tela. Agora ele aparece inteiro, logo acima
  do baú aberto, com o "Mapa" e o "JOGAR AGORA" sempre visíveis. O card ficou
  mais enxuto (emoji + nome da nova fase — a voz continua anunciando o cenário).

## v0.22.0 (2026-08-23)
- **5 botões numa fileira no mapa-múndi 🗺️:** VOLTAR HABITAT · REINICIAR
  AVENTURA · VOLTAR INÍCIO · COLEÇÃO · **INICIAR/CONTINUAR JOGO** (branco,
  no fim) — todos lado a lado no rodapé, sem um cobrir o outro.

## v0.21.0 (2026-08-23)
- **Janelas do baú e do parabéns mais estreitas 📐:** os diálogos não esticam
  mais até a borda da tela — ficam do tamanho do conteúdo.
- **Medalha removida do baú:** a frase "Medalha de OURO!" sumiu da janela do
  fim de fase (o baú mostra moedas + o animal novo da coleção).
- **Botão COLEÇÃO no mapa-múndi 🐾:** embaixo, junto dos outros botões, agora
  há o "COLEÇÃO" (com a patinha) — abre a coleção de animais na hora.
- **MAPA MUNDI na coleção 🗺️:** canto superior direito da coleção de animais,
  botão "MAPA MUNDI" que leva direto ao mapa — e a coleção se atualiza ao
  voltar.

## v0.20.0 (2026-08-23)
- **Baú muito mais caprichado 🧰✨:** novo desenho com **tábuas de madeira com
  veios**, **faixas de ouro com rebites**, **cadeado com buraco de fechadura**,
  tampa **abaulada com friso dourado e brasão**. E o **tesouro de dentro**:
  quando a tampa abre, aparecem **moedas de ouro empilhadas com joias
  (esmeralda e safira)** e brilhos — e moedas **escorrem pela frente** do baú!

## v0.19.0 (2026-08-23)
- **"Sair" do parabéns agora VOLTA para os cenários ↩️:** ao terminar uma categoria
  fora do mapa-múndi, o "Sair" tem a mesma função do "Voltar" — sai da categoria
  e volta para os mapas. ("Jogar de novo" continua recomeçando a categoria.)
- **BAÚ do tesouro de verdade 🧰:** em vez da caixinha de presente, ao concluir
  uma fase do mapa-múndi aparece um **baú de madeira fechado** com faixas e
  cadeado de ouro. O Davi **toca no baú** → a tampa abre animada com brilho
  dourado, estouram confetes 🎉 e **sai o card da nova fase** ("Você desbloqueou
  o cenário Ártico!") com **▶ JOGAR AGORA**. Na última fase, o card mostra o
  🏆 da aventura completa.

## v0.18.0 (2026-08-22)
- **Jogo continua de onde parou ▶️:** o botão do mapa-múndi virou **CONTINUAR JOGO**
  quando já existe progresso — volta exatamente na próxima fase não concluída
  (e **REINICIAR JOGO** quando todas já foram feitas). Não recomeça mais do zero.
- **Parabéns ao terminar qualquer categoria 🎉:** acabou as palavras de um tema
  (habitat, nível, meus animais…) sem passar pelo mapa-múndi → festa de
  **PARABÉNS! 🏆** com confetes, e o Davi escolhe **"Jogar de novo"** ou **"Sair"**.
- **Anúncio de fase nova sem sobreposição 🔧:** o texto "Pronto para conhecer os
  animais dele?" foi ajustado pra caber junto com o botão ▶ JOGAR AGORA, sem
  rolar nem ficar um por cima do outro.

## v0.17.0 (2026-08-22)
- **O app FALA as palavras 🗣️:** a voz do celular lê cada palavra em voz alta
  (português, ritmo devagar) quando ela aparece na tela — e anuncia "Fase
  concluída!", "Você desbloqueou o cenário Ártico!" e o parabéns da aventura.
  Dá pra **desligar** na engrenagem ⚙️ → "Falar a palavra" (padrão: ligado).
- **Vibração de toque 📳:** o celular vibra de leve no acerto, firme no erro e
  mais forte no baú do fim de fase — resposta tátil do jogo.

## v0.16.0 (2026-08-22)
- **Sequência de acertos 🔥:** acertou **3 palavras seguidas sem errar** → "🔥 3 seguidas! +2" e bônus
  de moedas que cresce a cada 3 (6 seguidas = +4, 9 = +6…). A chama aparece no topo da tela. Errou,
  zerou. E o **baú** do fim de fase agora também mostra **qual animal entrou na coleção**.
- **Confetes 🎉:** estrelinhas coloridas voam a cada acerto de palavra e no baú do fim de fase.
- **Anel pulsando no mapa ✨:** no mapa-múndi, o **próximo habitat a jogar** fica pulsando com brilho
  neon — a criança vê para onde a aventura continua sem precisar adivinhar.
- **Coleção de animais 🐾:** novo botão (patinha 🐾) na tela inicial — cada fase concluída no
  mapa-múndi **ganha o animal da região** (8 no total: 🦌 🐻❄️ 🦅 🐼 🦘 🦁 🐬 🐒). Ainda não ganhou =
  ❓ "Fase pendente".

## v0.15.0 (2026-08-22)
- **Aventura CONTÍNUA no mapa-múndi! 🌍** Ao concluir uma fase, depois do baú 🎁, aparece o anúncio
  **"Você desbloqueou o cenário …!"** com o bicho da próxima região pulando — e o botão **▶ JOGAR AGORA**
  leva direto para a próxima fase, sem precisar voltar ao mapa. Na última fase, um **parabéns pela
  aventura completa** 🏆🎉.

## v0.14.3 (2026-08-20)
- **Zerar pontuação nas Configurações:** na engrenagem ⚙️, ao lado do − das moedas, um
  botão **↺** zera as moedas **e** o nível do Davi (com confirmação antes).
- **Moedas subindo nas Contas:** ao acertar uma conta, aparece o **+1 / +2** subindo na
  tela (como nas palavras) — a criança vê as moedas chegando.

## v0.14.2 (2026-08-19)
- **Rabiscar e cor de fundo nas Contas:** a tela das contas ganhou as **canetas coloridas**
  (azul/vermelho/amarelo/roxo) com **vassoura** e **desfazer** na lateral, e as bolinhas de
  **cor de fundo** no topo — igual à tela de palavras. Dá pra **escrever/riscar por cima** da
  conta enquanto resolve.

## v0.14.1 (2026-08-19)
- **Escrever no modo "Completar":** voltaram as **canetas coloridas** (azul/vermelho/amarelo/roxo),
  a **vassoura** e o **desfazer** no modo de completar a sílaba — dá pra **escrever por cima** da
  palavra normalmente, como nos outros modos. (Tinham sumido por engano na versão anterior.)

## v0.14.0 (2026-08-19)
- **Completar a sílaba que falta! 🧩** Novo modo (na engrenagem ⚙️ → "Como mostrar as palavras"):
  a palavra aparece em MAIÚSCULAS com **uma sílaba faltando** (nunca a primeira) e a criança escolhe
  a certa entre **4 opções**. Acertou → ganha moedas e passa; errou → a opção fica **vermelha** e
  pode tentar de novo. (Agora são 3 modos: **MAIÚSCULAS · minúsculas · Completar**.)
- **Ordem mais justa das palavras:** dentro de cada tema, as palavras agora vêm **das que têm menos
  letras para as com mais** (e depois por sílabas). Ex.: **RENA** (4 letras) vem antes de **PINGUIM**
  (7), mesmo as duas tendo 2 sílabas — as mais curtinhas primeiro.

## v0.13.0 (2026-08-19)
- **Tela cheia em TODAS as telas:** objetos, alimentos, nomes, contas etc. agora também ficam
  **sem a barra do sistema** (rede/bateria/horário) — igual aos animais. Clima de jogo em tudo.
- **Palavras em minúsculas:** na engrenagem ⚙️ (**Como mostrar as palavras**) dá pra escolher
  **MAIÚSCULAS** ou **minúsculas** — a palavra completa, só muda o caixa. (Em breve: completar a
  sílaba que falta.)
- **Contas "Até 20":** nova opção com **soma de números até 20** (ex.: 5+19, 15+15, 7+10).
- **Menu de Contas sem rolar:** os botões ficaram **menores** e cabem todos numa tela só (a tela
  deitada é bem aproveitada) — não precisa mais rolar.
- **Logo ao lado do título** na tela inicial (antes do "JOGO DO DAVI") e **nome do app com maiúscula:
  "Jogo do Davi"**.

## v0.12.1 (2026-08-19)
- **Logo maior:** o menino no ícone do app ficou **bem maior** (menos espaço em volta) — e
  continua **inteiro**, sem cortar cabeça/pés, mesmo no ícone redondo do Android.
- **Nome do app:** embaixo do ícone no Android agora aparece **"jogo do Davi"**.
- **Contas com Anterior/Próximo:** na tela das contas dá pra **passar** ou **voltar** de conta
  sem precisar responder.

## v0.12.0 (2026-08-19)
- **Novo tema: Contas 🧮** Na tela inicial entrou o tema **Contas** (calculadora): **soma e
  subtração**, com **1 ou 2 dígitos** (você escolhe). A conta aparece grande (ex.: "12 + 7 =") e a
  criança digita o resultado num **teclado numérico**; o app diz se acertou e dá **+1 moeda** (1
  dígito) ou **+2** (2 dígitos). Tem também **"Escrever contas"** pra você sugerir as suas próprias
  (ex.: "12 + 7").
- **Correção do mapa-múndi:** tocar no **Céu** estava abrindo os bichos da Ásia (tigre, panda) —
  agora abre certinho as **aves**. (A área de toque de um anel estava invadindo a fase de cima.)
- **Botão Início na tela das palavras:** subiu e foi um tico pra direita — fica **alinhado** com o
  topo e não encosta mais na primeira cor de caneta (azul).

## v0.11.0 (2026-08-19)
- **Mapa-múndi por CONTINENTE! 🌍** As fases do mapa-múndi não repetem mais os habitats — agora
  são organizadas por **onde cada bicho vive de verdade**: 🦌 América do Norte · 🐒 América do
  Sul · 🦁 África · 🐼 Ásia · 🦘 Austrália · ❄️ Ártico · 🐬 Oceano · 🦅 Céu. Assim o Davi aprende
  em que parte do planeta cada animal mora (leão na África, macaco no Brasil, panda na Ásia, alce
  nos EUA…). A tela de **habitats** (savana, selva, aves…) continua igual — muda só o mapa-múndi.
- **Bichos novos:** entraram 🐫 camelo e 🦧 orangotango (Ásia) e 🐨 coala, emu, dingo e
  ornitorrinco (Austrália), pra essas regiões ficarem bem cheias.

## v0.10.20 (2026-08-19)
- **Botão "Início" bem visível:** na tela das palavras, o botão **🏠 Início**
  ficou **flutuante no canto superior esquerdo** (casinha + nome) — dá pra
  voltar à página inicial de qualquer lugar.

## v0.10.19 (2026-08-19)
- **Botão Início 🏠:** na tela das palavras, ao lado do "Voltar", entrou o
  botão **"Início"** com casinha — toque e vá **direto pra página inicial**,
  de qualquer lugar.

## v0.10.18 (2026-08-19)
- **Botão Voltar com flecha:** na tela das palavras, o botão "Voltar" trocou o
  símbolo de casinha 🏠 por uma **seta para a esquerda** ← (volta pra página
  anterior).

## v0.10.17 (2026-08-19)
- **Moedas ao lado da engrenagem (garantido):** a pontuação virou uma
  **caixinha com fundo** 🪙 moedas · Nv, na barra do topo, **colada à esquerda
  do botão de configurações ⚙️**. (Teste automático confere a posição.)

## v0.10.16 (2026-08-19)
- **Pontuação GIGANTE:** o "+2 / +3 / +4" (verde) do acerto e o "−" (vermelho)
  do erro agora aparecem com fonte **52px** — impossível não ver.
- **Moedas e nível ao lado da engrenagem:** na tela inicial, o "🪙 moedas ·
  Nv" fica na **barra do topo, ao lado do botão de configurações** ⚙️.

## v0.10.15 (2026-08-19)
- **Pontuação BEM maior:** o "+2 / +3 / +4" (verde) do acerto ficou com fonte
  ainda maior (42px) — impossível não ver.
- **Mapa-múndi (confirmado):** **INICIAR JOGO** (branco) está no **canto
  inferior direito**; **Voltar habitat, Reiniciar aventura e Voltar início**
  no canto inferior esquerdo.
- ⚠️ Se a versão na tela inicial não for **v0.10.15**, o APK instalado é antigo
  (cache do navegador). Baixe pelo link novo abaixo.

## v0.10.14 (2026-08-19)
- **Pontuação maior:** o "+2 / +3 / +4" (verde) e o "−" (vermelho) do acerto/
  erro na tela das palavras ficaram com a **fonte maior**.
- **Mapa-múndi — botões redistribuídos:** **INICIAR JOGO** agora fica no
  **canto inferior direito** (branco) e os demais (Voltar habitat, Reiniciar
  aventura, Voltar início) no **canto inferior esquerdo**.

## v0.10.13 (2026-08-19)
- **Logo do menino corrigido de vez:** o ícone do app agora mostra o **menino
  sentado na cadeira inteiro** (cabeça e pés aparecem), no fundo âmbar. O
  problema anterior era a pele alaranjada do menino sendo confundida com o
  fundo e "furada".

## v0.10.12 (2026-08-19)
- **Logo ajustado:** a figura da criança aparece **inteira** no ícone do app
  (antes o recorte quadrado cortava a cabeça). O fundo âmbar preenche os
  lados.

## v0.10.11 (2026-08-19)
- **Editar pontuação na engrenagem ⚙️:** na tela de Configurações agora tem a
  seção **Pontuação** — o pai/mãe pode **ajustar as moedas 🪙 e o nível ⭐** do
  Davi com botões −/+ (toque muda 1; segurar pressionado muda 10 nas moedas).
  Útil pra recomeçar a contagem ou corrigir. As moedas e o nível atualizam em
  todas as telas na hora.

## v0.10.10 (2026-08-19)
- **Novo nome:** a tela inicial agora se chama **"JOGO DO DAVI"** 🎮
- **Novo logo do aplicativo:** a imagem que você enviou virou o ícone do app
  (na tela do celular).
- **"Selva" mais para a esquerda:** saiu mais um pouquinho — agora fica
  totalmente fora da caixinha de moedas do mapa de animais.
- **Pontuação no meio do topo:** o "+2 / +3 / +4" do acerto (e o "−" do erro)
  agora aparece **no topo, centralizado** — não fica mais por cima da palavra.

## v0.10.9 (2026-08-18)
- **"Selva" sem conflito:** o título da categoria Selva no mapa de animais
  saiu um pouquinho para a esquerda — não fica mais por baixo da caixinha de
  moedas (que segue no canto superior direito).
- **Tela inicial bem compacta:** os 4 temas (Animais, Objetos, Alimentos,
  Nomes) ficam **um ao lado do outro numa linha só**, com "Escrever" embaixo —
  cartões baixinhos, tudo visível sem rolar.

## v0.10.8 (2026-08-18)
- **Moedas no mapa de animais e no mapa-múndi:** as moedas 🪙 (e o nível)
  aparecem no **canto superior direito** dos dois mapas — ao lado da "Selva"
  no mapa de habitats e no topo do mapa-múndi — sempre atualizadas.
- **Tela inicial mais compacta:** os temas agora ficam em **4 colunas** com
  cartões menores — tudo cabe na tela deitada **sem precisar rolar**.

## v0.10.7 (2026-08-18)
- **V/X mais para dentro:** o botão de errar (X) ganhou mais folga da borda —
  a borda branca não sai mais da tela.
- **Moedas em mais telas:**
  - Na tela inicial, ao lado de **"Escolha um tema"** (canto direito).
  - No mapa de habitats dos animais, no **canto superior direito** (perto da
    "Selva").
  - Na tela das palavras já apareciam (topo direito).
- **App inteiro deitado (paisagem):** já vale pra TODAS as telas — início,
  categorias, Escrever, seleção de animais (o aplicativo inteiro vira deitado
  pra dar sensação de jogo).

## v0.10.6 (2026-08-18)
- **App todo DEITADO (paisagem)!** Não é só mais a parte dos animais: todas as
  telas (início, categorias, Escrever, seleção de animais) agora ficam deitadas.
- **V/X com respiro:** os botões de acertar/errar ficaram um pouquinho para a
  esquerda (a borda branca não é mais cortada pela tela).
- **Pontuação sempre na tela:** na tela inicial aparece o **🪙 (moedas) e o
  nível (Nv)** o tempo todo — atualiza sozinho ao voltar de qualquer tela.
- **Mapa-múndi só com os círculos:** confirmado — os anéis das fases agora são
  **apenas círculos**, sem nenhum emoji (nem dos bichos, nem medalhinha).

## v0.10.5 (2026-08-18)
- **V/X no canto (garantido):** os botões agora são **flutuantes**, colados no
  canto superior direito da tela, sempre **um ao lado do outro** — nada de
  empilhar.
- **Botões de baixo do mapa-múndi:** os 4 (Voltar habitat, Reiniciar aventura,
  Iniciar jogo, Voltar início) agora ficam **todos lado a lado numa única
  linha** — nenhum cobre o outro (em telas estreitas eles encolhem juntos).
- **Mapa-múndi sem emojis:** removidos os emojis dos anéis (❄️🐮🐠🌴🦁🦅) —
  ficam só os **círculos/anéis** das fases onde estão (com a medalha quando a
  fase é concluída).

## v0.10.4 (2026-08-18)
- **V/X (correção de verdade):** os botões agora ficam **colados no canto
  superior direito da tela** (sem nenhuma margem) e são **quadrados de 40×40
  com bordas levemente arredondadas** — não redondos.
- **Mapa-múndi (correção):** o botão **INICIAR JOGO** não fica mais por cima do
  "Reiniciar aventura" — os 4 botões de baixo agora ficam todos numa linha
  única centralizada, sem nenhum se sobrepor.

## v0.10.3 (2026-08-18)
- **Botões V/X (ajuste):** agora ficam **bem no canto superior direito**
  (sem espaço até a margem) e viraram **quadrados com cantos arredondados**,
  no mesmo clima dos botões de baixo — não são mais redondos.

## v0.10.2 (2026-08-18)
- **▶️ Iniciar jogo (ajuste):** agora o botão fica **centralizado embaixo**, no
  mesmo tamanho/estilo dos demais (Voltar habitat, Reiniciar aventura, Voltar
  início) — só que com **fundo branco**. Continua começando a aventura pela
  **primeira fase** da ordem da engrenagem ⚙️.

## v0.10.1 (2026-08-18)
- **▶️ Iniciar jogo!** Botão **branco, centralizado** no mapa-múndi: toque pra
  começar a aventura pela **primeira fase** da ordem que você escolheu na
  engrenagem ⚙️ (ou a padrão, se nunca mudou).

## v0.10.0 (2026-08-18)
- **Gamificação! 🪙** Agora dá pra pontuar o quanto a criança acerta:
  - **Botões V e X** no canto superior direito da tela de palavras, ao lado do
    contador: **V verde** = acertou (ganha pontos e passa pra próxima) ·
    **X vermelho** = errou (perde os pontos da palavra, que **repete** até
    acertar). Por enquanto o adulto aperta — depois o microfone pode fazer isso.
  - **Pontos pela dificuldade:** 2 sílabas = 2, 3 sílabas = 4, 4 sílabas = 6.
  - **🪙 Moedas e Nível (Nv)** no topo: as moedas são o saldo (cai quando erra,
    nunca fica negativo); o nível sobe conforme o XP acumulado (que nunca cai).
  - **Baú no fim de fase:** ao concluir um habitat no mapa-múndi, abre um baú
    com **+10 moedas** e uma **medalha** pela precisão (🥇 ouro = acertou tudo,
    🥈 prata ≥ 80%, 🥉 bronze ≥ 60%) — a medalha fica no anel da fase.

## v0.9.0 (2026-08-18)
- **Escrever! ✏️** Nova categoria na tela inicial (abaixo de Alimentos e Nomes):
  digite **qualquer palavra** que quiser, toque no **+** e monte a sua lista.
  A lista fica **salva** — na próxima vez que abrir, as palavras já estão lá.
  Depois é só tocar em **Confirmar** e elas passam na tela como as demais
  (grande, pra ler e escrever por cima).

## v0.8.0 (2026-08-18)
- **Fazenda! 🐮** Nova turma de bichos domésticos (vaca, cavalo, porco, ovelha, gato, cachorro,
  coelho…). No mapa-múndi eles viram uma **fase na América do Norte**; na tela de habitats entram
  junto das Aves — o botão agora é **"Aves e Fazenda"**.
- **Anéis de fase estilo jogo:** os marcadores viraram **anéis/pódios** brilhantes no chão (o bicho
  fica "em pé" em cima), como num joguinho. Acendem em neon quando você conclui a categoria.
- **Botões do mapa-múndi:**
  - **↩︎ (canto superior esquerdo):** volta pra tela anterior.
  - **Voltar habitat:** desfaz a **última** fase concluída (some a última luz; clicando de novo,
    some a anterior, e assim por diante).
  - **Reiniciar aventura:** apaga **todas** as luzes.
  - **🏠 Voltar início (canto inferior direito):** volta pra tela principal (Animais/Objetos/…).
- **⚙️ Configurações:** botão de engrenagem na tela inicial. Por ora dá pra **escolher a ordem**
  em que as categorias de animais aparecem no mapa-múndi (arrastar pra reordenar).

## v0.7.0 (2026-08-18)
- **Mapa-múndi lindo! 🌍** Agora é uma **ilustração de verdade** — relevo, montanhas, sombras,
  oceano brilhante e **bichos em cada continente** (urso polar no gelo, leão/elefante/girafa na
  África, onça/arara na América do Sul, panda/tigre na Ásia, baleias no mar, aves no céu…).
- **Fases como num jogo:** os discos ficaram **achatados** e, ao concluir todas as palavras de
  uma categoria, o disco **acende** com um brilho neon "fumacinha" e o **caminho** até a próxima
  fase ilumina. Cada fase fica no continente do bicho.
- **Novo bicho:** 🦘 **canguru** na lista de animais (habitat Savana).

## v0.6.0 (2026-08-18)
- **Mapa-múndi novo, desenhado! 🌍** Saiu a imagem antiga (meio borrada) e entrou um mapa-múndi
  **desenhado no próprio app** — nítido em qualquer tela, estilo infográfico, com **oceano fundo**,
  **montanhas com relevo** e sombras dando **profundidade**.
- **Cada bicho no seu continente:** ❄️ Ártico no gelo · 🦅 Aves na Ásia · 🦁 Savana na África ·
  🌴 Selva na América do Sul · 🐠 Aquático no mar. O caminho das fases foi reordenado pra fluir
  bonito pelo mapa.

## v0.5.0 (2026-08-18)
- **Mapas mais largos.** O mapa de habitats e o mapa-múndi agora **encostam nas laterais**
  (esticados de leve) — não ficam mais "quadrados". A água azul preenche o que sobra.
- **Fases em 3D!** No mapa-múndi, cada habitat virou um **disco brilhante** (achatado, com brilho
  em cima e sombrinha embaixo) e contorno **neon**. Ao concluir, o disco **acende** e o **caminho**
  até a próxima fase brilha — e o mapa ganhou uma leve **profundidade** (bordas mais escuras).
- **Botões no mapa-múndi:** **Voltar habitat** (volta pra lista/mapa de habitats) e **Reiniciar
  aventura** (apaga as luzes das fases pra começar de novo — as palavras continuam todas lá).

## v0.4.0 (2026-08-18)
- **Mapa dos habitats na medida certa.** A imagem agora aparece **inteira** (nada cortado),
  na proporção correta, e o resto da tela fica preenchido com **água** — continua ocupando a
  tela toda ("infinita"), sem perder as bordas.
- **Escolher os animais! 🔎** Botão **"SELECIONAR ANIMAIS"** (canto inferior esquerdo do mapa):
  abre uma lista com **busca por lupa**; toque no **+** de cada bicho pra adicionar e no
  **Confirmar** pra brincar só com os escolhidos (do mais fácil ao mais difícil).
- **Mapa-múndi virou fases! 🗺️** Tocando no mapa-múndi, cada habitat é um **círculo de fase**
  com contorno **neon**. Toque num círculo pra jogar aquele habitat; ao terminar, a fase
  **acende** e o **caminho** até a próxima fase **brilha** — e fica salvo pra da próxima vez.

## v0.3.1 (2026-08-18)
- **Desfazer:** abaixo da vassoura (limpar tudo) tem um botão **↩︎ desfazer** — apaga só o
  último rabisco; clicando várias vezes, vai apagando um a um.
- **Mapa em tela cheia:** o mapa de habitats agora ocupa a **tela inteira** (sem bordas), em modo
  imersivo.
- **Correção de tela:** ao voltar das palavras pro mapa, ele **continua deitado** (não vira mais
  pra vertical).
- **Muito mais animais!** Agora são **71** bichos nos 5 habitats (ártico 10 · savana 13 · selva 14 ·
  aquático 16 · aves 18) — de "foca" a "rinoceronte" e "estrela-do-mar".

## v0.3.0 (2026-08-18)
- **Animais viraram um jogo! 🗺️** Ao tocar em "Animais", abre um **mapa de habitats** (deitado,
  clima de jogo). Toque num habitat pra brincar só com aqueles animais:
  ❄️ Ártico · 🦁 Savana · 🌴 Selva · 🐠 Aquático · 🦅 Aves. (O mapa-múndi fica pra depois.)
- Nos animais **não se escolhe mais o nível**: cada habitat começa pelas palavras **mais fáceis**
  (menos sílabas) e vai ficando mais difícil conforme a criança avança — inclusive palavras
  maiores, como "hipopótamo" e "rinoceronte".

## v0.2.2 (2026-08-18)
- **Correção de instalação.** As versões anteriores eram assinadas com uma chave diferente a
  cada build, o que fazia o Android recusar a instalação por cima ("conflito com pacote
  existente"). Agora a assinatura é fixa. ⚠️ **Só desta vez**: desinstale a versão antiga e
  instale esta v0.2.2. Da próxima em diante, as atualizações instalam por cima normalmente.

## v0.2.1 (2026-08-18)
- **Ícone do app!** Agora tem logo próprio (livro aberto com urso, carro e melancia, fundo
  âmbar) — aparece na tela inicial do celular.

## v0.2.0 (2026-08-18)
- **Escrever na tela!** Na tela da palavra dá pra escrever por cima (feito caderno), com o
  dedo ou caneta capacitiva. Cores da caneta (bolinhas verticais à esquerda): azul, vermelho,
  amarelo, roxo. Botão de **limpar** o desenho. O desenho some ao trocar de palavra.
- **Cor de fundo** escolhível (bolinhas ao lado do título): preto, branco, bege escuro, bege
  claro — a palavra fica branca no fundo preto e preta nos demais (mais contraste/conforto).
- **Botões de baixo menores** — mais espaço pra palavra.
- **Muito mais palavras** de animais, objetos e alimentos (agora ~209 no total).

## v0.1.0 (2026-08-18)
- Primeira versão! Tela inicial com 4 temas de palavras (Animais, Objetos, Alimentos, Nomes),
  escolha de nível por sílabas (Fácil 2 · Média 3 · Difícil 4) e a tela de leitura em paisagem
  com a palavra grande e os botões Voltar / Anterior / Recomeçar / Próximo. Tema escuro.
