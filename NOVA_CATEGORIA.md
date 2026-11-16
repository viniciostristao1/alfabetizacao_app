# NOVA_CATEGORIA.md — como criar uma categoria completa (Fácil/Médio/Difícil + Temas)

Processo fechado, aprendido criando a categoria **Espaço** (v0.91.0 → v0.96.0).
Da próxima vez que o usuário pedir "cria a categoria X", seguir este arquivo
do início ao fim — sem reinventar. Molde de referência: Espaço
(`Categoria.espaco`); espelhos: Alimentos, Objetos, Nomes.

## 0. O que pedir ao usuário ANTES de começar

Não comece sem isso (foi o que travou/voltou nas versões do Espaço):

1. **Nome, emoji e cor** da categoria.
2. **Lista de palavras** (só o texto; a divisão silábica é conferida no passo 2).
3. **Imagem do menu** — 1 composta (3 cenas em cima + 1 larga embaixo, ex. 1536×1024,
   para fatiar) **ou** 4 separadas (`facil/medio/dificil/temas`).
4. **Foto dos temas** (paisagem, ex. 1672×941) — fundo da tela de fases.
5. **Os 4 temas**: nome + emoji de cada um + **distribuição das palavras por tema**
   (cada palavra em 1 tema; ver passo 7).
6. **Prêmios da coleção**: 1 emoji+nome por tema + 1 bônus final.

## 1. Modelo — `app/lib/models/categoria.dart`
- Nova entrada no enum: `xxx('Rótulo', 'emoji', Color(0x...))`.
- Nada de string/cor solta nas telas: tudo sai desse enum.

## 2. Palavras — `app/lib/services/banco_palavras.dart`
- 1 `Palavra` por palavra, como **lista de sílabas** (o nível = nº de sílabas):
  `1–2 = Fácil`, `3 = Médio`, `4 = Difícil`. **5+ sílabas NÃO têm nível**
  (`palavrasDe` filtra 1/2/3/4) — essas só jogam via Selecionar/Temas.
- Nomes próprios: primeira sílaba com maiúscula (`['Mar', 'te']`).
- Espaço/hífen: `textoOverride` (`Palavra([...], ..., texto: 'buraco-negro')`).
- Sem duplicata dentro da mesma categoria+nível (o teste reprova).
- Adicionar `todosOsXxx()` (ordem alfabética via `semAcento`) — alimenta o Selecionar.

## 3. Frases (Modo Frases) — `app/lib/services/banco_frases.dart`
- **1 frase por palavra**, chave `categoria|texto|tema|habitat|regiao`.
- Regras (o teste reprova tudo isso): **3–7 palavras**, **sem duplicata**,
  **contém a palavra-alvo** (pedaço ≥ 3 letras, sem acento/maiúsculas).
- Forma normal com acentos; a caixa aplica-se na hora (`ModoLeitura`).

## 4. Imagens do menu — `app/assets/xxx/`
- Fatiar a composta (se preciso) em `xxx_facil.png`, `xxx_medio.png`,
  `xxx_dificil.png`, `xxx_temas.png` (topo ~3 painéis + base larga, como Espaço).
- **Registrar as 4 + a foto dos temas no `app/pubspec.yaml`** (sem isso o asset
  não embarca). Mover a original da raiz para `assets/` (raiz não embarca).

## 5. Menu da categoria — `app/lib/features/xxx/xxx_menu_screen.dart`
- Molde `AlimentosMenuScreen`: `Column` com `Row` de 3 em cima (`flex 5`) +
  cena larga embaixo (`flex 4`), `BoxFit.cover`, legenda com gradiente —
  funciona com o celular na horizontal.
- Botões: Fácil/Médio/Difícil → `EstudoScreen(palavrasDe(...))`;
  **Temas (largo) → `XxxTemasScreen`**; transparente **SELECIONAR XXX** → Selecionar.
- Rota na `HomeScreen`: `Categoria.xxx => const XxxMenuScreen()`.
  (O `NivelScreen` genérico está **aposentado** — categoria nova tem menu próprio.)

## 6. Selecionar — `app/lib/features/selecao/selecao_xxx_screen.dart`
- Molde `SelecaoAlimentosScreen` com `todosOsXxx()`, busca via `semAcento`,
  `Confirmar(n)` devolvendo a lista ordenada por sílabas.

## 7. Temas (dados) — modelo + progresso + mapa
- `app/lib/models/xxx_tema.dart`: enum `chave, rotulo, emoji, cor, premioEmoji,
  premioNome` + `porChave()` + `const double kXxxTemasFotoAspect = W / H`
  (medir a foto real).
- `app/lib/services/progresso_xxx_temas_fases.dart`: molde dos demais
  (`fases_xxx_concluidas_v1`, carregar/marcarConcluido/voltarUltima/reiniciar).
- Em `banco_palavras.dart`: `kPalavrasPorTemaXxx` (**cada palavra-base em 1 tema**,
  ex. 9/11/10/8) + `palavrasDoTemaXxx()` (filtra + ordena). **Padrão Espaço:
  reuso sem duplicar** banco nem frases. (Alimentos/Objetos duplicam a palavra por
  tema com frase própria — só faça isso se o tema precisar de frase diferente.)

## 8. Temas (tela) — `app/lib/features/xxx/xxx_temas_screen.dart`
- Molde `NomesTemasScreen`: foto `BoxFit.fill` com `LayoutBuilder` + aspect,
  **4 anéis em zigue-zague** (`x = w/5*(i+1)`, `y` alternando 0.62/0.40) com
  `_Caminho...Painter` neon entre eles, anel da próxima fase **pulsante**.
- **5 botões embaixo** (`FittedBox scaleDown`): `VOLTAR XXX` (pop),
  `REINICIAR AVENTURA` (diálogo + `reiniciar()`), `VOLTAR INÍCIO`
  (`popUntil(isFirst)`), `COLEÇÃO` (emoji da categoria), `INICIAR/CONTINUAR/
  REINICIAR JOGO` (branco, abre a 1ª fase pendente).
- `Image.asset` da foto **com `errorBuilder`** (fundo preto se faltar).
- **Controlador do anel criado sempre no `initState`** (mesmo sem pulsar):
  `late final` inicializado só no `dispose` quebra o teardown dos testes.

## 9. Coleção — `app/lib/features/colecao/colecao_xxx_screen.dart`
- Molde `ColecaoAlimentosScreen`: cards por tema (emoji/nome/prêmio, `❓` se
  pendente) + bônus final (ganho = todos concluídos).
- Cross-link: em **cada uma das demais** coleções, adicionar import +
  `_abrirXxx()` + botão `XXX` no AppBar (e o inverso na nova).

## 10. Estudo — `app/lib/features/estudo/estudo_screen.dart` (5 edições)
1. Imports do modelo + serviço de progresso do tema.
2. Parâmetro + campo `xxxTemaConcluivel`.
3. Branch em `_avancarAposResposta` → `_concluirFaseXxxTemas()`.
4. Método `_concluirFaseXxxTemas()` (bônus + `marcarConcluido` + `_BauXxxDialog`
   com próxima fase via `palavrasDoTemaXxx`) + classes `_BauXxxDialog` /
   `_CardNovaFaseXxx` (molde Alimentos: textos "Novo tesouro", "Voltar a..." etc.).
5. Branch em `_talvezConcluir`.

## 11. Testes (obrigatórios)
- `banco_palavras_test.dart` → grupo `categoria Xxx`: total + `containsAll` por
  nível (+ `luz`-style se houver 1 sílaba; + afirmação das 5+ sílabas) **e** grupo
  `temas do Xxx`: cada tema não-vazio e ordenado + **cobertura total sem
  sobreposição** (`nosTemas.toSet() == todas`).
- `widget_test.dart`: menu abre (Fácil/Médio/Difícil/Temas) + `Xxx > Temas abre
  as fases` (VOLTAR XXX, REINICIAR AVENTURA, COLEÇÃO, INICIAR JOGO). **Sem
  `pumpAndSettle` após entrar nos Temas** (anel pulsante nunca estabiliza):
  `pump(100ms)` + `pump(1s)`.
- `banco_frases_test.dart` já cobre tudo automaticamente (frase por palavra,
  sem duplicata, contém alvo, 3–7 palavras).

## 12. Fechamento (fluxo padrão do repo)
- `flutter analyze lib/ test/` limpo + `flutter test` verde.
- Versão (`pubspec.yaml` + `kVersao`), 1 linha em `ATUALIZACOES.md` + nota em
  `APRENDIZADOS.md`, commit + push + CI + `scripts/release.sh` + link do APK
  (ver `AGENTS.md` §4 — inclusive a regra de entregar o link).
