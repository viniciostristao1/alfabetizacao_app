# APRENDIZADOS.md — técnico / gotchas (Primeiras Palavras)

Notas técnicas e decisões. Topo = mais recente.

## 2026-08-19 — v0.12.0 (tema Contas + fix toque do anel + botão Início)
- **Fix "Céu abria tigre/panda" (mapa-múndi):** o anel de fase ficava numa caixa `Positioned`
  **d×d** com o anel só na base — a parte de cima (vazia mas `HitTestBehavior.opaque`) sobrepunha a
  fase de fy menor. Como a Ásia é desenhada depois do Céu (fica por cima), tocar no céu abria a Ásia.
  **Fix:** a caixa virou **só o anel** (`height: anelH`, `top: fy*boxH - anelH/2`); `_AnelFase`
  preenche a caixa (sem Stack/emoji). Área de toque = o anel.
- **Botão Início (estudo_screen):** `top 10→6`, `left 8→12`, padding vertical `8→6` — sobe/vai à
  direita e encolhe, pra alinhar ao topo e não encostar na 1ª bolinha de caneta (azul).
- **Tema Contas (matemática):** `Categoria.contas` (especial, sem banco — igual `escrever`; testes do
  banco pulam as duas). Rota na home → `features/contas/contas_menu_screen.dart`.
  - `models/conta.dart` (`Conta` a/b/soma/pontos + `enunciado`/`resultado`; `OperacaoConta`).
  - `services/gerador_contas.dart`: `gerarContas(op, digitos)` (1díg 0-9 / 2díg 10-99; subtração a≥b
    sem negativo; soma 2díg mantém resultado ≤99) + `parseConta("12 + 7")` (aceita +/−, rejeita
    negativo/inválido; pontos=2 se algum número ≥10). `services/contas_escritas.dart` (persistência).
  - `conta_estudo_screen.dart`: enunciado grande + **teclado numérico próprio** (1-9/⌫/0/✓ — melhor
    que teclado do sistema em paisagem); acerto → `ProgressoRepository.registrarAcerto(pontos)` (+1/+2)
    e avança; erro → vermelho + limpa, repete. `escrever_contas_screen.dart` espelha `EscreverScreen`.
  - Testes: `contas_test` (gerador ranges/subtração/mistas + parser) e `conta_estudo_test` (acerto dá
    moeda e avança; erro não pontua). 47 testes, analyze limpo; telas validadas no preview-PNG.

## 2026-08-19 — v0.11.0 (mapa-múndi por REGIÃO/continente, separado do habitat)
- **Decisão:** o mapa-múndi deixou de reusar `Habitat` e passou a agrupar por **geografia**. O
  habitat (tela mapa_animais) continua igual; só o mapa-múndi mudou. São **classificações
  independentes** por animal.
- **`Palavra.regiao`** (novo campo, nullable): 'norte'|'sul'|'africa'|'asia'|'australia'|'artico'|
  'oceano'|'ceu'. Todo animal tem uma (teste garante). Independe do `habitat` (ex.: tigre habitat
  'selva' + regiao 'asia'; alce habitat 'artico' + regiao 'norte' — "alce nos EUA", pedido do
  usuário). Selva foi **dividida** por continente real; savana→africa (canguru→australia);
  aquatico→oceano; aves→ceu; fazenda→norte; ártico→artico (mas lobo/lebre/alce/raposa→norte).
- **`models/regiao.dart`** (enum `Regiao`): chave/rotulo/emoji/ordem/fx/fy (8 fases). fx/fy
  posicionam o anel no continente da arte `mapa_mundi.jpg` (conferido no preview-PNG): norte
  0.17,0.33 · artico 0.44,0.14 · ceu 0.85,0.13 · asia 0.80,0.31 · australia 0.87,0.66 · africa
  0.59,0.60 · oceano 0.46,0.47 (no golfinho do Atlântico) · sul 0.34,0.72.
- **Novos animais só-região** (habitat null, não poluem a tela de habitats): Ásia (camelo,
  orangotango) e Austrália (coala, emu, dingo, ornitorrinco). Leopardo/tigre/panda → região asia.
- **Refatoração de uso:** `ConfigOrdem` agora ordena `Regiao` (chave nova `ordem_regioes_v1`);
  `config_screen` e `mapa_mundi_screen` trocaram `Habitat`→`Regiao`; `_abrirFase` usa
  `palavrasDaRegiao(r.chave)` (sumiu o caso especial aves+fazenda — região 'ceu' já tem todas as
  aves, 'norte' já tem a fazenda). `ProgressoFases`/`ProgressoRepository` inalterados (chaves de
  região; progresso antigo por habitat simplesmente não casa e é ignorado). `habitat.dart` fica
  como fonte de `kAgua`/`kMapaDisplayAspect` + habitats da outra tela.
- Testes: `banco` (todo animal tem região válida; cada região tem palavras ordenadas; exemplos no
  continente certo), `config_ordem` reescrito p/ regiões, `mapa_mundi` 1ª fase = América do Norte.
  37 testes, analyze limpo. Posições validadas no preview-PNG headless [[feedback-flutter-preview-png-headless]].

## 2026-08-19 — v0.10.17 (moedas ao lado da engrenagem — de novo)
- Chip da home virou **pílula com fundo** (`surface2`, raio 16) — o texto "dim"
  solto era fácil de não notar. Teste novo trava a posição:
  `chip.right < engrenagem.left` e `engrenagem.right > 780` (AppBar 800 de
  largura) — se alguém mover, o teste quebra. O relato "ainda não está ao lado"
  quase certamente é build antigo (cache) — orientar link versionado.

## 2026-08-19 — v0.10.16 (feedback 52px + pontuação na barra ao lado da engrenagem)
- `_PontosFeedback` fontSize 42 → **52** (pedido "aumente ainda mais").
- Home: o chip de pontuação voltou da linha "Escolha um tema" para a **AppBar
  (actions), ao lado da engrenagem ⚙️** (era assim na v0.10.6; v0.10.7 pediu ao
  lado do tema; agora voltou p/ o topo). Teste da home segue igual
  ('🪙 0 · Nv 1' presente). 34 testes, analyze limpo.

## 2026-08-19 — v0.10.14 (feedback maior + botões do mapa-múndi redistribuídos)
- `_PontosFeedback` fontSize 26 → **36**.
- Mapa-múndi: saiu o Wrap único central; **INICIAR JOGO = `Align(bottomRight)`
  (FittedBox scaleDown)**, e VOLTAR HABITAT + REINICIAR AVENTURA + VOLTAR
  INÍCIO = `Align(bottomLeft)` num `FittedBox(Row(min))`.
- ⚠️ **Testes × fonte Ahem:** a fonte de teste é "quadrada" (cada glifo =
  fontSize), então botões ficam ~1,6x mais largos e o grupo esquerdo (3 botões)
  encostava no INICIAR — nos testes do mapa usei
  `tester.platformDispatcher.textScaleFactorTestValue = 0.5` p/ simular fonte
  estreita (no celular real é Roboto). O grupo esquerdo legítimamente passa do
  meio da tela → asserções de lado: INICIAR > 600, VOLTAR HABITAT < 300 (não
  "meio da tela"). 34 testes, analyze limpo.

## 2026-08-19 — v0.10.15 (reforço do pedido: usuário instalava build antigo)
- Usuário relatou "não mudou nada" — o código JÁ tinha os dois ajustes
  (v0.10.14); provável **cache de download** (link fixo `latest/download` com o
  MESMO nome de arquivo → navegador/celular reutilizam o APK antigo). Ação:
  informar o link **versionado**
  (`releases/download/v0.10.15/primeiras-palavras-v0.10.15.apk` — nome único,
  sem cache) e a fonte foi p/ **42**.

## 2026-08-19 — v0.10.13 (logo do menino de vez — sem chroma key)
- ⚠️ **Causa raiz do logo "furado":** a "chroma key" que removia o âmbar
  (tolerância 42) comeu a **pele alaranjada do menino** — amostras da arte:
  pele/cadeira em (254,179,6) e (254,184,70), distância do âmbar (253,180,5) =
  3..66 → removida. O foreground ficou com buracos (15,7% opaco) e o ícone
  parecia o antigo.
- **Fix:** foreground adaptativo = quadrado ÂMBAR cheio + menino inteiro a 70%
  (537×716, centrado) **SEM nenhuma remoção de cor** — o âmbar da própria arte
  se mistura com `adaptive_icon_background: #FDB405` (mesmo tom) e o recorte do
  Android corta só o âmbar puro → costura invisível. Legado: âmbar + menino a
  92% (706×942). Cabeça a ~62px do topo do ícone, pés a ~957px — tudo visível.
- **Lição:** com fundo monocromático, usar **contain + fundo igual no
  foreground** em vez de chroma key; só usar chroma key se a arte não tiver
  tons próximos do fundo. 34 testes, analyze limpo.

## 2026-08-19 — v0.10.12 (logo SEM corte: arte em pé inteira no quadrado)
- ⚠️ **Lição:** o recorte central QUADRADO da arte (1086×1448) cortou a
  cabeça/pés da criança. Solução: **contain** em vez de crop —
  `logo.png` = canvas 1024² âmbar + arte inteira com 92% da altura (706×942),
  centrada (os lados viram âmbar, que é o fundo da própria arte → invisível);
  `logo_foreground.png` = arte inteira a **68%** (safe zone do recorte
  adaptativo) sobre transparente, com o âmbar removido (tolerância 42).
  `dart run flutter_launcher_icons` regenerou os 5 mipmaps + foregrounds
  (commitados). 34 testes, analyze limpo.

## 2026-08-19 — v0.10.11 (editar pontuação nas Configurações)
- `ProgressoRepository` ganhou `salvarMoedas(int)` e `salvarXp(int)` (floor 0).
- **ConfigScreen** virou uma `ReorderableListView.builder` única com itemCount
  = fases + 1: o **item 0 = seção "Pontuação"** (não arrastável — guard
  `velho == 0 || novo == 0` no onReorderItem; índices das fases ajustados
  `-1`). Motivo: com a seção fixa em cima + Expanded, a lista de fases ficava
  com ~40px na paisagem (tela baixa) — agora tudo rola junto.
- Steppers: `_BotaoMaisMenos` (38px circulares); toque = ±1, **long press =
  ±10 nas moedas** (nível só ±1; nível é derivado do XP, então editar nível
  escreve `xp = (nivel-1)*25`).
- Testes: +2 (salvarMoedas/salvarXp com floor; config com +moedas→1 e
  +nível→Nv 2 via ícones `add_rounded` `.first`/`.last`). 34 testes, analyze
  limpo.

## 2026-08-19 — v0.10.10 (JOGO DO DAVI + logo novo + Selva + feedback central)
- **Título da home = "JOGO DO DAVI"** (AppBar). MaterialApp.title continua
  "Primeiras Palavras" (nome interno do projeto — inofensivo).
- **Logo novo:** usuário subiu `file_000000004144820e94ddaeb50c60d7d2.png`
  (1086×1448, fundo âmbar ~#FDB405) no GitHub — commit do usuário, PUXADO com
  `git pull` antes de qualquer trabalho. Processo (mesmo da v0.2.1): recorte
  central quadrado → 1024² `assets/icon/logo.png` (legado); `logo_foreground.png`
  = mesmo quadrado com o âmbar virado transparente (tolerância 42 na soma das
  difs RGB — "chroma key") p/ o adaptativo; `adaptive_icon_background:
  #FDB405`; original movido p/ `assets/icon/logo_fonte.png`; `dart run
  flutter_launcher_icons` regenera os mipmaps (commitados).
- **Selva:** deslocamento -26 → **-38px** (ainda "pouca coisa" por pedido).
- **Feedback de pontos:** saiu de `Positioned(top:6, right:18)` (topo direito
  da área da palavra) p/ `Positioned(top:4, left:0, right:0, Center)` — topo
  CENTRALIZADO da área da palavra (não cobre a palavra, que é central).
- **Explicado ao usuário o que é "Nível":** nível = 1 + XP acumulado ÷ 25;
  XP = total de pontos JÁ ganhos (nunca cai); moedas = saldo (caem no erro).
- 32 testes, analyze limpo.

## 2026-08-18 — v0.10.9 (Selva fora da caixinha de moedas + home mais compacta)
- **Selva × moedas:** a célula sup. direita do mapa de habitats (Selva) ficava
  com o rótulo por baixo do chip de moedas. Fix: `Transform.translate(offset:
  Offset(-26, 0))` no `_Nome` da célula quando `habitat == Habitat.selva` (só
  ela) — o toque/InkWell continua na célula inteira.
- **Home ainda "grande" p/ o usuário** (disse que não tinha ficado correto —
  provável que estivesse na v0.10.7, que tinha 2 colunas): grade agora
  `crossAxisCount: 4, childAspectRatio: 2.6` (4 temas numa linha + Escrever
  embaixo), emoji 30 + rótulo 14 nos cards. Cabe em qualquer paisagem (até
  640×320) sem rolar: 2 linhas ≈ 124–190px vs ~210–290px disponíveis.
- 32 testes, analyze limpo.

## 2026-08-18 — v0.10.8 (moedas nos dois mapas + home compacta em paisagem)
- **Moedas no mapa de habitats já existiam (v0.10.7)** — usuário estava na
  v0.10.6. Teste agora garante: `tocar em Animais → find.textContaining('🪙')`.
- **Mapa-múndi ganhou o mesmo chip** (top-right, estilo translúcido) +
  `_carregarPontuacao()` no initState e no `_recarregarProgresso` (após fase).
  Import de progresso_repository voltou (tinha sido removido no v0.10.6).
- **Home compacta:** grade 4 colunas (`childAspectRatio: 1.9`) + emoji 40 e
  rótulo 16 — 2 linhas de cartões cabem em paisagem sem rolar. ⚠️ Os testes da
  home usavam viewport RETRATO (360×800) → células minúsculas estouravam;
  `_pumpApp` agora usa PAISAGEM (2400×1080@3 → 800×360), como o app real.
- **NivelScreen estourava em paisagem** (3 cards ~346px > ~272px): cards
  compactados (padding 18→12, gaps 14→10) + `SingleChildScrollView` (nunca
  estoura; rola só se faltar). 32 testes, analyze limpo.

## 2026-08-18 — v0.10.7 (V/X +folga; moedas ao lado de "Escolha um tema" e no mapa de habitats)
- Usuário insistiu 3x no V/X: `Positioned right: 8` → `right: 12` (layout test
  espera `X.right == 788`). O relato "borda fora da tela" também bate com builds
  antigos (v0.10.4 tinha o cluster sem folga); orientar a instalar a versão nova.
- **Home:** chip de pontuação saiu da AppBar → `Row` do cabeçalho ao lado de
  "Escolha um tema" (com `Flexible` + ellipsis — o teste em viewport 360
  estourava 78px sem ele).
- **HabitatMapScreen:** chip `🪙 n · Nv x` no `Stack` (top-right, mesmo estilo
  dos rótulos translúcidos) + `_carregarPontuacao()` no initState e após voltar
  de Estudo/mapa-múndi/seleção. Import de AppColors removido (não usado).
- App inteiro em paisagem: conferido com `grep portraitUp lib/` — sobrou ZERO
  chamada de retrato (main + 4 telas todas paisagem). 32 testes, analyze limpo.

## 2026-08-18 — v0.10.6 (app todo paisagem + pontuação na home + V/X com respiro + anéis puros)
- **App TODO deitado**: `main.dart` trava PAISAGEM (era retrato com exceções).
  Removidas TODAS as chamadas de orientação que brigavam: EstudoScreen.dispose
  agora seta paisagem (o parâmetro `manterPaisagemAoSair` virou morto — mantido
  p/ compat de chamadas), HabitatMapScreen.dispose seta paisagem,
  SelecaoAnimaisScreen perdeu o initState que forçava RETRATO (era tela de
  digitação). EscreverScreen/Home/Nivel/Config não mexiam em orientação — OK.
- **V/X com respiro de 8px** (`Positioned right: 8`): a borda branca de 2px e a
  sombra eram cortadas no `right: 0`. Layout test agora espera `X.right == 792`.
- **Pontuação SEMPRE visível**: HomeScreen virou StatefulWidget — chip
  `🪙 n · Nv x` na AppBar, `_carregarPontuacao()` no initState e APÓS cada
  `Navigator.push` retornar (incluindo Config). ⚠️ Os testes da home agora
  precisam de prefs mock → movido `SharedPreferences.setMockInitialValues({})`
  p/ dentro do `_pumpApp`.
- **Anéis do mapa-múndi 100% sem emoji** (pedido duplo do usuário): removi até a
  medalha/estrelinha do anel — só o círculo (aceso quando concluído). A lógica
  de medalha continua no `ProgressoRepository` (o baú ainda mostra ao concluir);
  o `_AnelFase` perdeu o parâmetro `medalha` e o mapa perdeu o import de
  progresso_repository. 32 testes, analyze limpo.

## 2026-08-18 — v0.10.5 (V/X flutuantes no canto + botões do mapa numa linha + sem emojis)
- Usuário via o comportamento da v0.10.3 (V/X empilhados = o Wrap quebrava;
  INICIAR JOGO cobria o Reiniciar = os 3 Aligns). Mesmo com o v0.10.4 já
  corrigido, fiz a versão **à prova de falhas**:
  - **V/X = flutuantes**: `body: Stack([Column(...), Positioned(top:10, right:0,
    Row(min, [V, 8, X]))])` — colados na TELA (o Stack é o body, sem SafeArea;
    a linha do topo reserva 104px à direita p/ não ficar texto embaixo).
    Lado a lado sempre (Row min não empilha).
  - **Botões do mapa = uma linha**: `FittedBox(fit: scaleDown) + Row(min)` com
    os 4 botões — nunca empilha (encolhe junto se a tela for estreita), em vez
    do Wrap (que podia quebrar linha).
  - **Emojis removidos do mapa-múndi** (pedido): `_AnelFase` perdeu o emoji "em
    pé" e o parâmetro `emoji`; fica o anel + medalha/estrelinha quando concluída.
    ⚠️ Cuidado: remover o parâmetro quebra o construtor — atualizar a chamada
    (for dos anéis).
- Testes: layout_test agora verifica V/X na MESMA linha (top igual) + X.right
  == 800; botões do mapa com o MESMO top (linha única); e ausência dos 6 emojis
  no mapa. 32 testes, analyze limpo.

## 2026-08-18 — v0.10.4 (fix REAL do V/X no canto + botões do mapa sem sobreposição)
- Usuário disse que o v0.10.3 não resolveu (X fora do canto e "ainda redondo").
  Causas reais (verificadas com teste de layout + sondas):
  1. **SafeArea** adicionava o inset do notch (44px) → o X ficava longe da
     borda. Fix: a linha do topo saiu do SafeArea do body e ganhou
     `MediaQuery.removePadding(removeLeft/Right)` — encosta na TELA.
  2. **`Wrap` é "guloso"** (preenche a linha toda; `mainAxisSize` não existe
     nele) e dentro de `Flexible` ficava preso num pedaço → X no meio da tela.
     Fix: `Expanded(grupo esquerdo) + Row(mainAxisSize.min, cluster)` — o
     cluster, inflexível e por último, encosta na borda.
  3. **Raio 12 ainda parecia redondo** → `BorderRadius.circular(8)` (40×40).
  4. Testes que renderizavam a EstudoScreen em RETRATO estouravam (109px) —
     agora TODOS giram pra paisagem ANTES de abrir a tela (senão o overflow
     acontece no frame em que a tela nasce). `test/layout_test.dart` novo:
     mede os RETÂNGULOS dos botões (não do texto!) com `FakeViewPadding(right:
     44)` simulado: X.right == 800, top == 10, 40×40, V+8==X, decoração
     retangular com raio 8. ⚠️ `tester.getRect(find.text())` mede o TEXTO
     (centrado no botão) — parecia "10px de sobra" que não existia.
- **Botões do mapa:** os 3 Aligns separados (esq/centro/dir) viravam um sobre o
  outro; agora TODOS os 4 botões (Voltar habitat, Reiniciar aventura, Iniciar
  jogo, Voltar início) estão num único `SafeArea(Align(bottomCenter, Wrap))` —
  Wrap centralizado NUNCA sobrepõe (quebra linha se apertar). Teste no
  layout_test: rects dos 4 botões não se sobrepõem.
- 31 testes, analyze limpo.

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
