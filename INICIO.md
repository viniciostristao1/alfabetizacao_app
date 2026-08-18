# Primeiras Palavras — INÍCIO (ler primeiro em toda tarefa)

App **Flutter** para uma **criança aprender a ler**. Bem simples, tema **escuro**.
Fluxo: tela principal com **4 modalidades** de palavras → escolher **nível** (nº de
sílabas) → a tela **gira para paisagem** e mostra **uma palavra grande** de cada vez,
com botões embaixo. **Sem áudio e sem figura** por enquanto (decisão do usuário — MVP
minimalista). Meta futura: Play Store, como os apps irmãos.

> ⚠️ Projeto **isolado**. Vive **só** em `/root/alfabetizacao_app/`.
> NUNCA tocar em `/root/trading*`, `/root/calistenia_app/`, `/root/carlog_app/`,
> `/root/lista_app/`, `/root/adm-projetos/`.

> 📓 **Fluxo fixo (harness):** ao fim de cada bloco significativo →
> 1. `cd app && /root/flutter/bin/flutter analyze lib/ test/` (e `flutter test`) **limpos**;
> 2. **subir a versão** em `app/pubspec.yaml` (`X.Y.Z+N` → o `+N`/versionCode tem de crescer)
>    e o `kVersao` em `app/lib/util/versao.dart`;
> 3. registrar em [`APRENDIZADOS.md`](APRENDIZADOS.md) (técnico) e, se visível ao usuário,
>    UMA LINHA em [`ATUALIZACOES.md`](ATUALIZACOES.md) (topo = mais recente); planos → [`IDEIAS.md`](IDEIAS.md).
>
> Papéis dos docs: referência (`INICIO`) · **regras/como contribuir (`AGENTS.md`)** ·
> mapa de padrões (`ARQUITETURA.md`) · técnico/gotchas (`APRENDIZADOS`) · changelog do
> usuário (`ATUALIZACOES`) · futuro (`IDEIAS`).

## ⭐ ESTADO ATUAL (2026-08-18) — ler primeiro pós-/clear

**v0.3.0 — + JOGO DE HABITATS (Animais)** (`flutter analyze` limpo, 10 testes passando).
Assinatura estável desde v0.2.2 (`app/android/app/debug.keystore` versionado — NÃO apagar).
Ícone do app em `app/assets/icon/` (gerado por `flutter_launcher_icons`).

**O que existe e funciona:**
- **Home** (retrato) — 4 cards: **Animais 🐶 · Objetos 🧸 · Alimentos 🍎 · Nomes 🔤**
  (emoji/cor são só apoio visual de navegação p/ quem ainda não lê).
- **Animais = JOGO de habitats** (v0.3.0): tocar em Animais abre o **mapa de habitats** (PAISAGEM,
  `assets/habitats/mapa_animais.jpg`, grade 3×2). 5 botões: ❄️ Ártico · 🦁 Savana · 🌴 Selva ·
  🐠 Aquático · 🦅 Aves (6ª célula = mapa-múndi, reservada). Cada habitat abre o Estudo **SEM escolher
  nível**, rodando do menos ao mais sílabas. `palavrasDoHabitat` em `services/banco_palavras.dart`.
- **Níveis** (retrato) — para Objetos/Alimentos/Nomes: **Fácil (2 sílabas) · Média (3) · Difícil (4)**,
  cada card mostra quantas palavras tem.
- **Estudo** (PAISAGEM) — **uma palavra grande em CAIXA ALTA** de cada vez (`FittedBox`).
  - **Cor de fundo** (bolinhas HORIZONTAIS no topo, ao lado do título): preto/branco/bege
    escuro/bege claro. A palavra é **branca só no preto**, **preta** nos demais (contraste).
  - **Escrever na tela** (bolinhas de caneta VERTICAIS à esquerda: azul/vermelho/amarelo/roxo +
    botão limpar) — a criança escreve por cima como num caderno (dedo ou caneta capacitiva). O
    desenho some ao trocar de palavra.
  - Botões **baixos** embaixo: **Voltar** (volta ao menu + restaura retrato), **Anterior**,
    **Recomeçar**, **Próximo**. Progresso "3 / 12" no topo.
- **Banco de palavras** curado em `app/lib/services/banco_palavras.dart` (**~181 palavras**:
  animais 35 por habitat · objetos 59 · alimentos 57 · nomes 30), **offline**, guardando as
  **sílabas** (não só o texto) — já deixa pronto o "sílabas coloridas" e as subcategorias (`sub`).

**Decisões de origem (2026-08-18):**
- MVP = **só a palavra, sem áudio e sem imagem** (pedido do usuário; começar simples).
- Nome de exibição **"Primeiras Palavras"**; pacote Android **`com.vinyapps.alfabetizacao`**;
  pasta do projeto Flutter `app/` com `--project-name alfabetizacao`. Nada publicado/assinado
  ainda → nome/pacote ainda são fáceis de trocar (só antes do 1º release na loja).
- Palavra em **CAIXA ALTA** (mais legível pra quem começa). Um toggle maiúsculas/minúsculas
  é candidato do IDEIAS.

**Próximos passos (ver [`IDEIAS.md`](IDEIAS.md)):**
1. **Modo Microfone** (fase 2): criança fala a palavra, app reconhece se acertou; **3
   tentativas**; se errar, o app **fala a palavra** (TTS). Ressalvas de voz infantil no IDEIAS.
2. **Gamificação**: moedas + troféus.
3. **Subcategorias**: animais (aquático/terrestre/voador), nomes (menino/menina), objetos
   (casa/rua) — o campo `sub` do banco **já vem preenchido**.
4. **Repo GitHub + CI = LIVE** (público, `viniciostristao1/alfabetizacao_app`). Push em `app/**`
   → CI compila APK universal (assinado em DEBUG) → `ci-latest`; `scripts/release.sh vX.Y.Z "nota"`
   corta o release. **Link perene do APK:**
   `https://github.com/viniciostristao1/alfabetizacao_app/releases/latest/download/primeiras-palavras.apk`
   (repo PÚBLICO por causa da cota de Actions no plano grátis).

## Princípios (não violar)
1. **Simples pra criança** — poucos toques, texto grande, tema escuro, nada de tela poluída.
2. **Offline** — funciona 100% local; sem login/nuvem por enquanto.
3. **Sem frustrar** — no futuro Modo Microfone, erro nunca trava (3 tentativas + o app fala).
4. **Dados curados** — palavras/sílabas revisadas à mão em `banco_palavras.dart`.

## Técnico
- Flutter **3.44.7** / Dart **3.12.2** em `/root/flutter`.
- Estado: **Riverpod** (`flutter_riverpod`) — já no `ProviderScope` do `main`, pronto p/ a
  gamificação. Persistência local: **shared_preferences** (ainda não usada; entra com moedas/troféus).
- Arquitetura **feature-based**: `app/lib/features/<feature>/`.
- Pacote Android **com.vinyapps.alfabetizacao**; exibição **Primeiras Palavras**.
- **Build de APK sai na nuvem** (padrão dos apps irmãos) quando houver repo/CI — a VPS é fraca.

## Estrutura do código (`app/lib/`)
> Mapa de PADRÕES (como adicionar tela/palavra/subcategoria) → [`ARQUITETURA.md`](ARQUITETURA.md).
- `models/` — `categoria.dart` (enums `Categoria` e `Nivel`), `palavra.dart` (sílabas +
  `texto`/`nivelSilabas` + `sub` + `habitat` + `textoOverride`), `habitat.dart` (5 habitats +
  posição na grade 3×2), `estudo_opcoes.dart` (`FundoTela`, `CorCaneta`).
- `services/` — `banco_palavras.dart` (lista curada + `palavrasDe`/`contarPalavras`/`palavrasDoHabitat`).
- `theme/` — `app_colors.dart` (tokens do tema escuro), `app_theme.dart` (`buildAppTheme`).
- `util/` — `versao.dart` (`kVersao`).
- `features/` — `home/` (as 4 categorias), `nivel/` (Objetos/Alimentos/Nomes), `habitat/` (mapa de
  habitats dos Animais, paisagem), `estudo/` (paisagem: palavra + fundo + caneta).
- `main.dart` — trava retrato global; a EstudoScreen gira p/ paisagem e restaura ao sair.

## Ambiente
VPS: ~1 vCPU, pouca RAM. OK para codar/`flutter analyze`/`flutter test`; **build de APK
sai na nuvem** quando montarmos o CI.
