# APRENDIZADOS.md — técnico / gotchas (Primeiras Palavras)

Notas técnicas e decisões. Topo = mais recente.

## 2026-08-18 — v0.10.3 (V/X no canto + quadrados arredondados)
- Usuário pediu: V/X **bem no canto superior direito** e **quadrados com
  cantos arredondados** (não círculos). Feito: padding do topo mudou de
  `fromLTRB(16,10,16,0)` p/ `fromLTRB(16,10,0,0)` (sem margem direita → o X
  encosta na borda; `SafeArea` ainda protege em telas com notch) e
  `_BotaoAcertoErro` trocou `BoxShape.circle` por `BorderRadius.circular(12)`
  em 40×40 (raio proporcional ao dos botões de baixo). Testes inalterados
  (29 verdes, analyze limpo).

## 2026-08-18 — v0.10.2 (Iniciar jogo: reposicionado p/ inferior-centro, branco)
- Usuário pediu ajuste: o botão NÃO fica mais centralizado no mapa (tampava a
  arte); agora é `Align(bottomCenter)` no mesmo molde `_BotaoTransparente` dos
  demais botões de baixo. `_BotaoTransparente` ganhou `fundo` (padrão preto
  translúcido `0x8C000000`, que substitui `Colors.black.withValues(alpha:0.55)`
  — mesmo visual, const-friendly) e `letra` (padrão branco); o Iniciar passa
  `fundo: Colors.white, letra: AppColors.bg` + ícone play. `_BotaoIniciar`
  (pílula grande) DELETADO. Testes seguem iguais (texto 'INICIAR JOGO' +
  toque abre Fase 1). 29 testes, analyze limpo.

## 2026-08-18 — v0.10.1 (botão "Iniciar jogo" no mapa-múndi)
- **`_BotaoIniciar`** (pílula branca, texto `INICIAR JOGO` em `AppColors.bg`,
  `Material elevation 6`) centralizado via `SafeArea(Center(...))` — fica por
  cima do mapa (último no Stack). `_iniciarJogo()` lê `ConfigOrdem.fases()` e
  abre `_abrirFase(fases.first, 1)` — a **primeira fase da ordem da engrenagem**
  (decisão do usuário), não a fase 1 fixa. Teste novo no mapa_mundi_test
  (renderiza + toque abre "Fase 1 · Ártico"). 29 testes, analyze limpo.

## 2026-08-18 — v0.10.0 (gamificação: XP + moedas + V/X + medalhas)
- **`services/progresso_repository.dart`** (molde do ARQUITETURA, sem Riverpod —
  segui o padrão estático de ProgressoFases/ConfigOrdem): chaves
  `xp_total_v1` (nunca cai), `moedas_v1` (saldo, floor 0), `acertos_<habitat>` /
  `erros_<habitat>`. `nivelDe(xp) = 1 + xp ~/ 25`. `registrarErro` devolve a
  perda REAL (clampada) p/ o feedback; na UI mostro `-$pontos` (a regra), não a
  perda clampada.
- **Pontos da palavra = 2 × (sílabas − 1)**, clamp mínimo 1 (palavras do
  usuário têm `nivelSilabas = 1` → dão 1 pt).
- **EstudoScreen:** V (`_acertou`) soma XP+moedas, limpa o desenho, avança e, se
  for a última palavra de fase (`habitatConcluivel`), abre o **baú** (`_BauDialog`
  com `Curves.elasticOut` + bônus `bonusFase=10` + medalha). X (`_errou`) só
  desconta moedas e **repete a palavra** (pedagógico: erro vira aprendizado).
  Botões V/X = `_BotaoAcertoErro` (círculo 34px, letra dentro).
- **Feedback flutuante `_PontosFeedback`:** `AnimationController` 950ms (sobe +
  fade), `ValueKey(_feedbackSeq)` reinicia a animação em cliques repetidos;
  `onFim` (status listener) limpa no pai. ⚠️ No teste, `pumpAndSettle` espera a
  animação TERMINAR → o "+1" some; verifique com `pump(100ms)` e depois
  `pumpAndSettle` p/ confirmar que sumiu.
- **Topo da EstudoScreen estourava em telas estreitas** (portrait 360 / teste):
  o bloco progresso+moedas+Nv+V/X entrou num **`Wrap`** (`alignment: end`) dentro
  de `Flexible` → quebra linha em vez de overflow; em paisagem (uso real) fica
  numa linha só.
- **Medalhas no mapa-múndi:** `_AnelFase` ganhou `medalha` (ouro/prata/bronze ou
  null → estrela). `_carregarMedalhas()` lê por habitat no `_carregar` e no
  `_recarregarProgresso` (após voltar de uma fase). `AppColors.acerto`
  (verde 2ECC71) criado p/ o V.
- Testes: `progresso_repository_test.dart` (6: soma, erro floor, nível, bônus,
  medalha por precisão 100/67/80/50%, isolamento entre habitats) + widget_test
  "estudo: V dá pontos e X tira". 28 testes, analyze limpo.
- **A definir (usuário):** o que as moedas compram (sugestão = Prêmios reais
  cadastrados pelo pai). Decisões fechadas: moedas+nível, erro perde os pontos da
  palavra, V/X no topo direito ao lado do contador.

## 2026-08-18 — v0.9.0 (categoria "Escrever" — palavras do usuário)
- **`Categoria.escrever`** (5º enum, emoji ✏️, cor rosa `F472B6`): categoria DO
  USUÁRIO — **não tem banco** (`bancoPalavras`). HomeScreen roteia com `switch`
  (animais→mapa, escrever→EscreverScreen, resto→Nivel). Grid da home vira 5
  cards (última linha sozinha). Teste de banco "card não fica vazio" **skipa**
  `Categoria.escrever`; o teste de duplicatas passa (lista vazia) sem tocar.
- **`EscreverScreen`** (`features/escrever/`, RETRATO): mesma estrutura da
  "Selecionar animais" (campo no topo + lista + FAB "Confirmar (n)"). Adição
  = TextField + **`IconButton.filled`** "+" (e `onSubmitted` do teclado);
  remove por linha com `remove_circle_outline` (danger). Valida vazio e
  duplicata via `semAcento` (busca amigável, ex.: "Água" vs "agua").
- **Palavra do usuário = `Palavra([texto], Categoria.escrever)`** → uma única
  "sílaba", `nivelSilabas = 1`. OK: a EstudoScreen só usa `texto`, e o teste do
  banco não cobre palavras em runtime. Ordem = da lista (inserção).
- **Persistência:** `services/escrever_palavras.dart` (shared_preferences,
  chave `escrever_palavras_v1`), mesmo molde de ProgressoFases/ConfigOrdem —
  carrega no `initState`, salva a cada mudança. A lista sobrevive ao app.
- Estudo abre com `manterPaisagemAoSair` padrão (`false`) → ao voltar, retrato
  (a EscreverScreen é retrato e a home também — sem código de orientação).
- Testes: widget_test ganhou "home mostra as 5 categorias", "tocar em Escrever"
  e "adicionar gato → Confirmar (1) → Estudo mostra GATO". ⚠️ Testes que abrem
  a EscreverScreen precisam de `SharedPreferences.setMockInitialValues({})`.
- **Fix overflow do card de nível** (`nivel_screen.dart`): com viewport de
  celular real (360×800) o `Row` do `_NivelCard` estourava 53–67px (rótulo +
  contagem + chevron sem flex). Troquei o `Spacer` por `Expanded` no `Column`
  do rótulo — o overflow NÃO era visível no viewport padrão de teste (800×600).

## 2026-08-18 — v0.8.0 (Fazenda + anéis de fase + botões/undo + ordem configurável)
- **Habitat Fazenda:** `Habitat.fazenda` (`col/row = -1` — NÃO tem célula na grade do mapa_animais).
  14 bichos domésticos no banco (habitat 'fazenda', sub terrestre). No mapa-múndi = fase na
  **Am. do Norte** (`fx,fy = 0.17,0.33`). Na grade de habitats **não** tem botão próprio: a célula
  das Aves virou **"Aves e Fazenda"** (`habitat_map_screen`) e abre `palavrasDosHabitats(['aves',
  'fazenda'])`. Na aventura, `_abrirFase(aves)` também inclui a fazenda.
- **ProgressoFases agora é LISTA ordenada** (não Set): guarda a ordem de conclusão p/ o "Voltar
  habitat" desfazer só a última (`voltarUltima()` = remove o fim). `carregar` devolve `List<String>`;
  telas usam `.contains`.
- **Botões do mapa-múndi:** ↩︎ topo-esq (`pop`, voltar à tela anterior — reintroduzido); **Voltar
  habitat** = `voltarUltima` (undo 1 fase, NÃO navega — o rótulo ficou por pedido do usuário);
  **Reiniciar aventura** = apaga tudo; **Voltar início** (inferior-dir, casinha) =
  `popUntil((r)=>r.isFirst)`.
- **Ordem das fases configurável:** `services/config_ordem.dart` (shared_preferences, chave
  `ordem_fases_v1`) — **sanitiza** (descarta chave inválida + acrescenta no fim habitat novo tipo
  fazenda → nunca perde fase). `features/config/config_screen.dart` = `ReorderableListView.builder`
  (use **`onReorderItem`**, não `onReorder` deprecado; newIndex já ajustado). Engrenagem na AppBar da
  home. Mapa-múndi lê `ConfigOrdem.fases()` (nº da fase = índice+1) em vez de `Habitat.fases`.
- **Anel/pódio de fase (estilo Brawl Stars):** `_AnelFase` (era `_DiscoFase`) = elipse bem achatada
  (`Radius.elliptical(360,120)`, `anelH = d*0.34`) no "chão" com `RadialGradient` translúcido (claro
  no miolo→tinta no rim), `Border` neon e `BoxShadow` de brilho difuso; o **emoji fica em cima** do
  anel (`Positioned bottom`), tipo personagem no pódio. Aceso só quando concluído. Posicionamento
  ancora o **centro do anel** em (fx,fy): `top = fy*boxH - (d - anelH/2)`.
- **`?Habitat.porChave(c)`** (null-aware element) em vez de `if-case` (lint `use_null_aware_elements`).
- Validado no preview-PNG (anéis + fase Fazenda na Am.N + brilho). +testes: voltarUltima, ConfigOrdem
  (sanitização/fase-nova). 19 testes, analyze limpo.

## 2026-08-18 — v0.7.0 (mapa-múndi = ARTE ilustrada + discos achatados c/ glow + canguru)
- **Reversão do vetorial (v0.6.0):** o `CustomPaint` "infográfico simples" NÃO atingiu o estilo que
  o usuário queria (ilustração rica c/ relevo/sombra/bichos, igual `mapa_animais.jpg`). Conclusão
  reforçada: **arte rica = raster gerado por IA**, não código. O usuário gerou a imagem no ChatGPT.
- **Integração da imagem:** usuário subiu `1787076988417.png` (1376×768, ≈16:9) na raiz do repo.
  Convertida p/ `assets/habitats/mapa_mundi.jpg` via PIL (quality 88 → ~350KB), png da raiz removida.
  `MapaMundiScreen` voltou a `Image.asset(... BoxFit.fill, filterQuality.high)`; **deletado**
  `mapa_mundi_arte.dart`; vinheta removida (a arte já tem profundidade). `kMapaMundiAspect` = 1376/768.
- **Círculos nos continentes certos** (`habitat.dart` fx/fy, conferidos no preview PNG): ártico
  0.44,0.15 (gelo/urso) · aves 0.85,0.15 (aves no céu, dir.sup) · savana 0.59,0.60 (África) · selva
  0.34,0.72 (Am.S/onça) · aquático 0.12,0.66 (mar/baleias). **A imagem já veio em paisagem** — não
  precisou girar ("deitar"). ⚠️ Reposicionar fx/fy SE trocar a arte do mapa.
- **Discos "fase de jogo":** `_DiscoFase` mais achatado (`dh = d*0.66`) e glow tipo **fumacinha**:
  quando concluído, 2 `BoxShadow` neon (largo difuso alpha .55 blur 34 spread 7 + concentrado alpha
  .95 blur 16); apagado = contorno neon sutil (alpha .28). Acende só ao concluir toda a categoria.
- **canguru** no banco (`['can','gu','ru']`, média, sub terrestre, habitat savana — melhor encaixe
  entre os 5; migra p/ Austrália/Fazenda se criar o habitat). NÃO gerou release próprio (v0.6.1
  ficou só no git); entrou junto na v0.7.0.
- **Preview validado** com o truque headless-PNG (`precacheImage` do asset dentro de `runAsync` antes
  do `toImage`, senão a imagem não decodifica no teste). Ver [[feedback-flutter-preview-png-headless]].

## 2026-08-18 — v0.6.0 (mapa-múndi VETORIAL desenhado em CustomPaint)
- **Por quê:** o `mapa_mundi.jpg` (1024², baixa qualidade) borrava ao esticar. Claude no CLI **não
  gera imagem** → o usuário aprovou desenhar **vetorial** (nítido em qualquer tela, sem asset).
- **`mapa_mundi_arte.dart` (`MapaMundiArtePainter`):** oceano = `LinearGradient` vertical (profundidade);
  continentes = polígonos em **frações 0..1** suavizados por quadráticas (`_suave`: quadraticBezier
  pelos vértices → costas arredondadas "de desenho"); cada terra leva plataforma rasa (stroke azul-claro
  largo) + `canvas.drawShadow` (relevo, SEM MaskFilter) + fill com gradiente claro→escuro (volume) +
  contorno. Montanhas = 2 triângulos (face clara/escura) + neve. `shouldRepaint=false` (arte estática).
  7 continentes desenhados (Am.N, Am.S, Europa, África, Ásia, Austrália, gelo).
- **Substituição:** na `MapaMundiScreen` o `Image.asset` virou `const CustomPaint(painter:
  MapaMundiArtePainter())`; removi `mapa_mundi.jpg` do pubspec e do git (não é mais usado). Vinheta
  mantida (leve). Discos/caminho/botões da v0.5.0 seguem iguais.
- **Fases nos continentes certos** (`habitat.dart`, campos `fx`/`fy` + `ordem`): ártico 0.38,0.10 (gelo) ·
  aves 0.74,0.22 (Ásia) · savana 0.53,0.46 (África) · selva 0.25,0.68 (Am.S) · aquático 0.42,0.83 (mar).
  **`ordem` reordenada** p/ o caminho fluir: ártico(1)→aves(2)→savana(3)→selva(4)→aquático(5). Se mexer
  nos polígonos do painter, re-conferir esses `fx`/`fy`. (col/row NÃO mudam — são da grade do
  mapa_animais.jpg.)
- **Verificação visual sem emulador:** dá pra renderizar a tela num PNG via teste headless
  (`RepaintBoundary` + `boundary.toImage` dentro de `tester.runAsync`, com `tester.view.physicalSize`)
  e abrir o PNG. ⚠️ No teste, **texto e emoji viram quadradinhos** (sem fonte carregada) — é artefato
  de teste, no app renderiza normal. Teste de fumaça: `test/mapa_mundi_test.dart` (painter não estoura
  + botões presentes).

## 2026-08-18 — v0.5.0 (mapas esticados + discos 3D + botões reiniciar/voltar no mapa-múndi)
- **Esticar os mapas ("não ficar quadrado"):** trocado `AspectRatio(nativo)` por `LayoutBuilder`
  + `SizedBox(width: w, height: (w/kMapaDisplayAspect).clamp(0, h))` centrado, com a imagem em
  `BoxFit.fill`. `kMapaDisplayAspect = 2.0` (em `habitat.dart`) é mais largo que o nativo (animais
  1.5, mundi 1.0) → a imagem **enche a largura** (encosta nas laterais) e sobra água em cima/embaixo;
  em telas bem largas toma a tela toda. A grade 3×2 do habitat e os círculos do mundi dividem a MESMA
  box (frações `fx`/`fy`) → **seguem alinhados** mesmo esticando. Ajustar `kMapaDisplayAspect` se quiser
  mais/menos stretch. `filterQuality: medium/high` nas imagens pra suavizar o reescalonamento.
- **Qualidade do mapa-múndi:** o `mapa_mundi.jpg` atual é 1024² e de baixa qualidade — esticado
  fica pior. Paliativos por código: `filterQuality.high` + **vinheta** (`RadialGradient` transparente→
  preto nas bordas) que dá profundidade e disfarça. Solução real = **imagem nova** (relevo/infográfico,
  de preferência em paisagem ~1536×1024 pra esticar menos). **Não há tool de geração de imagem no
  ambiente CLI** → depende de arte externa dropada em `assets/habitats/mapa_mundi.jpg` (aí re-tunar
  `fx`/`fy` se o layout mudar) OU um mapa vetorial em `CustomPaint` (custoso). Ver IDEIAS.
- **Discos de fase 3D achatados:** `_DiscoFase` (era `_CirculoFase`) = retângulo `dh = d*0.78`
  (achatado) com `borderRadius: Radius.elliptical(200,160)` grande → vira **elipse**. Volume por
  `RadialGradient` (centro claro deslocado p/ cima-esq), **glossy** (LinearGradient branco→transparente
  no topo via `FractionallySizedBox`), `Border` neon e 2 `BoxShadow` (preta com offset = profundidade +
  neon = brilho). NÃO usei `MaskFilter.blur` (pesa/flaky no raster). Posicionamento usa `w`/`boxH` da box.
- **Botões inferiores + reset:** `MapaMundiScreen` ganhou Row inferior com `_BotaoTransparente`
  (mesmo estilo dos nomes) — **VOLTAR HABITAT** (`Navigator.pop`, substitui a setinha do canto, que
  removi) e **REINICIAR AVENTURA** (`showDialog` de confirmação → `ProgressoFases.reiniciar()` que faz
  `prefs.remove(_chave)` → `setState(_concluidas={})`). Responde ao "fica aceso pra sempre?": **sim,
  persiste** (shared_preferences) até reiniciar. Teste novo `test/progresso_fases_test.dart`
  (marca idempotente / carrega / reinicia, com `SharedPreferences.setMockInitialValues`).

## 2026-08-18 — v0.4.0 (fix dimensão do mapa + selecionar animais + mapa-múndi de fases)
- **Fix "imagem cortada" do mapa (o pedido):** o v0.3.1 usava `BoxFit.cover` em `Stack(expand)`,
  que recortava as bordas. Agora `HabitatMapScreen` volta ao `Center(AspectRatio(kMapaAnimaisAspect))`
  com **`BoxFit.fill`** — como a box JÁ tem o aspecto certo (1536/1024), `fill` == sem distorção e
  **sem corte**; o `Scaffold` fica `backgroundColor: kAgua` e a água preenche o resto da tela
  ("infinita" sem perder nada). Imersivo (`immersiveSticky`) mantido. Constantes de aspecto/água
  centralizadas em `models/habitat.dart` (`kMapaAnimaisAspect`, `kMapaMundiAspect`, `kAgua`).
- **Selecionar animais:** `features/selecao/selecao_animais_screen.dart` (RETRATO — é tela de
  digitação; volta à paisagem no `dispose`). `banco_palavras.dart` ganhou `todosOsAnimais()`
  (só `Categoria.animais`, ordenado A→Z por `semAcento`) e `semAcento()` (normaliza acento+caixa
  p/ busca amigável — tabela `de`/`para` de 46 chars, comprimentos casados; como aplica
  `toLowerCase()` antes, só o ramo minúsculo é atingido). Devolve `List<Palavra>` via `Navigator.pop`
  ordenada por sílabas; o `HabitatMapScreen._selecionarAnimais` abre o Estudo com os escolhidos.
- **Mapa-múndi de FASES:** `features/mapa_mundi/mapa_mundi_screen.dart`. Círculos posicionados por
  fração `fx`/`fy` (0..1) de cada `Habitat` sobre `AspectRatio(1)` (mapa 1024²) via `LayoutBuilder`
  (diâmetro `= (w*0.13).clamp(44,88)`). Contorno **neon** = `Border` + `BoxShadow` (NÃO usei
  `MaskFilter.blur` de propósito — pesa/flaky no raster). Caminho entre fases = `CustomPaint`
  (`_CaminhoPainter`) que acende o trecho i→i+1 quando `fases[i]` está concluída.
- **Persistência de progresso:** `services/progresso_fases.dart` (shared_preferences, chave
  `fases_concluidas_v1`, valores = `Habitat.chave`). `EstudoScreen` ganhou `habitatConcluivel`;
  `_talvezConcluir()` chama `ProgressoFases.marcarConcluido` ao chegar na **última** palavra
  (no `initState` p/ habitat de 1 palavra e no `_proxima()`). Só o fluxo do mapa-múndi passa a
  chave — o fluxo normal de habitat/nível NÃO marca fase. Ao voltar, `_recarregar()` reacende.
- **Ordem das fases:** `Habitat.fases` (getter) ordena por `ordem` (1→5): Ártico→Savana→Selva→
  Aquático→Aves. `fx`/`fy` de cada habitat definidos em `habitat.dart`; ajustar lá se o desenho
  do `mapa_mundi.jpg` mudar.

## 2026-08-18 — v0.3.1 (desfazer + mapa tela cheia + fix orientação + +animais)
- **Desfazer rabisco:** `_desfazer()` faz `_tracos.removeLast()` (a vassoura `_limparDesenho()`
  limpa tudo). Botão `undo_rounded` abaixo da vassoura, na coluna das canetas.
- **Fix orientação (mapa voltava em pé):** a causa era o `EstudoScreen.dispose` forçar RETRATO
  sempre — no fluxo do mapa (paisagem) ele revertia. Corrigido com o flag
  `manterPaisagemAoSair` (o habitat passa `true`; o Nível usa o padrão `false`). O
  `_abrirHabitat` ainda reforça paisagem/imersivo ao voltar (cinto e suspensório).
- **Mapa em tela cheia:** `HabitatMapScreen` virou `Stack(StackFit.expand)` com
  `Image.asset(fit: BoxFit.cover)` + `SystemUiMode.immersiveSticky` (restaura `edgeToEdge` no
  dispose). Trade-off: `cover` recorta um pouco das BORDAS da imagem (não distorce). Como no
  celular a tela é mais larga que a imagem (3:2), o recorte é vertical e as **colunas continuam
  alinhadas** aos habitats; a divisa das linhas fica no centro (alinhada). Botão voltar virou
  flutuante (top-left) sobre a imagem; título removido.
- **+Animais:** 71 no total (ártico 10 · savana 13 · selva 14 · aquático 16 · aves 18). Novos
  multi-palavra via `textoOverride`: "água-viva", "estrela-do-mar". Sílabas até 5.

## 2026-08-18 — v0.3.0 (jogo de habitats — Animais reestruturado)
- **Fluxo novo p/ Animais:** Home → `HabitatMapScreen` (paisagem) → `EstudoScreen`. As outras
  categorias seguem no fluxo de Nível. Roteamento em `home_screen.dart` (`if categoria == animais`).
- **`HabitatMapScreen`:** imagem `assets/habitats/mapa_animais.jpg` (grade **3×2**) num
  `AspectRatio(3/2)` + overlay de 6 células (`Column` de 2 `Expanded` × `Row` de 3 `Expanded`) →
  alinhamento perfeito à imagem **independente do tamanho da tela** (imagem e grade preenchem a
  MESMA box). 5 células = habitats (botão + nome); a 6ª (col2,linha1 = mapa-múndi) é reservada
  (SnackBar "em breve"). `Image.asset` com `errorBuilder` (não quebra em teste/asset ausente).
- **Orientação entre telas:** habitat força paisagem; ao voltar do Estudo (que restaura RETRATO no
  dispose), o `_abrirHabitat` faz `await push` e **re-força paisagem** ao retornar. Sem isso a tela
  de habitats voltaria em retrato.
- **`EstudoScreen` generalizada:** agora recebe `titulo` (String) + `palavras`, em vez de
  categoria+nível. Nível e Habitat montam o título. (Quebrou o widget_test antigo que tocava em
  "Animais" esperando os níveis → teste passou a usar "Objetos" p/ nível e um novo p/ habitat.)
- **Modelo `Palavra`:** ganhou `habitat` e `textoOverride` (p/ palavras com **espaço/hífen**:
  "urso polar", "beija-flor" — `silabas` ainda conta sílabas p/ ordenar). `palavrasDoHabitat` filtra
  animais por habitat e **ordena por nº de sílabas** (sort estável). Sílabas agora vão até 5
  (hipopótamo/rinoceronte) → teste do banco afrouxado p/ 2–6.
- **Animais reescritos por habitat** (35 animais em 5 habitats). Os antigos domésticos/insetos
  (gato, vaca, formiga…) SAÍRAM do jogo por não caberem nos 5 habitats da imagem — candidatos a um
  habitat "Fazenda"/"Insetos" futuro (ver IDEIAS). Fonte da imagem em `assets/habitats/*_fonte.png`.

## 2026-08-18 — v0.2.2 (BUG: assinatura instável → "conflito com pacote existente")
- **Sintoma:** usuário não conseguia instalar por cima de uma versão já instalada — Android:
  *"um pacote tem conflito com um pacote já existente"*.
- **Causa:** o CI assinava com a chave de **debug**, mas o `~/.android/debug.keystore` é gerado
  **aleatoriamente em cada runner** → cada release tinha uma **assinatura diferente** → o Android
  recusa update com assinatura diferente. (`flutter build apk --release` sem keystore cai no debug.)
- **Fix:** keystore de debug **estável versionado** em `app/android/app/debug.keystore` (credenciais
  padrão: storepass/keypass `android`, alias `androiddebugkey` — NÃO são segredo) + `signingConfigs.debug`
  no `build.gradle.kts` apontando pra ele (`storeFile = file("debug.keystore")`). Foi preciso **negar**
  o `**/*.keystore` em DOIS `.gitignore` (raiz e o gerado `app/android/.gitignore`, mais específico
  vence) com `!app/debug.keystore`. SHA-256 fixo: `71:2D:DC:54:...:30:E0`.
- **Ação do usuário (1x):** desinstalar a versão antiga (assinatura aleatória) e instalar a v0.2.2.
  Daí em diante, updates instalam por cima. **Nunca trocar/perder este keystore** (senão o problema
  volta e, se um dia for pra Play Store, aí sim usar keystore de upload própria via secrets).

## 2026-08-18 — v0.2.1 (ícone do app)
- Usuário subiu a arte (1254×1254, badge âmbar arredondado com cantos BRANCOS). Pedido: fundo
  todo âmbar, sem os recortes. **PIL** (venv do calistenia, sem numbers): âmbar = `(253,164,16)`
  = `#FDA410`; troquei todo pixel com **B>90** (branco/halo, só ~2% = os cantos) por âmbar →
  `app/assets/icon/logo.png` (quadrado âmbar cheio). Arte original guardada em `logo_fonte.png`.
- **flutter_launcher_icons ^0.14.4**: `image_path` = quadrado âmbar (legado); adaptativo com
  `adaptive_icon_background: "#FDA410"` + `adaptive_icon_foreground` = `logo_foreground.png`
  (arte a 68% sobre transparente, p/ o recorte circular não cortar raios/livro). O gerador ainda
  aplica `inset 16%` no foreground. Rodar: `dart run flutter_launcher_icons` (gera mipmaps +
  `mipmap-anydpi-v26/ic_launcher.xml` + `values/colors.xml`) — os PNGs gerados **são commitados**
  (o CI só faz `flutter build apk`, não regenera ícone).

## 2026-08-18 — v0.2.0 (fundo + caneta + botões baixos + +palavras)
- **Escrever na tela (caderno):** `Listener` (onPointerDown/Move, `HitTestBehavior.opaque`)
  sobre um `Stack[palavra, CustomPaint]`; usa `event.localPosition` (relativo à box do Listener,
  = mesma da CustomPaint) → sem conversão manual de coordenadas. Cada "canetada" = `_Traco`
  (lista de `Offset` + cor). `_DesenhoPainter` desenha `Path` com `strokeCap/Join.round` (ponto
  único vira `drawCircle`). `IgnorePointer` na CustomPaint p/ não roubar toque. Desenho é limpo
  ao trocar de palavra (próximo/anterior/recomeçar) e pelo botão "limpar". **Caneta capacitiva
  passiva = toque normal**, então o mesmo `Listener` já cobre.
- **Cor de fundo por `FundoTela`** (enum em `models/estudo_opcoes.dart`) com `corLetra` embutida:
  só o **preto** usa letra branca; branco/bege usam letra preta (regra do usuário). A UI (título,
  progresso, botões, bordas das bolinhas) deriva de `corLetra.withValues(alpha:)` p/ ler em
  qualquer fundo. Cores de caneta em `CorCaneta`.
- **Layout:** bolinhas de fundo **horizontais** no topo (ao lado do título); bolinhas de caneta
  **verticais** à esquerda (+ "limpar"). Botões inferiores agora **baixos** (ícone+texto na
  horizontal, `vertical: 9`) → mais área p/ a palavra (`fontSize 200` no FittedBox).
- **Banco expandido p/ ~209 palavras** (animais 63 · objetos 59 · alimentos 57 · nomes 30). O
  teste de invariantes (2–4 sílabas, sem duplicata) segura a mão ao adicionar. Evitei palavras
  com hífen (ex.: guarda-chuva) porque `texto = silabas.join()` não preserva o hífen.
- Lint: `if (cond) setState(...)` sem chaves acusa `curly_braces_in_flow_control_structures` →
  troquei por `if (!cond) return;` + `setState`.

## 2026-08-18 — v0.1.0 (nascimento do app)
- **Scaffold:** `flutter create --org com.vinyapps --project-name alfabetizacao --platforms
  android /root/alfabetizacao_app/app`. Pasta do projeto = `app/` (igual aos irmãos).
- **Orientação:** o app trava **retrato** no `main` (`SystemChrome.setPreferredOrientations`).
  A `EstudoScreen` força **paisagem** no `initState` e **restaura retrato no `dispose`** — assim
  o "voltar" do sistema (não só o botão) também devolve o retrato. Evita a tela "presa" deitada.
- **Palavra escala com `FittedBox(fit: scaleDown)`** sobre um `Text` de `fontSize: 180` — as
  palavras longas (difícil) encolhem sozinhas sem estourar a largura.
- **CAIXA ALTA na exibição** via `.toUpperCase()` (o dado fica na forma correta; nomes com
  inicial maiúscula). Decisão pedagógica p/ quem começa a ler; toggle é candidato do IDEIAS.
- **Banco guarda SÍLABAS, não só o texto** — de propósito: o nível sai de `silabas.length` e o
  futuro "sílabas coloridas"/subcategorias já têm os dados. `texto = silabas.join()`.
- **Cores em enum:** `Categoria`/`Nivel` carregam a cor no próprio enum (`const` com `Color`),
  evitando um mapa cor↔categoria à parte.
- **`withValues(alpha:)`** em vez de `withOpacity` (deprecado no Flutter 3.44).
- **Testes (as conferências):** 5 invariantes do banco (`banco_palavras_test.dart`) + 2 de UI
  (`widget_test.dart`: home mostra as 4 categorias; tocar em Animais abre os níveis). O teste de
  banco é a rede de segurança ao editar palavras. `analyze lib/ test/` limpo, 7 testes verdes.
- **Aviso "running flutter as root":** inofensivo nesta VPS; os comandos rodam normalmente.
- **Ainda SEM** Firebase, keystore de upload, áudio, imagem — por design (MVP mínimo).
- **Repo/CI (2026-08-18):** repo **público** `viniciostristao1/alfabetizacao_app` (público por
  causa da cota de Actions no plano grátis). CI `build-apk.yml` compila **APK universal**
  (`flutter build apk --release`, sem `--split-per-abi`) para instalar em qualquer ABI; **sem
  keystore** → assina com as chaves de DEBUG (o template já faz no buildType release), então
  instala. Publica em `ci-latest`; `scripts/release.sh` corta o release nomeado com asset de
  nome fixo `primeiras-palavras.apk`. APK ~42MB (universal + debug). O filtro `paths: app/**`
  faz commits só-de-docs (raiz) NÃO dispararem build.
