# APRENDIZADOS.md — técnico / gotchas (Primeiras Palavras)

Notas técnicas e decisões. Topo = mais recente.

## 2026-09-04 — v0.82.0 (Historinhas 📚 — livrinhos infantis com páginas e fonte)
- **Categoria nova `Historinhas` (`Categoria.historinhas`, 📚 #FBBF24):** entra na Home como 7º card (grid 4 colunas). É **categoria especial** sem banco de palavras (igual Escrever/Contas) — os testes `banco_palavras_test` ignoram-na. Roteada em `HomeScreen._abrirCategoria` → `HistorinhasMenuScreen`.
- **Modelo `Livro` (`models/livro.dart`):** `Livro(chave,titulo,emoji,cor,paginas)` + `FonteHistorinha` (maiuscula/normal com `aplicar`). `totalPaginas` getter. Texto guardado em **sentence case** ("Era uma vez…") — `maiuscula` faz `toUpperCase()`, `normal` mostra como está (Aa).
- **Banco `banco_historinhas.dart`:** 8 livros infantis, 4–6 páginas cada, frases curtas infantis: Gato Esperto, Pato na Lagoa, Sapo Feliz, Casa da Vovó, Sol e Lua, Davi e o Tesouro, Coelho e Cenoura, Avião Azul. Cores distintas por livro.
- **Telas `features/historinhas/`:** `HistorinhasMenuScreen` grid 3 colunas com cards (emoji + título + "N páginas", borda na cor do livro). `LivroLeituraScreen` com `PageView` (PageController + animação 280ms), `SegmentedButton<FonteHistorinha>` (MAIÚSCULA/Aa) salvo em `ConfigHistorinhaFonte` (`shared_preferences` chave `fonte_historinha_v1`), botão 🔊 (Fala.instance.falar da página), página estilo "livro" (fundo creme #FFF8E7, borda na cor, sombra, emoji topo, "p. N" rodapé, texto 28px centralizado), navegação Anterior/Próxima + bolinhas indicadoras + Voltar.
- **Versão:** `pubspec 0.82.0+112`, `kVersao 0.82.0`, linha em `ATUALIZACOES.md`.

## 2026-09-01 — v0.81.0 (mic quase instantâneo — aceita no resultado parcial)
- **Sintoma:** usuário falava em <1s mas o acerto só registrava ~3s depois. Causa: o `pauseFor`
  (silêncio pós-fala antes de finalizar) estava em 4s → o `finalResult` (onde eu aceitava)
  demorava.
- **Fix principal (early-accept):** `voz.dart` `ouvir()` ganhou `onParcial` — no `onResult` com
  `finalResult == false` eu encaminho os parciais. A `EstudoScreen._parcialMic` roda `reconheceu`
  em cada parcial e, se bater, **aceita na hora**: `_micAceito = true`, `Voz.instance.parar()` e
  `_acertou()` — sem esperar o silêncio/`finalResult`. Guardas: `_micAceito` bloqueia o
  `_resultadoMic` (final) de reprocessar; resetado no início de cada `_ouvirMic`.
- **Secundário:** `pauseFor` 4→**2s** e `listenFor` 12→**8s** (timeout de segurança 18→**12s**) —
  acelera também o caminho de "errou/não entendi" (que ainda depende do final).
- Errar/again ainda espera o final (correto: só declaramos erro quando o reconhecedor fecha).
  `analyze` limpo, suíte verde (a lógica de match é a mesma, já coberta por `reconhecimento_test`).

## 2026-09-01 — v0.80.0 (barra "estou te ouvindo" + escuta mais paciente)
- **Contexto:** usuário quer testar o mic sem falar alto e perguntou por "ajuste de volume". Não
  existe ganho/sensibilidade exponível — o Android faz AGC. O que ajuda é **feedback visual** e
  **paciência** na escuta.
- **`voz.dart`:** `ouvir()` ganhou `onNivel` opcional, ligado ao `onSoundLevelChange` do `listen`
  (é PARÂMETRO direto do `listen`, não vai em `SpeechListenOptions`). Normalizo o nível (Android
  ≈ dB, ~-2..10) para 0..1 com `((l+2)/12).clamp(0,1)`. `pauseFor` 3→**4s** e `listenFor` 8→**12s**
  (fala devagar não corta); o timeout de segurança subiu p/ **18s** (> listenFor).
- **`EstudoScreen`:** estado `_nivelMic`; `_MedidorNivel` (barra 0..1, cinza < 0.06 senão verde,
  `AnimatedContainer` 120ms) aparece na área de status **enquanto `_ouvindo`**. Reseto `_nivelMic`
  em fim/resultado. Mensagem de ouvindo virou const `_msgOuvindo` (o `_fimMic` compara com ela).
- **Sem novos testes** (é UI/plugin, no-op em teste); `analyze` limpo, suíte verde.

## 2026-09-01 — v0.79.0 (fix: mic dava "Não entendi" mesmo falando certo)
- **Sintoma (no aparelho do usuário):** mic ligado, permissão concedida, falando claro → sempre
  "Não entendi". Ou seja: `onFim` disparava com `_micRespondeu == false` (nenhum resultado).
- **Causa raiz:** no `voz.dart` eu concluía a escuta no status **`notListening` E `done`**. No
  Android o `notListening` dispara **antes** do texto (o mic parou de captar, mas o reconhecedor
  ainda vai transcrever) → eu disparava o "fim" cedo e descartava o resultado. Somado a
  `partialResults:false` (menos confiável no Android) e `localeId:'pt_BR'` fixo (se o id do
  aparelho não for exatamente esse, dá `error_no_match`).
- **Fix (`voz.dart`):** (1) concluir **só** no `done` / `finalResult` / `onError` / **timeout de
  12s** (nunca no `notListening`); (2) `partialResults: true`, guardando a **melhor** transcrição
  até o fim; (3) **detectar o locale pt** via `_stt.locales()` (prefere `pt_br`, senão qualquer
  `pt*`, senão `null` = padrão do aparelho); (4) contrato novo: `onResultado` é chamado **uma vez**
  com a melhor lista (**vazia** = não entendeu) e depois `onFim`.
- **`EstudoScreen`:** removido `_micRespondeu`; `_resultadoMic` trata lista vazia como "não
  entendi" (sem gastar tentativa) e, quando erra com texto, **mostra o que ouviu**
  (`Ouvi "gato"…`) — ajuda a criança e a calibrar a tolerância. `_fimMic` só reseta o botão.
- **Ainda não testável na VPS** (sem mic). É a correção mais provável; se persistir, o `Ouvi "…"`
  na tela dirá se o reconhecedor está ouvindo algo (aí o problema é locale/rede) ou nada (aí é
  permissão/serviço de voz do aparelho).

## 2026-09-01 — v0.78.0 (Configurações: ligar/desligar mic + tolerância)
- **`services/config_mic.dart`:** `ConfigMic` (padrão `ativado()` LIGADO; `tolerancia()` 0..2,
  padrão = `kTolerancia` de `reconhecimento.dart`; `salvar*` com clamp). Chaves
  `mic_ativado_v1` / `mic_tolerancia_v1`. Espelha `ConfigFala`/`ConfigLeitura`.
- **`ConfigScreen`:** nova seção "Modo microfone 🎤" (após "Falar a palavra"): `SwitchListTile`
  liga/desliga + `SegmentedButton<int>` **Exato/Tolerante/Bem tolerante** (0/1/2). Truque:
  `onSelectionChanged: _mic ? (...) : null` → o seletor fica **cinza/desabilitado** quando o
  mic está desligado (padrão do próprio widget).
- **`EstudoScreen`:** carrega `_micAtivado`/`_micTolerancia` no `_carregarGamificacao`; o botão
  `_BotaoMic` agora só aparece com `_micAtivado && _modo != incompleta`; `reconheceu(...)` recebe
  `tolerancia: _micTolerancia` (o "ajuste fino" vale sem recompilar).
- **Testes:** `config_mic_test.dart` (padrão + save/load + clamp) e caso novo em
  `mic_botao_test.dart` (mic off → botão some). `analyze` limpo, suíte verde.

## 2026-09-01 — v0.77.0 (Modo Microfone 🎤 — o Davi lê falando)
- **Objetivo:** a criança **fala** a palavra e o app decide certo/errado sozinho (jogar sem o
  pai marcar V/X). **Decisão do usuário:** NÃO é placar novo — o mic só dispara o MESMO
  efeito do V/X de hoje (acerto = `_acertou()`; 3 erros seguidos = `_errou()` "-N" + o app
  fala a palavra + avança). Toleância **calibrável no aparelho**.
- **Dependência:** `speech_to_text: ^7.0.0` (resolveu **7.4.0**). Na 7.4.0, `localeId`,
  `listenFor`, `pauseFor` estão **deprecados no `listen()`** → tem de ir DENTRO de
  `SpeechListenOptions(...)` (senão `analyze` acusa `deprecated_member_use` e quebra o "No
  issues found!"). Uso `partialResults:false` + `ListenMode.confirmation`.
- **Permissões (`AndroidManifest.xml`):** `RECORD_AUDIO` + `INTERNET` (o reconhecedor
  Google costuma pedir rede) e, no `<queries>` já existente, o intent
  `android.speech.RecognitionService` (Android 11+ precisa pra achar o serviço de voz).
- **`services/reconhecimento.dart` (PURO, testável sem plugin):** `reconheceu(alvo, ditas,
  {tolerancia})` reusa **`semAcento()`** (`banco_palavras.dart`), normaliza tirando
  espaço/hífen (cobre "urso polar"/"beija-flor"), testa a frase inteira **e cada palavra**
  dita (artigo grudado "o gato" → "gato"), e aceita por Levenshtein. Regra p/ evitar
  `gato`↔`pato`: só perdoa a diferença se **a 1ª letra bate** (`kExigeMesmaInicial`) e
  tamanho/dist ≤ `kTolerancia` (=1). Constantes no topo p/ **calibrar no aparelho**.
- **`services/voz.dart`:** singleton espelhando `Fala` (try/catch, silencioso se indisponível).
  `initialize()` uma vez com `onStatus`/`onError`; guardo um `_onFim` que a tela usa p/
  reabilitar o botão. `onResult` só age no `finalResult`, mandando principal + `alternates`.
- **`EstudoScreen`:** extraí `_avancarAposResposta()` do rabo do `_acertou()` (o switch de
  conclusão de fase/`_temProximo`) e reuso no fim das 3 tentativas — **sem duplicar** o
  switch. Estado novo `_tentativas/_ouvindo/_micRespondeu/_statusMic`; `_tentativas` zera em
  acerto e em toda troca de palavra (anterior/próximo/recomeçar/jogar de novo). Botão
  `_BotaoMic` (`Expanded`, verde/vermelho) só quando `_modo != incompleta` (no "completar" é
  por toque); linha de status acima dos botões.
- **Não testável na VPS:** sem microfone/emulador; o plugin é no-op em `flutter test` (igual
  haptics/TTS) — a lógica de acerto está coberta por `reconhecimento_test.dart` (puro) e a
  presença do botão por `mic_botao_test.dart` (com `textScaleFactor 0.5` p/ 5 botões não
  estourarem a linha). **Validar/calibrar no celular** com a voz do Davi.

## 2026-08-26 — v0.60.0 (Alimentos > Temas -2% + voltar maior)
- **Voltar maior:** 6 telas `EdgeInsets 8→12`, `size 22→28` + 2 `IconButton size 28` (Habitat/Mapa-múndi) — área +30%. **Círculos:** `y 0.70→0.72`. `versao 0.60.0+90`.

## 2026-08-26 — v0.59.0 (Alimentos > Temas — círculos +10% extra, y 0.70)
- **`AlimentosTemasScreen`:** `y` `0.60` → `0.70` em `_pos`/`_centro`.

## 2026-08-26 — v0.58.0 (Alimentos > Temas — círculos 10% mais baixos)
- **`AlimentosTemasScreen`:** `y` de `0.50` → `0.60` (+10% `h`) em `_pos` e `_centro` — anéis agora na vitrine.

## 2026-08-26 — v0.57.0 (Alimentos > Temas supermercado — 4 círculos centralizados)
- **`AlimentosTema` agora 4+5:** 4 fases de supermercado **hortifruti 🍎 / padaria 🍞 / laticinios 🥛 / acougue 🥩** (cores verde/azul/laranja/roxo) foram movidas de `NomesTema` para `AlimentosTema` — `AlimentosTema.values` agora tem 9 (4 novos + 5 legados mercado/pomar/horta/roca/arrozal mantidos só para validar as 60 palavras antigas, mas **`AlimentosTemasScreen._fases` filtra só os 4 novos**). `NomesTema` revertido ao original **curtos/medios/longos/compostos** com foto de chegada `file_000000009cb...` (2.7 MB) e `_pos` reto `h*0.58`. **Foto:** `file_000000004db8820eb74210682d50195d.png` (3.0 MB, 1536×1024) copiada para `assets/alimentos/alimentos_temas_foto.png` (`kAlimentosTemasFotoAspect` 1536/1024). **Tela:** `AlimentosTemasScreen` agora **4 círculos centralizados** (`_pos` com `y=h*0.50`, `step=w/5`, `_centro` refatorado para `fases` fixas) e `_CaminhoAlimentosPainter` só entre os 4 novos. **Banco:** as 48 palavras hortifruti/padaria/laticinios/acougue continuam `Categoria.alimentos` mas agora validadas via `AlimentosTema` (não `NomesTema`). `versao.dart`/`pubspec` → `0.57.0+87`.

## 2026-08-26 — v0.56.0 (Nomes > Temas supermercado — 4 categorias, círculos em zigue-zague)
- **`NomesTema` (model):** 4 fases agora são **hortifruti 🍎 / padaria 🍞 / laticinios 🥛 / acougue 🥩** (mesmas cores verde/azul/laranja/roxo) — mantido `compostos` como 5º valor legado só para validar as 12 palavras antigas `tema: 'compostos'` (Ana Clara etc.) mas **`NomesTemasScreen._fases` filtra só os 4 de supermercado** (`const [hortifruti, padaria, laticinios, acougue]`) — assim `NomesTema.values` tem 5 mas a UI mostra 4. **Banco:** 48 novas `Palavra(..., Categoria.alimentos, tema: hortifruti|padaria|laticinios|acougue)` com **palavras curtas na esquerda** ( Hortifruti 2-3 sílabas, 3-7 letras: uva→abacate; Padaria 2-4: bolo→brigadeiro; Laticínios 2-4: leite→provolone; Açougue 2-4 maiores: carne→calabresa) — ordenadas por `porDificuldade` automaticamente mas já inseridas em ordem crescente esq→dir. **`NomesTemasScreen`:** `_pos` e `_CaminhoNomesPainter._pos` agora usam `ys = [0.70,0.56,0.67,0.54]` (zigue-zague esq→dir) com `step = w/5*(idx+1)` e `_proximaChave/_iniciarJogo/paint` iterando só `_fases`. **Foto:** `assets/nomes/nomes_temas_foto.png` regenerada como resize Lanczos de `assets/alimentos/alimentos_temas.png` (1529×489 → 1536×1024, 2.5 MB) — supermercado esticado em `BoxFit.fill` (usuário disse ter colocado nova imagem mas nenhuma nova PNG apareceu desde `file_000000006ee...` — placeholder aceitável até enviar). `kNomesTemasFotoAspect` mantido 1536/1024. `versao.dart` e `pubspec.yaml` → `0.56.0+86`.

## 2026-08-25 — v0.55.0 (Alimentos com nova imagem 1536×1024 recortada)
- **Imagem `file_000000006ee8820ebe063e4bfb147152.png` (3.3 MB, 1536×1024, horta/fazenda/ordenha/supermercado):** detectadas quebras com PIL (média por coluna/linha + contagem de brancos >240): verticais em `x≈499-506` e `1029-1035` (topo, 7px brancos) e horizontal em `y≈529-535` (7px). Recortada em `assets/alimentos/`: `alimentos_facil` (495×525), `medio` (523×525), `dificil` (498×525) e `temas` (1529×489, supermercado largo). Declarados no `pubspec.yaml` já existentes (só sobrescritos). `AlimentosMenuScreen` já era `Column[Expanded flex5 Row 3 _CenaBotao + Expanded flex4 _CenaBotao largo]` com labels **Fácil/Médio/Difícil/Temas** — sem mudança de código além das imagens (labels já estavam corretas esq→dir). Testado `flutter analyze` limpo e `flutter test` 60 OK.

## 2026-08-25 — v0.54.0 (Config: Ordem das fases colapsável)
- **`ConfigScreen`:** adicionado `bool _ordemExpandida = false`; cabeçalho `Ordem das fases no mapa-múndi` virado `InkWell` com `Row[Expanded Text + Icon(expand_more/less)]` que faz `setState(() => _ordemExpandida = !_ordemExpandida)`; `ReorderableListView` com `itemCount: _ordemExpandida ? fases.length+1 : 1` (quando fechado só o cabeçalho `pontuacao` aparece, sem ocupar espaço). Mantém `onReorderItem` guard (`velho==0||novo==0`).

## 2026-08-25 — v0.53.0 (Nomes: Selecionar nomes + Coleção 4+1)
- **`NomesMenuScreen`:** adicionado `SafeArea Align bottomLeft` com `_BotaoTransparente` **SELECIONAR NOMES** e método `_selecionarNomes` (`push(SelecaoNomesScreen)` → `push(EstudoScreen '🔤 Meus nomes')`); novo `todosOsNomes()` em `banco_palavras.dart` e `SelecaoNomesScreen` espelhando `SelecaoAlimentos/Objetos`. **`ColecaoNomesScreen`:** grid 3×2 com 4 `NomesTema` (`curtos ⭐, medios 🏅, longos 🏆, compostos 👑`) + bônus 📜 Diploma (todos concluídos) — espelho de `ColecaoAlimentosScreen` com navegação cruzada para as outras coleções. **`NomesTemasScreen`:** adicionado `import` da coleção, método `_abrirColecao` e 5º botão **COLEÇÃO 🔤** na barra inferior (FittedBox Row). **Modelo** `NomesTema` teve prêmios trocados para Estrela/Medalha/Troféu/Coroa para a coleção fazer sentido.

## 2026-08-25 — v0.52.0 (Nomes > Temas 4 fases — chegada, abaixo do centro)
- **`NomesTemasScreen` (`features/nomes/nomes_temas_screen.dart`):** espelha `AlimentosTemasScreen`/`TemasScreen` (Scaffold preto, `LayoutBuilder` com `kNomesTemasFotoAspect=1536/1024`, `dW/dH/dx/dy` para `BoxFit.fill`, `Positioned` da foto `assets/nomes/nomes_temas_foto.png` = `file_000000009cb8820ea5a8dded3acde31c.png` (maratona CHEGADA, 2.8 MB) copiada sobre a anterior). 4 círculos (`_pos` em `w/(5)*(idx+1), h*0.58` — um pouco abaixo do centro, esq→dir Curtos/Médios/Longos/Compostos) com `_AnelNomes` (72×24 elipse, pulsante no próximo) e `_CaminhoNomesPainter` (linha neon 14/5 se concluído senão branca 3). **Modelo** `NomesTema` (4 valores com `Wall` `curtos/medios/longos/compostos`) e **serviço** `ProgressoNomesTemasFases` (`fases_nomes_temas_concluidas_v1`). **Banco:** 12 compostos novos (`tema: 'compostos'`, `texto` com espaço, ex. Ana Clara) em `Categoria.nomes`; teste `banco_palavras_test` atualizado para incluir `NomesTema` nas chaves válidas. **NomesMenuScreen** `_abrirTemas` agora abre `NomesTemasScreen` (antes abria todos os Nomes direto). **EstudoScreen** ganhou `nomesTemaConcluivel`, `_concluirFaseNomesTemas` + `_BauNomesTemasDialog`/`_CardNovaFaseNomes` e `_talvezConcluir` para `ProgressoNomesTemasFases`.

## 2026-08-25 — v0.51.0 (Nomes em 4 cenas — recorte da imagem enviada)
- **`NomesMenuScreen` (`features/nomes/nomes_menu_screen.dart`):** espelha `ObjetosMenuScreen`/`AlimentosMenuScreen` (Scaffold preto, Stack `Column[Expanded flex5 Row 3 _CenaBotao + Expanded flex4 _CenaBotao]`) mas com `assets/nomes/nomes_facil/medio/dificil/temas.png` (labels **Fácil/Médio/Difícil/Temas**). `NomesMenuScreen` mostra `🪙/Nv`, `_carregar()` e `_abrirNivel/_abrirTemas` (`_abrirTemas` = todos os Nomes ordenados por `porDificuldade`). Imagem origem `file_0000000035d8820e9879ae2fd63481e4.png` (1536×1024, Bin da raiz) recortada com PIL nas quebras 505/516, 1021/1031 e 515/525 → 4 crops em `assets/nomes/` declarados no `pubspec.yaml`. Home: `_abrirCategoria` trocado `Categoria.nomes => NomesMenuScreen` (antes `NivelScreen`), import ajustado e `NivelScreen` removido do switch (evita `unreachable_switch_case`). `+ todosOsNomes()` não necessário (Temas usa `bancoPalavras.where(Categoria.nomes)` direto).

## 2026-08-25 — v0.50.0 (Selecionar alimentos/objetos — botão inferior esquerdo)
- **Novas telas `selecao_alimentos_screen.dart` / `selecao_objetos_screen.dart`:** espelham `selecao_animais_screen.dart` (busca com `semAcento`, `+`/`check`, `Confirmar` → `Navigator.pop(List<Palavra>)` ordenada por `nivelSilabas`) mas com `todosOsAlimentos()` / `todosOsObjetos()` (novas funções em `banco_palavras.dart` que filtram por `Categoria` e ordenam alfabeticamente sem acento). **Menus:** `alimentos_menu_screen.dart` e `objetos_menu_screen.dart` ganharam `SafeArea Align bottomLeft` com `_BotaoTransparente` (mesmo estilo preto 0.55 + borda branca, `Icons.search`) e método `_selecionarAlimentos/_selecionarObjetos` que faz `push(Selecao…)` → se `escolhidos != null` faz `push(EstudoScreen(titulo: '🍎/🧸 Meus …', palavras: escolhidos))`.

## 2026-08-25 — v0.49.1 (Baú: MAPA/FAZENDA/CIDADE voltam ao mapa)
- **`_concluirFase*`:** `showDialog<bool>` com `BauDialog` retornava `false` (MAPA/FAZENDA/CIDADE) e o handler fazia `if (jogar != true || proxima == null) return;` — só tratava `true` (próxima fase), ignorando o `false` pedido do usuário. Corrigido para `if (!mounted) return; if (jogar == true && proxima != null) pushReplacement(next); else if (jogar == false) pop();` nos 3 métodos (`_concluirFase` com `Regiao`, `_concluirFaseAlimentos` com `AlimentosTema`, `_concluirFaseObjetosTemas` com `Tema`). Cobre também o caso `ehUltima` ("Voltar ao mapa/fazenda/cidade"). `null` (dismiss na borda) continua sem navegar.

## 2026-08-25 — v0.49.0 (Baú verificado em 5 PNGs headless: pivô traseiro 90° com overshoot)
- **Verificação visual headless:** `BauPainter` tornado público para `test/bau_preview_test.dart` que renderiza 5 frames (`p=0/0.25/0.50/0.75/1.0`) via `RepaintBoundary.toImage(pixelRatio:3)` + `tester.runAsync` → `/tmp/bau_frames/*.png` (necessário `runAsync` pois `toImage` é async real; sem ele o teste trava "did not complete") + `Read` das imagens para inspeção; após verificação o teste foi removido (mantido só `flutter test` funcional). Confirmado: 3/4 com frente+lateral+topo, tampa curva com volume/espessura, interior escuro, moedas metálicas com monte e highlights, dobradiça traseira correta, 90° com `θ=-eff·π/2` e overshoot sutil, corpo parado, moedas estáveis, perspectiva/sombras/iluminação coerentes durante toda a animação — sensação de objeto 3D de videogame, não 2D.

## 2026-08-25 — v0.48.0 (Baú videogame 3/4: 90° dobradiça traseira, 750 ms ease-out + overshoot sutil)
- **Análise prévia:** `_BauPainter` é `CustomPainter` puro 2D (`Canvas`) sem sprite/imagem nem engine 3D; assets de baú inexistentes — todo o baú é código. **Decisão:** manter `CustomPainter` (leve, sem dependências, performático em mobile) mas elevar a 3D convincente com projeção cavalier `sideW=w*0.14, sideUp=h*0.058`, rotação Y-Z real em torno da dobradiça traseira (`hinge=frontCenter+sideW, topo-sideUp`, `W=frontR-frontL, D=sideW, Ht=7.5, barrelR=D*0.46`, `proj(X,Y,Z): yr=Y*cosA-Z*sinA, zr=Y*sinA+Z*cosA, screen=hinge+X+zr*(-sideW/D), hingeY-yr+zr*(sideUp/D)`, 8 cantos + arco do barril `Ht+barrelR*sin t, D/2+barrelR*cos t` em 10 segmentos). **Aparência 3/4:** corpo `frente RRect + lado Path` com volume/espessura, tampa curva arqueada (slab + barril cilíndrico com volume), interior escuro `bauInterior` vs exterior `bauMadeira`, moedas elípticas metálicas `rx=7, ry=0.58rx` com espessura lateral, gradiente 4 stops + highlights, pilha 4 fileiras sobrepostas, joias facetadas, frisos/ferragens/fechadura com rebites. **Abertura:** `AnimationController 750 ms` (antes 1100) + `Curves.easeOutCubic` com overshoot sutil `eff=p+0.07*sin(p*pi)*(1-p)` → `angle=-eff*π/2` (~90°), pivô traseiro correto (não centro), corpo parado, moedas estáveis no `clip` interior. **3D e iluminação:** luz topo/lateral, sombras dinâmicas (`_sombra` com `shift/scale` e `alpha` por `eased`, sombra da tampa no interior), `topHighlight`, `woodGrain`, `_glow` radial que cresce com `eased`, interior mais evidente ao abrir, oclusão e perspectiva coerentes durante toda a animação. Verificado `analyze` limpo e `mapa_mundi_test` com `1250 ms` (antes 800) para completar `750 ms`.

## 2026-08-25 — v0.47.0 (Baú 3D: tampa com rotação Y-Z real na dobradiça traseira)
- **`_tampaCubo` reescrita com rotação 3D:** `W=frontR-frontL, D=sideW, boxHt=7.5, barrelR=D*0.46`, `hinge=(frontL+W/2+sideW, topo-sideUp)`, `angle=-p*1.92`, `proj(X,Y,Z): yr=Y*cosA-Z*sinA, zr=Y*sinA+Z*cosA, screen=hinge+X+zr*(-sideW/D), hingeY-yr+zr*(sideUp/D)`. 8 cantos do paralelepípedo `(±W/2,0/HT,0/D)` + arco do barril `Y=Ht+barrelR*sin t, Z=D/2+barrelR*cos t` (10 segmentos) projetados; polígonos `bottom/front/sideLeft/sideRight/top` + `barrelFill` com gradiente madeira + `stroke` nítido; frisos em `Path` L, faixas com `proj` e rebites 3D, brasão no `ridge`. Corrige dobradiça traseira fixa e arco real da tampa — impressão 3D convincente com volume e profundidade. Limpeza de warnings `unused` e `non_constant`.

## 2026-08-25 — v0.46.0 (Baú cubo 90°: frente + lateral, tampa dupla articulada)
- **`_BauPainter` → cubo 90°:** `_corpo` virou `_corpoCubo` com `sideW=w*0.14, sideUp=h*0.058`: frente `RRect 0.08→0.72` + lado `Path 0.72→0.86` com gradiente escuro e veios próprios; friso/rodapé em L, 2 faixas frontais + 1 lateral. `_interiorETesouro` com `clip` hexagonal (`frontL/frontR/sideR/sideUp`) e parede lateral `Path` `0x1A0E06`, friso dourado em L. `_tampaCubo`: `lidFrontW=0.64w, lidSideW=0.14w`, centrada em `(frontL+frontR+sideW)/2`, `visH=lidH*cosA + thickness*sinA` + `sideUp*cosA` na aresta superior lateral; frente `RRect` + lado `Path` trapezoidal com gradiente; vinco/friso/faixas duplos (front e side), `_cadeado` deslocado para `w*0.40` (centro da frente cubo). Mantida animação `1100ms easeInOutCubic`.

## 2026-08-25 — v0.45.0 (Baú realista: moedas elípticas 3D + dobradiça simétrica + luz)
- **`estudo_screen.dart` `_BauPainter` reescrito:** moedas deixaram de ser círculos frontais (pareciam olhos) → viraram **elipses** `rx=7, ry=0.58*rx` com **espessura lateral** (oval escuro + claro), gradiente radial 4 stops (branco→ouro→ouro escuro) e duplo brilho elíptico — ângulo de cima, empilhadas com `scaleByRow` e jitter fixo (`Random(7)`). 4 fileiras (`-4-10.5*i`, 5/4/3/3 moedas) aparecem com `eased* lidH` progressivo. Tampa refeita com **dobradiça simétrica** centrada em `w/2, topo`: `angle=p*1.92` (110°), `visH = lidH*cosA + thickness*sinA*0.55` comprimida uniformemente (sem `rotate(-p*0.3)` que puxava só um lado), `Radius.circular(16*(0.45+0.55*cosA))`, mais `inner` quando `sinA>0.12` e brilho no friso. Corpo com `stroke` preto 1.4, highlight, veios duplos (claro+escuro) e faixas com luz especular; `_rebite` com gradiente + brilho; `_sombra` dupla oval blur 8/4; `_glow` com `easeOutCubic` e dois layers. Duração `_abertura 700→1100ms`, `_card 650→850ms` + `Curves.easeInOutCubic` no `p` (antes linear) para fluxo lento. Teste `mapa_mundi_test` ajustado `800→1250ms` para completar a abertura.

## 2026-08-24 — v0.44.0 (Mapa-múndi 1679×937 alta qualidade)
- **`mapa_mundi.jpg` trocado:** `file_000000007a64820e9057a288b79cdc6c.png` (1679×937,
  2,8 MB PNG) convertido para JPG 92% (616 KB) em `assets/habitats/mapa_mundi.jpg`.
  Mesma arte, mais nítida. `kMapaMundiAspect` atualizado para `1679/937` (era 1376/768);
  exibição continua em `SizedBox` com `kMapaDisplayAspect=2.0` + `BoxFit.fill` — ocupa a tela toda,
  círculos `Regiao.fx/fy` mantidos idênticos.

## 2026-08-24 — v0.43.0 (Novo mapa Animais + coleção sem MAPA)
- **Novo `mapa_animais.jpg`:** `file_00000000e354820eb45010595305fc39.png` (1536×1024,
  3,5 MB PNG) convertido para JPG 92% (818 KB) em `assets/habitats/mapa_animais.jpg`
  (mesmo `kMapaDisplayAspect`, grade 3×2 `HabitatMapScreen` sem cortes, `BoxFit.fill`).
  Cenários: Ártico (gelo/urso), Savana (elefante/girafa/leão), Selva (onça/tucano),
  Aquático (baleia/golfinho), Fazenda (vaca/cavalo) e Mapa-múndi.
- **`colecao_screen.dart`:** removido `MAPA` (`_abrirMapaMundi` e import `mapa_mundi_screen`),
  ficam só `ALIMENTOS 🍎` e `OBJETOS 🧸` — navegação cruzada 2 vias nas 3 coleções.

## 2026-08-24 — v0.42.0 (Coleções 3 vias)
- **3 coleções cruzadas:** `colecao_screen.dart` (animais) agora importa alimentos/objetos
  e tem 2 `TextButton.icon` extras (ALIMENTOS 🍎, OBJETOS 🧸) ao lado de MAPA;
  `colecao_alimentos_screen.dart` tem OBJETOS + ANIMAIS 🐾; `colecao_objetos_screen.dart`
  tem ALIMENTOS + ANIMAIS. Ciclo de imports `alimentos ↔ objetos ↔ animais` ok (`analyze` limpo).

## 2026-08-24 — v0.41.0 (Coleções cruzadas Alimentos ↔ Objetos)
- **`colecao_alimentos_screen.dart`:** `FAZENDA` (agriculture_rounded + `AlimentosTemasScreen`)
  → `OBJETOS` (🧸 + `ColecaoObjetosScreen`), método `_abrirObjetos`.
- **`colecao_objetos_screen.dart`:** `TEMAS` (store_rounded + `TemasScreen`)
  → `ALIMENTOS` (🍎 + `ColecaoAlimentosScreen`), método `_abrirAlimentos`.
  Import cruzado (`colecao_alimentos ↔ colecao_objetos`) — Dart permite ciclo, `analyze` ok.

## 2026-08-24 — v0.40.0 (Moedas nos Temas + coleções na Home)
- **`temas_screen.dart` e `alimentos_temas_screen.dart`:** `StatefulWidget` com
  `_moedas/_xp` + `SafeArea Align topRight` container 🪙·Nv (igual `HabitatMapScreen`),
  recarrega após cada tema/coleção. `TemasScreen` já era stateful (progresso objetos).
- **`home_screen.dart`:** importadas `colecao_alimentos_screen` e `colecao_objetos_screen`;
  2 `IconButton` novos com emoji `Text('🍎')`/`Text('🧸')` antes da engrenagem, tooltips
  "Coleção de alimentos/objetos", `pop` + `_carregarPontuacao` após voltar.

## 2026-08-24 — v0.39.0 (Nível por fase + moedas no topo)
- **`progresso_repository.dart`:** `registrarAcerto` e `registrarBonus` (sequência)
  agora só somam **moedas**, não XP. `registrarBonusFase` dá `xpPorNivel` (25 XP = 1 nível)
  + `bonusFase` (10 moedas). Nível = 1 + xp/25 só sobe no baú. Teste `progresso_repository_test`
  atualizado (acerto 0 XP, bônus fase 25 XP).
- **`objetos_menu_screen.dart` e `alimentos_menu_screen.dart`:** viraram `StatefulWidget`
  com `_moedas/_xp` e `Container` 🪙·Nv no `Align topRight` (igual `HabitatMapScreen`),
  recarregam após voltar de qualquer `EstudoScreen`/`TemasScreen`.

## 2026-08-24 — v0.38.0 (Alimentos Temas com palavras familiares)
- **`banco_palavras.dart` Temas Alimentos:** 5×12 trocados de exóticos para rotina.
  Mercado: bolo/queijo/leite/carne/ovo/suco/café/biscoito/bolacha/salsicha/presunto/manteiga.
  Pomar: maçã/pera/uva/banana/laranja/manga/limão/mamão/melão/abacate/abacaxi/morango.
  Horta: couve/alface/tomate/cenoura/batata/cebola/pepino/repolho/beterraba/pimentão/brócolis/abóbora.
  Roça: arroz/feijão/milho/trigo/soja/cana/aveia/mandioca/amendoim/pipoca/farinha/açúcar.
  Arrozal: peixe/siri/ostra/lula/polvo/atum/camarão/sardinha/tilápia/dourado/pescada/caranguejo.
  Todas 2–4 sílabas, ordenadas por `porDificuldade` então as curtas (maçã, pera, uva) vêm primeiro.

## 2026-08-24 — v0.37.0 (Coleção Objetos + baú + caminhos)
- **`models/tema.dart`:** `Tema` ganhou `premioEmoji/premioNome` (brinquedo/videogame/mochila/bola/bicicleta).
- **`services/progresso_objetos_temas_fases.dart`:** novo (chave `fases_objetos_temas_concluidas_v1`).
- **`features/colecao/colecao_objetos_screen.dart`:** grade 3 colunas (5+1 bônus presente), espelho da alimentos.
- **`features/estudo/estudo_screen.dart`:** `objetosTemaConcluivel` + `_concluirFaseObjetosTemas()` +
  `_BauObjetosDialog`/`_CardNovaFaseObjetos` (mensagem "Novo brinquedo desbloqueado").
- **`features/objetos/temas_screen.dart`:** virou `StatefulWidget` com `_concluidas/_proximaChave`,
  `_CaminhoObjetosPainter` (linha neon entre 5 colunas) e 5 botões inferiores
  (VOLTAR OBJETOS→pop, REINICIAR limpa progresso objetos, COLEÇÃO 🧸 abre objetos, INICIAR branco).

## 2026-08-24 — v0.36.0 (Caminhos Alimentos + ajuste anéis + botões Objetos)
- **CAJU/SOJA mais baixo de novo:** `pomar/roca top 0.22` (centro y≈0.42) — longe da serra.
- **`alimentos_temas_screen.dart` caminho:** novo `_CaminhoAlimentosPainter`
  (usa `_rectStatic` + `dW/dH/dx/dy` para centro de cada tema, desenha linha
  neon 14/5 se anterior concluída senão branca 3, igual `MapaMundiScreen`).
- **`objetos/temas_screen.dart` botões inferiores:** `TemasScreen` com 5
  `_BotaoObjetos` (VOLTAR ALIMENTOS, REINICIAR, VOLTAR INÍCIO, COLEÇÃO 🍎,
  INICIAR JOGO branco) no `SafeArea Align bottomCenter FittedBox Row` — mesma
  UX dos Alimentos. Importa `AppColors` e `ColecaoAlimentosScreen`.

## 2026-08-24 — v0.35.0 (Coleção Alimentos + baú por fase)
- **`models/alimentos_tema.dart`:** `AlimentosTema` ganhou `premioEmoji/premioNome`
  (pizza/sushi/hamburguer/macarrão/iogurte) para a coleção.
- **`services/progresso_alimentos_fases.dart`:** novo `ProgressoAlimentosFases`
  (chave `fases_alimentos_concluidas_v1`, métodos `carregar/marcarConcluido/voltarUltima/reiniciar`)
  espelhando `ProgressoFases`.
- **`features/colecao/colecao_alimentos_screen.dart`:** grade 3 colunas com 5
  temas + 1 bônus chocolate (6 cards). Cada card: premioEmoji + nome + tema,
  borda dourada no bônus quando todos ganhos. Botão `FAZENDA` volta à foto.
- **`features/estudo/estudo_screen.dart`:** novo `alimentosTemaConcluivel` +
  `_concluirFaseAlimentos()` + `_BauAlimentosDialog`/`_CardNovaFaseAlimentos`
  (baú com `Novo sabor desbloqueado` e chocolate no fim). `_talvezConcluir`
  agora marca também alimentos. Fluxo idêntico ao mapa-múndi com `pushReplacement`.
- **`features/alimentos/alimentos_temas_screen.dart`:** virou `StatefulWidget`
  com `_concluidas/_proximaChave/_rotuloIniciar`, `_AnelAlimentos` com
  `isConcluida/isProximo` (apagado vs aceso vs pulsando). Botões inferiores:
  VOLTAR ALIMENTOS, REINICIAR (limpa `ProgressoAlimentosFases`), VOLTAR INÍCIO,
  COLEÇÃO 🍎 (abre `ColecaoAlimentosScreen`) e INICIAR/CONTINUAR branco.

## 2026-08-24 — v0.34.0 (Alimentos Temas: anéis + botões inferiores)
- **Pomar/Roça mais baixo de novo:** `pomar 0,0.15→0,0.22` e `roca 0.62,0.15→0.62,0.22`
  (centro de y≈0.35→0.42, bem na copa/vinhedo, longe da serra).
- **5 botões inferiores em `alimentos_temas_screen.dart`:** `VOLTAR ALIMENTOS`
  (`pop`), `REINICIAR AVENTURA` (dialog + SnackBar), `VOLTAR INÍCIO`
  (`popUntil isFirst`), `COLEÇÃO 🍎` (emoji, abre `ColecaoScreen`) e `INICIAR JOGO`
  branco (`_abrirTema(primeiro)`). Layout `SafeArea Align bottomCenter FittedBox Row`
  idêntico ao `MapaMundiScreen._BotaoTransparente` — novo `_BotaoAlimentos` local
  com `icon?/emoji?`.

## 2026-08-24 — v0.33.0 (Anéis em Objetos + ajuste Pomar/Roça)
- **`temas_screen.dart` (Objetos):** `_FaixaTema` agora com `Stack[expand, Center(_AnelTema)]`
  — `_AnelTema` idêntico ao `_AnelAlimentos` (78×26 elíptico pulsante na cor do `Tema`).
- **Ajuste Pomar/Roça em `alimentos_temas_screen.dart`:** `pomar 0,0 0.30×0.48 → 0,0.15 0.30×0.40`
  e `roca 0.62,0 0.38×0.48 → 0.62,0.15 0.38×0.40` — centro sai de y≈0.24 (montanhas)
  para y≈0.35 (pomar/vinhedo), pedido "CAJU e SOJA nas montanhas fora de contexto".

## 2026-08-24 — v0.32.0 (Anéis pulsando nos Temas Alimentos)
- **`alimentos_temas_screen.dart`:** `_FaixaAlimentosTema` agora tem `Stack` com
  `Center(_AnelAlimentos)` — anel elíptico 78×26 pulsante (`AnimationController 900ms
  repeat/reverse`) nas cores do `AlimentosTema`, igual ao `_AnelFase` do mapa-múndi
  (gradiente radial, borda `lerp(branco, cor, pulso)` + 2 `BoxShadow`). O `InkWell`
  continua invisível cobrindo o `Rect` inteiro; o anel só indica visualmente a fase.

## 2026-08-24 — v0.31.0 (Temas Alimentos: 5 faixas na foto da fazenda)
- **Renomeado "Todos" → "Temas" em `alimentos_menu_screen.dart`:** `_abrirTodos`
  virou `_abrirTemas` → `AlimentosTemasScreen`. A nova foto `1787617182584.png`
  (1376×768, mercado+rio+plantação) copiada para `assets/alimentos/alimentos_temas_foto.png`.
- **Novo `models/alimentos_tema.dart`:** enum `AlimentosTema` (mercado/pomar/horta/roca/arrozal,
  5 valores) + `kAlimentosTemasFotoAspect`. Nova `features/alimentos/alimentos_temas_screen.dart`
  espelha `TemasScreen` mas com `Rect` por tema (mercado centro 0.30/0.30 0.38×0.42, pomar
  topo-esq, horta baixo-dir, roça topo-dir, arrozal baixo-esq) usando a matemática de cover
  (dW/dH/dx/dy) igual à cidade.
- **60 palavras novas em `banco_palavras.dart`:** 12 por tema, `Categoria.alimentos` com `tema`,
  2–5 sílabas, sem duplicar as dos níveis normais. Teste `banco_palavras_test` atualizado
  para validar chaves de `Tema` + `AlimentosTema` e checar 10+ palavras por alimentos tema.

## 2026-08-24 — v0.30.0 (Alimentos com foto 1376×768 em 4 cenas)
- **Imagem `1787616789192.png` (2.1 MB, 1376×768) no root:** detectei os vãos pelas
  quebras de média por coluna/linha (dif >30): verticais ~458 e ~917, horizontal
  ~423. Recortei em `assets/alimentos/`: `alimentos_facil` (456×421), `medio`
  (455×421), `dificil` (457×421) e `temas` (1376×343, cena larga). Declarados no
  `pubspec.yaml`.
- **Nova `features/alimentos/alimentos_menu_screen.dart`:** espelha `ObjetosMenuScreen`
  (Scaffold preto sem AppBar, Stack + voltar flutuante, 3 + 1 `_CenaBotao` com
  degradê). Rota na home: `Categoria.alimentos => AlimentosMenuScreen` (antes caía
  no `NivelScreen` genérico). O botão largo "Todos" abre `EstudoScreen` com a união
  dos 3 níveis de Alimentos.

## 2026-08-24 — v0.29.0 (Temas sem AppBar, 100% tela cheia)
- **`temas_screen.dart` sem `AppBar`/`SafeArea`:** removidos `AppBar("Temas")` e o
  `SafeArea` que envolvia o `LayoutBuilder`. Agora `Scaffold(body: Stack[LayoutBuilder(cover),
  voltar flutuante])` — idêntico ao padrão do `ObjetosMenuScreen` v0.28.0. Foto ocupa
  a tela toda; botão voltar circular preto 45% em `SafeArea` no `Positioned(top:6,left:6)`.

## 2026-08-24 — v0.28.0 (Objetos sem AppBar, botão voltar flutuante)
- **Sem `AppBar`:** `ObjetosMenuScreen` agora é `Scaffold(body: Stack[Column(4 cenas), Positioned voltar])`.
  O `AppBar` que mostrava "🧸 Objetos" foi removido e a `Column` encosta no topo
  (sem `SafeArea` ao redor — só o botão voltar está dentro de `SafeArea` flutuante
  com fundo preto 45% circular). Ganha ~56px verticais: as cenas ocupam a tela toda.

## 2026-08-24 — v0.27.0 (Objetos tela cheia sem bordas)
- **`objetos_menu_screen.dart` tela cheia:** removidos `SafeArea`+`Padding(10)` e a
  `DecoratedBox` com `Border.all` do `_CenaBotao` (cara de "card com borda").
  Agora `Scaffold(background:black)` + `Column` sem padding com gaps de `4px`
  (linhas pretas finas). `_CenaBotao` virou `ClipRRect(14)` + `Stack(Image cover
  + degradê preto na base com legenda branca em negrito)` — legenda dentro da
  imagem, sem texto solto abaixo. Mais imersivo, ocupa a tela toda.

## 2026-08-24 — v0.23.0 (menu de Objetos com foto de 4 cenas)
- **Nova tela `features/objetos/objetos_menu_screen.dart`:** substitui a
  `NivelScreen` **só para Objetos** (home: `Categoria.objetos => ObjetosMenuScreen`;
  Alimentos/Nomes seguem na NivelScreen). Paisagem (o app é todo landscape).
- **Origem da arte:** o usuário subiu pelo GitHub uma foto **1536×1024** com 4
  cenas (`file_00000000198c820e82a90e650f7cb448.png`, na RAIZ do repo — commit
  `f066b74 "Add files via upload"` no origin/main). Detectei os vãos brancos com
  PIL (redução BOX → média por coluna/linha): verticais em x≈504–513 e 1021–1029,
  horizontal em y≈461–469. Recortei em 4 assets em `assets/objetos/`:
  `objetos_facil.png` (casa/ESCOLA, 504×461), `objetos_medio.png` (PADARIA,
  508×461), `objetos_dificil.png` (HOSPITAL/SUPERMERCADO, 507×461) e
  `objetos_temas.png` (cena larga MUSEU/ESCOLA/CAFETERIA/BOMBEIROS, 1536×555).
  Declarados no `pubspec.yaml`.
- **Layout:** `Column[ Expanded(flex:5, Row[3 tiles]) , Expanded(flex:4, tile
  largo) ]`. Cada `_CenaBotao` = `Image.asset(BoxFit.cover)` com borda na cor do
  nível (verde/âmbar/vermelho de `Nivel.cor`) + legenda LOGO ABAIXO. As 3 de cima
  chamam `palavrasDe(objetos, nível)` → EstudoScreen (idêntico ao fluxo antigo).
- **Temas (a de baixo):** comportamento ainda **não definido** (usuário decide
  depois) — por ora só um SnackBar "Temas: em breve! 🧩" (botão não fica morto).
- **Legenda "Médio":** o usuário pediu "médio" (masc., concorda com *nível*); a
  `NivelScreen` continua usando "Média" no rótulo do enum — aqui a legenda é só
  visual, o filtro segue `Nivel.media` (3 sílabas).
- **Render de asset em teste:** pra capturar PNG com as imagens decodificadas,
  `tester.runAsync` + `precacheImage(AssetImage(...), element)` ANTES do
  `toImage`. Só achar os `Text` das legendas não precisa disso (existem na árvore
  mesmo sem a imagem pintar) — por isso o `widget_test` valida por texto.
- **⚠️ Pendência de git:** os 4 crops estão LOCAIS; o commit da foto original
  (`f066b74`) está no origin/main mas ainda NÃO no main local. Ao commitar/pushar
  a v0.23.0, integrar o origin/main primeiro (pull) senão o push é rejeitado.

## 2026-08-24 — v0.23.0 (baú do fim de fase: card não corta mais no topo)
- **Sintoma:** o card "NOVA FASE!" que sai do baú (`_BauDialog` em `features/estudo/
  estudo_screen.dart`) ficava CORTADO no topo da tela em paisagem. Confirmado por render
  headless (teste que dispara o baú + `RenderRepaintBoundary.toImage` → PNG): o texto do
  card ficava em **y = −24** (acima do topo da tela). Causa: o card era ALTO (emoji + 4
  linhas de texto ~112 px) e ficava `Positioned(bottom: 74)` num `SizedBox(height:148)` com
  `Clip.none` → transbordava ~55 px acima da caixa, além do topo do `AlertDialog`. Em 360 px
  de altura (paisagem) não havia folga.
- **Fix (3 partes):** (1) `_CardNovaFase` **compacto** — só emoji + "NOVA FASE! 🔓" + o nome
  da região (as frases "Você desbloqueou o cenário…" e "Pronto para conhecer…" saíram; a voz
  TTS já as anuncia). (2) baú um tico menor (`_Bau` CustomPaint `190×128 → 168×112`; o
  `_BauPainter` pinta tudo em frações de `size`, então escala proporcional). (3) a caixa do
  Stack agora é **condicional e CONTÉM o card inteiro**: `height: _aberto ? 200 : 124`
  (fechado = só o baú; aberto = alto o bastante pro card ficar todo dentro, `bottom: 82`),
  `AlertDialog(scrollable: true)` como rede de segurança (rola em telas ainda mais baixas em
  vez de cortar). A "+N moedas!" segue no topo (dá a folga que o card ocupa ao emergir).
- **Verificação:** render headless nos dois estados (fechado/aberto) — todos os rects
  positivos e < 360 (card em y≈55, botões Mapa/JOGAR AGORA em y≈310). Nada cortado.
- **Teste atualizado:** `mapa_mundi_test.dart` checava `find.textContaining('Você
  desbloqueou o cenário')` (texto removido) → trocado por `find.text('NOVA FASE! 🔓')`.
- **Gotcha do render headless:** pra chegar no baú ABERTO no teste, use `pumpAndSettle`
  depois de tocar no `Key('bau')` (as animações são one-shot); `pump` de duração fixa deixava
  `_aberto=false` e o card nem entrava na árvore.

## 2026-08-23 — v0.22.0 (fileira única de 5 botões no mapa-múndi)
- **Layout do rodapé do mapa:** os DOIS SafeArea (INICIAR JOGO à direita + os 4 à esquerda)
  viraram UMA `SafeArea` centralizada com `FittedBox(scaleDown)` + `Row` com os 5 botões
  (INICIAR/CONTINUAR JOGO por último, branco). FittedBox garante que nunca encoste/sobreponha
  em telas menores.
- **Teste `layout_test` atualizado:** as checagens de canto (`iniciar.center.dx > 600`,
  `voltar.center.dx < 300`) foram trocadas por: todos os 5 no mesmo top, sem overlaps entre
  vizinhos, ordem da fileira (voltar < reiniciar < início < coleção < iniciar) e a fileira
  inteira dentro da largura da tela.

## 2026-08-23 — v0.21.0 (diálogos estreitos, sem medalha, COLEÇÃO ↔ MAPA MUNDI)
- **AlertDialog estreito:** `constraints: BoxConstraints(maxWidth: 360)` no `_BauDialog` e
  `_FimCategoriaDialog` (antes o `SizedBox(width: double.maxFinite)` do conteúdo esticava até a
  borda). O Stack do baú agora dimensiona pela largura do próprio baú (190) — o card sai do baú
  sem alargar a janela.
- **Medalha fora do baú:** removida a linha `_medalhaTexto` (e o parâmetro `medalha` do
  `_BauDialog`/chamada de `medalhaDe` no `_concluirFase`). `ProgressoRepository.medalhaDe` fica no
  repositório (ainda coberto pelos testes de `progresso_repository_test`).
- **COLEÇÃO no mapa-múndi:** 4º botão da fileira inferior (`Icons.pets_rounded`, `_abrirColecao`
  empurra `ColecaoScreen` e reaplica paisagem ao voltar). **MAPA MUNDI na coleção:** ação da
  AppBar (`TextButton.icon` com `Icons.public_rounded`) → `_abrirMapaMundi` recarrega a coleção
  ao voltar (`_carregar()` — fases podem ter mudado no mapa).

## 2026-08-23 — v0.20.0 (redesenho do baú: madeira, ouro e TESOURO)
- **`_BauPainter` reescrito com detalhes:** tábuas (vinco vertical) + veios (onda `sin(x/w*3)`),
  faixas de ouro com `_rebite` (3 por faixa no corpo, 2 na tampa), cadeado com placa + buraco
  de fechadura (círculo+triângulo) + alça (`drawArc`), frisos dourados na boca/rodapé/tampa,
  brasão (quadrado rotacionado 45°) e sombra no chão (`MaskFilter.blur`).
- **TESOURO:** `_interiorETesouro` desenha a parede interna (`AppColors.bauInterior` nova) e
  **fileiras de moedas que aparecem progressivamente** — fileira `i` (dy = -6-11i) só desenha
  quando `aberto >= raio - dy` (a boca `p*lidH` "descobre" o tesouro). Moeda = sombra + gradiente
  radial dourado + aresta + brilho; joias = losango com facetas (cores reusadas: `acerto`=esmeralda,
  `accent`=safira); brilhos = cápsulas cruzadas. `_tesouroDerramado` (p>0.55): 3 moedas deslizam
  pela frente do baú. Posições com `Random(7)` (seed fixa — não treme entre frames).
- **FIX da tampa:** rotação pura (`rotate(-p*1.9)`) fazia a tampa balançar para o LADO e COBRIR o
  tesouro (o braço de rotação saindo de cima do corpo nunca sobe). Troquei por **achatar+subir**
  (`visivel = lidH*(1-0.72p)`, `sobe = -p*lidH*0.6`, leve `rotate(-p*0.3)`) — a tampa "levanta e
  afunda para trás", revelando a boca com o tesouro.
- **Inspeção visual sem olhos:** o modelo não lê imagens → usei capturas `matchesGoldenFile`
  (`--update-goldens`) + script Python (PIL) que classifica pixels por cor e imprime "ASCII art"
  da imagem para conferir a estrutura (verificado: interior escuro + clusters dourados de moedas
  no aberto; tampa/frisos/cadeado no fechado). Teste de preview + goldens foram REMOVIDOS depois
  (mantive só o teste funcional do baú com `Key('bau')`).

## 2026-08-23 — v0.19.0 (baú animado 🧰 + "Sair" volta aos cenários)
- **`_BauDialog` virou o baú do tesouro:** fechado → toque (`_abrirBau`) → tampa gira
  (painter `_BauPainter` com `rotate(-p*1.9)` na dobradiça + brilho `RadialGradient`) →
  confetes (`ConfeteBurst(muito:true)` monta SÓ com `_aberto`) → card `_CardNovaFase`
  (escala `elasticOut` saindo de `bottom:74` do stack do baú, `clipBehavior: Clip.none`)
  → botões JOGAR AGORA (`pop(true)`)/Mapa. Na última fase (`proxima == null`) o card
  mostra 🏆. **Atenção:** o card/botões só aparecem quando `_abertura.isCompleted` —
  precisa de `addStatusListener` que chama `setState` (senão o build externo não re-render).
  O `_ProximaFaseDialog` e `_FimDaAventuraDialog` foram REMOVIDOS (o baú absorveu ambos;
  `_concluirFase` agora calcula a próxima fase ANTES do showDialog e `pushReplacement`
  direto). Identificadores Dart NÃO aceitam acento (`_Baú` → `_Bau`, `_BaúPainter` →
  `_BauPainter`). Cores do baú em `AppColors.bau*` (madeira/ouro).
- **`_fimDeCategoria`:** "Sair" agora faz `Navigator.pop()` (volta aos cenários, igual o
  Voltar) — antes só fechava o diálogo. `_acertou` ganhou `if (!mounted) return;` antes
  do `_prepararIncompleta()` final (a tela pode ter sido desmontada pelo pop).
- **Gotcha de teste (fake async):** animações iniciadas por TAP (fora de frame) precisam
  de `pump()` SEM duração antes do `pump(duration)` — o 1º frame só seta o `startTime`
  do ticker (elapsed 0), e o 2º avança o relógio (p. ex. `tapAt(bau)` → `pump()` →
  `pump(800ms)` → `pump()`). Teste novo cobre o baú de ponta a ponta (usa `Key('bau')`
  no `GestureDetector` do baú p/ achar o alvo).

## 2026-08-22 — v0.18.0 (continua de onde parou ▶️ + parabéns de categoria 🎉 + layout do anúncio)
- **`_iniciarJogo` retoma:** carrega `ProgressoFases.carregar()` e abre a 1ª fase NÃO concluída da
  ordem (`fases.indexWhere(!concluida)`, cai pra 0 se todas concluídas). Rótulo dinâmico
  `_rotuloIniciar`: nenhuma concluída = INICIAR JOGO; no meio = CONTINUAR JOGO; todas = REINICIAR
  JOGO. Novo teste `mapa_mundi_test` com `fases_concluidas_v1: ['norte']` confirma que abre a Fase 2.
- **`_fimDeCategoria`:** quando a ÚLTIMA palavra é acertada e `habitatConcluivel == null` (fora do
  mapa-múndi), abre `_FimCategoriaDialog` (PARABÉNS 🏆 + `ConfeteBurst(muito:true)` + fala). "Jogar
  de novo" = `_i=0` + limpa traços + zera sequência; "Sair" = só fecha. **Aviso:** isso MUDOU o teste
  `widget_test` "V dá pontos e X tira" (a 1ª categoria de 1 palavra agora dispara o diálogo — o teste
  fecha com "Sair" antes de testar o X).
- **Diálogos compactos:** `_ProximaFaseDialog` e `_FimCategoriaDialog` usam `insetPadding`
  vertical 16 + `titlePadding`/`contentPadding`/`actionsPadding` apertados e emoji menor (52) —
  em tela 800×360 (paisagem) o conteúdo NÃO estoura nem encosta nos botões (AlertDialog sem
  scroll + Column → overflow sobrepunha os actions).

## 2026-08-22 — v0.17.0 (app fala as palavras 🗣️ + vibração 📳)
- **TTS:** dependência nova `flutter_tts` (^4.2.5, precisa minSdk 21 — já OK no gradle).
  `services/fala.dart` = singleton `Fala.instance` com `falar(texto)` — configura `pt-BR`,
  `setSpeechRate(0.45)`, `awaitSpeakCompletion(true)`, `stop()` antes de falar; TUDO em
  `try/catch` (emulador/sem voz → silencioso, nunca quebra). `services/config_fala.dart` =
  `ConfigFala.ativado()/salvar()` (padrão LIGADO). Na `EstudoScreen`, `_falarPalavraAtual()`
  (fire-and-forget com `unawaited` de `dart:async`) dispara em `_carregarGamificacao`,
  `_acertou` (ao avançar), `_anterior`, `_proximo`, `_recomecar`; os diálogos `_BauDialog`,
  `_ProximaFaseDialog` e `_FimDaAventuraDialog` falam no `initState`. Toggle `SwitchListTile`
  "Falar a palavra" na ConfigScreen (seção "Como mostrar as palavras").
- **Haptics:** `HapticFeedback.lightImpact()` no acerto, `heavyImpact()` no erro,
  `mediumImpact()` no baú (do `flutter/services.dart`, já importado). Em testes de widget são
  no-op (channel sem handler) — não quebra nada.
- **Gotcha:** `unawaited` exige `import 'dart:async'` (evita lint `unawaited_futures`).

## 2026-08-22 — v0.16.0 (sequência 🔥, confetes 🎉, anel pulsando ✨, coleção 🐾)
- **Sequência de acertos:** `_sequencia` na `EstudoScreen` (zera no `_errou`); a cada `_sequenciaAlvo=3`
  seguidas, bônus `(_sequencia ~/ 3) * 2` via **`ProgressoRepository.registrarBonus(int)`** novo (soma
  XP+moedas, NÃO conta acerto/erro → medalha mede só precisão). Feedback 🔥 entra no slot único
  `_feedback` (substitui o "+pontos" da vez) e o `PontosFeedback` passou a tratar `startsWith('🔥')`
  como positivo (verde). Indicador 🔥 no topo quando `_sequencia >= 2`.
- **`ConfeteBurst`** (`features/estudo/confete.dart`): partículas (rects girando) com origem aleatória,
  ângulo 360°, gravidade e fade, animação ÚNICA de 1.1s via `AnimatedBuilder`+`CustomPaint`
  (`IgnorePointer`). `muito: true` = 70 partículas (baú). Reuso com `ValueKey(_confeteSeq)` — cada
  acerto incrementa e o widget recomeça. Cores da paleta nova **`AppColors.confete`** (regra: nada de
  `Color(0x…)` solto em tela). No `_BauDialog`, o content virou `SizedBox(width: double.maxFinite)`
  com `Stack` (confete atrás + coluna do texto).
- **Anel pulsando:** `_AnelFase` virou StatefulWidget com `AnimationController.repeat(reverse:true)`
  (900ms) SÓ quando `proximo` (1ª fase ainda não concluída da ordem = getter `_proximaChave` no
  estado do mapa). **Gotcha de teste:** animação infinita → `pumpAndSettle` TRAVA (timeout). Os
  testes do mapa (`mapa_mundi_test`, `layout_test`) trocaram `pumpAndSettle` por pumps de duração
  fixa (`pump()` pra processar microtasks + `pump(400ms)` pra transição).
- **Coleção:** `features/colecao/colecao_screen.dart` (grade 4×2 com `Regiao.regioes`, ganho =
  `ProgressoFases.carregar()`); botão `Icons.pets_rounded` na AppBar da home (antes da engrenagem).
  `_BauDialog` ganhou `regiao` (via `Regiao.porChave`) e avisa "Novo animal da coleção".

## 2026-08-22 — v0.15.0 (aventura contínua entre as fases do mapa-múndi)
- **`_concluirFase` agora continua o jogo:** após o `_BauDialog`, chama `_avancarParaProximaFase()` —
  carrega `ConfigOrdem.fases()`, acha o índice da fase atual (`habitatConcluivel`) e: se houver próxima,
  mostra `_ProximaFaseDialog` (bool: JOGAR AGORA=true) e **`Navigator.pushReplacement`** abre a próxima
  `EstudoScreen` (título `Fase ${i+2}`, `palavrasDaRegiao`, `habitatConcluivel`) — o Voltar cai direto no
  mapa, sem pilha acumulada; se for a última, `_FimDaAventuraDialog` só anuncia (devolve false → fica no
  mapa). `_ProximaFaseDialog` = emoji pulando (`AnimationController.repeat(reverse:true)` + translate);
  `_FimDaAventuraDialog` = 🎉 com `elasticOut` (mesmo padrão do `_BauDialog`).

## 2026-08-20 — v0.14.3 (zerar pontuação nas Configurações; feedback "+1/+2" nas Contas)

- **`_PontosFeedback` virou `PontosFeedback`** em `features/estudo/feedback_pontos.dart` (público,
  reusado pela `ContaEstudoScreen` — mesmo padrão de `desenho.dart`; `EstudoScreen` segue usando com
  o mesmo `ValueKey(_feedbackSeq)` + `onFim`). A `ContaEstudoScreen` ganhou `_feedback`/`_feedbackSeq`,
  mostra `'+${_conta.pontos}'` no `Stack` da conta no acerto e limpa ao avançar/`_irPara` (a animação
  de 950ms roda antes do delay de 700ms que troca a conta; `onFim` zera o `_feedback`).
- **Configurações:** `_zerarPontuacao()` zera moedas+XP com `showDialog` de confirmação (destrutivo);
  botão ↺ (restart) à esquerda do − das moedas reusa `_BotaoMaisMenos` que ganhou `tooltip` opcional
  (envelopa com `Tooltip` se preenchido). `salvarMoedas(0)`/`salvarXp(0)` já existiam no repo.

## 2026-08-19 — v0.14.2 (desenho + cor de fundo nas Contas; componentes compartilhados)
- **Extraí `features/estudo/desenho.dart`** com os componentes de "caderno" que eram privados da
  `EstudoScreen`: `Traco`, `DesenhoPainter`, `BolinhaCor` (era `_Bolinha`), `BotaoIconeDesenho` (era
  `_BotaoIcone`). `EstudoScreen` foi refatorada pra usar os públicos (sed nos usos + deletei as
  privadas) — **sem duplicação**. `FundoTela`/`CorCaneta` já eram compartilhados (`estudo_opcoes.dart`).
- **`ContaEstudoScreen`** ganhou: estado `_fundo`/`_caneta`/`_tracos` + handlers de traço; a `Scaffold`
  usa `backgroundColor: _fundo.cor` e o texto da conta usa `ui = _fundo.corLetra`; `_colunaCaneta(ui)`
  à esquerda; o enunciado fica dentro de `Listener`+`Stack(…, CustomPaint(DesenhoPainter))` (rabisca por
  cima); `_TopoContas` recebeu `ui`/`fundo`/`onFundo` e mostra as **bolinhas de cor de fundo**. Numpad
  e `_NavBtn` mantêm suas próprias cores (botões com fundo próprio → visíveis em qualquer fundo).
  `_tracos.clear()` ao trocar de conta (acerto/`_irPara`). analyze limpo, 54 testes; conferido no preview.

## 2026-08-19 — v0.14.1 (fix: canetas/desenho sumiram no modo "completar")
- **Bug:** o `_meioIncompleto` (v0.14.0) substituía o **Row inteiro** do meio, que continha a coluna
  de canetas + a camada de desenho (`Listener`+`_DesenhoPainter`) — então no modo completar sumiram
  as canetas, vassoura, desfazer e o desenho. **Fix:** extraí `_colunaCaneta(ui)` (reusada no corpo
  normal e no completar) e o `_meioIncompleto` virou `Row[_colunaCaneta, Expanded(Column[área de
  desenho com a lacuna, opções])]` — dá pra escrever por cima como nos outros modos. As opções ficam
  FORA do `Listener` (num Column irmão), então toque nas opções e desenho na palavra não conflitam.

## 2026-08-19 — v0.14.0 (modo "completar sílaba" + ordenação por letras→sílabas)
- **Ordenação por dificuldade:** `Palavra.nivelLetras` (letras de `texto`, ignora espaço/hífen) +
  `Palavra.porDificuldade` (**letras primeiro, sílabas depois** — pedido do usuário: rena 4L antes de
  pinguim 7L). Trocado nos sorts do banco (`palavrasDoHabitat/DosHabitats/DaRegiao/palavrasDe`).
  Testes de ordenação atualizados (checam `porDificuldade`) + exemplo rena<pinguim.
- **3º modo de leitura "completar a sílaba" (`ModoLeitura.incompleta`):** palavra em MAIÚSCULAS com
  UMA sílaba escondida (nunca a 1ª) + 4 opções. `services/completar_silaba.dart` (`montarDesafio`:
  sorteia blank ≥1, monta 4 opções = correta + 3 distratores de `poolSilabasMaiusculas()`, embaralha;
  null se <2 sílabas). Integrado NA `EstudoScreen` (não tela nova → todos os pontos de entrada valem):
  `_prepararIncompleta()` monta ao carregar e a cada avanço (proximo/anterior/recomeçar/acertou);
  `_meioIncompleto(ui)` substitui o corpo do meio (lacuna "＿＿" + `Wrap` de `_OpcaoSilaba`); V/X
  escondidos (`if _modo != incompleta`); acerto reusa `_acertou()` (+moedas, avança, conclui fase);
  erro pinta a opção de vermelho (`_erradaSel`, sem penalizar). Palavra de 1 sílaba (escrever) → sem
  desafio → mostra full + "Continuar". Seletor da engrenagem já itera `ModoLeitura.values` (virou 3).
- Testes: `completar_silaba` (blank nunca 0, 4 opções únicas c/ a certa, null p/ 1 sílaba). 54 testes,
  analyze limpo; modo conferido no preview-PNG. **Feature de dificuldade das palavras COMPLETA.**

## 2026-08-19 — v0.13.0 (tela cheia global + minúsculas + Contas Até 20/menu + logo na home)
- **Tela cheia (imersivo) em TODAS as telas:** só habitat/mapa setavam `immersiveSticky`; os demais
  mostravam a barra de status. **Fix:** `main()` agora seta `immersiveSticky` global; troquei os
  `SystemUiMode.edgeToEdge` restantes (habitat dispose + selecao init) por `immersiveSticky` (sed).
  MaterialApp title → 'Jogo do Davi'.
- **Nome Android:** `android:label="Jogo do Davi"` (J maiúsculo). **Logo na home:** `assets/icon/logo.png`
  adicionado aos `assets` do pubspec; `Image.asset` 34px arredondado ANTES do título na AppBar.
- **Modo de leitura (MAIÚSCULAS/minúsculas):** `models/modo_leitura.dart` (enum `ModoLeitura` +
  `aplicar(texto)`), `services/config_leitura.dart` (chave `modo_leitura_v1`, padrão maiúscula).
  Seletor `SegmentedButton` na engrenagem (seção "Como mostrar as palavras", em `config_screen`).
  `EstudoScreen` lê no initState e usa `_modo.aplicar(palavra.texto)` no lugar de `.toUpperCase()`.
  **Decisão de local:** o seletor mora na engrenagem (preferência global do pai). O **3º modo
  "completar sílaba que falta"** (múltipla escolha, MAIÚSCULAS, nunca a 1ª sílaba) fica p/ a próxima
  leva — será tela própria, aí o enum/seletor ganham a 3ª opção.
- **Contas:** `gerarContasAte(limite)` (soma com os dois números ≤ limite; "Até 20"). Menu reescrito:
  8 opções (6 op×dígitos + Até 20 + Escrever) numa **grade 4×2** (`crossAxisCount:4`,
  `childAspectRatio:2.3`) → cabe sem rolar na paisagem (era 3 col e rolava). Botões Anterior/Próximo
  já existiam (v0.12.1).
- Testes: `gerarContasAte`, `config_leitura` (aplica caixa + salva/carrega). 50 testes, analyze limpo;
  menu/home conferidos no preview-PNG.

## 2026-08-19 — v0.12.1 (logo maior + nome "jogo do Davi" + Anterior/Próximo nas contas)
- **Logo maior sem cortar:** `logo.png` e `logo_foreground.png` são o menino sobre âmbar (RGB, 1024²;
  âmbar real = #FDB405 = `adaptive_icon_background`). Script PIL: detecta o bbox do menino (pixels
  distantes do âmbar), reescala pra altura-alvo e recentraliza em canvas âmbar novo. Alvos: `logo.png`
  90% da altura, `logo_foreground.png` **84%** (era 65% — a foreground é a que o Android moderno usa,
  por isso parecia pequena). Menino é **estreito e centralizado** → mesmo grande, cabeça/pés ficam no
  eixo central (máscaras circulares/squircle vão até a borda no centro) = não corta. **Validei** com
  máscara circular no PIL antes de gerar. Depois: `dart run flutter_launcher_icons` regenera
  mipmaps/drawables (NÃO toca no debug.keystore — assinatura segue estável).
- **Nome Android:** `android:label="jogo do Davi"` no AndroidManifest (era "Primeiras Palavras").
- **Contas Anterior/Próximo:** `_irPara(i)` navega sem responder (limpa resposta/trava). Botões
  `_NavBtn` no rodapé da coluna esquerda (desabilitam nas pontas). 47 testes, analyze limpo.

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
