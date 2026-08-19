# IDEIAS — Primeiras Palavras (backlog / futuro)

Ordem ≈ prioridade conversada. Nada aqui está pronto; é roteiro.

## 🎤 Fase 2 — Modo Microfone (próximo grande passo)
A criança **fala** a palavra; o app reconhece se **acertou**.
- **Como:** `speech_to_text` (voz → texto, do Android/Google) + `flutter_tts` (o app fala).
- **Regras (decisão do usuário):** **3 tentativas**. Se errar as 3, o app **fala a palavra**
  (TTS) e segue. Erro **nunca trava** a criança.
- **Matching tolerante:** ignorar acento e aceitar diferença pequena (1 letra / distância curta)
  — palavra isolada é o caso mais fácil pro reconhecedor.
- **Ressalva honesta:** reconhecimento é treinado em voz adulta; **voz de criança erra mais**,
  costuma pedir internet e sofre com barulho. Precisa **testar no aparelho com a voz do filho**
  e calibrar a tolerância. Ter um "não entendi, tenta de novo" e, se quiser, um override manual.
- Vira um **modo/feature próprio** (`features/microfone/` + `services/voz.dart`); pede permissão
  de microfone no `AndroidManifest`.
- **Nota (2026-08-18) — não precisa "treinar" antes:** o reconhecedor é o do **Android/Google**
  (pré-treinado, sem modelo custom no app), então **não** precisamos gravar a voz do filho antes de
  construir. A voz dele serve pra **calibrar a tolerância** no aparelho DEPOIS de pronto (voz
  infantil erra mais). Complexidade = **média** (pacote + permissão + matching tolerante + TTS de
  apoio); o gargalo real é **testar no celular** (a VPS não tem microfone/emulador). Plano: montar o
  modo com toggle, publicar, e ajustar a tolerância com o filho. `speech_to_text` costuma exigir
  internet; um fallback offline é item aberto.

## 🪙 Gamificação — moedas e troféus
- ✅ **v0.10.0:** XP (nunca cai) + nível + **moedas** (saldo com floor 0) no
  V/X da EstudoScreen; **baú** (+10) e **medalha** (🥇🥈🥉) por precisão ao
  concluir fase no mapa-múndi. `services/progresso_repository.dart`.
- **A decidir:** o que as moedas **compram** — sugestão: tela de **Prêmios
  reais** (o pai cadastra "10 moedas = 1 figurinha", a criança troca com ele).
- Ideias: barrinha de progresso por nível, "vitrine" de troféus, som/animação de
  recompensa, sequência de acertos (streak), cosmetéticos (canetas/fundos) por nível.

## 🗺️ Mapa de habitats (Animais) — FEITO (v0.3.0 → v0.4.0), com pontas a evoluir
- Já existe: Home → mapa de habitats (paisagem, na dimensão certa + água ao redor) → 5 botões
  (Ártico/Savana/Selva/Aquático/Aves); cada um roda do mais fácil ao mais difícil.
- **Selecionar animais** (v0.4.0): botão no mapa → busca com lupa + "+" por animal → Confirmar.
- **Mapa-múndi de FASES** (v0.4.0 → v0.5.0): discos 3D neon por habitat; concluir acende o disco + o
  caminho até a próxima fase (progresso salvo em `progresso_fases.dart`). Botões **Voltar habitat** e
  **Reiniciar aventura** (v0.5.0). **A evoluir:** o progresso hoje é global (não por perfil de
  criança); pensar em escolher perfil quando entrar a gamificação. As fases seguem a ordem fixa de
  `Habitat.ordem` mas não bloqueiam jogar fora de ordem — se quiser "trancar" fase futura até
  concluir a anterior, dá pra fazer.
- **Arte do mapa-múndi — FEITO (v0.7.0):** virou **ilustração raster** gerada por IA
  (`assets/habitats/mapa_mundi.jpg`, 1376×768) com relevo/sombra/bichos por continente; o vetorial da
  v0.6.0 foi aposentado. **A evoluir se quiser:** animar o brilho "fumacinha" das fases (pulsar),
  nomes dos continentes/habitats falados (com o TTS), e um habitat **🦘 Austrália/Fazenda** (aí o
  canguru — hoje na Savana — migra pra lá; a arte já tem canguru/coala na Austrália).
- **Mapa-múndi por CONTINENTE — FEITO (v0.11.0):** o mapa-múndi virou geografia (`Palavra.regiao` +
  `models/regiao.dart`): 8 fases = Am. do Norte, Am. do Sul, África, Ásia, Austrália, Ártico, Oceano,
  Céu. **Separado do habitat** (que segue igual na tela anterior). **A evoluir:** dá pra "trancar"
  fase até concluir a anterior; mostrar o nome do continente falado (TTS); e **🐜 Insetos** ainda não
  existe (nem habitat nem região) — criar se quiser (formiga, abelha, aranha…).
- **Fazenda — FEITO (v0.8.0):** domésticos viraram habitat `fazenda`; no mapa-múndi entram na região
  Am. do Norte. Na grade de habitats entram junto de Aves ("Aves e Fazenda").
- **Configurações (v0.8.0):** engrenagem na home → reordenar as fases do mapa-múndi
  (`ConfigOrdem`). A tela pode crescer: escolher quais categorias entram, tema claro, toggle
  maiúsculas/minúsculas, etc.
- **Contas / matemática — FEITO (v0.12.0):** tema Contas (soma/subtração, 1-2 dígitos, teclado
  numérico, +1/+2 moedas, escrever contas). **A evoluir:** multiplicação/divisão; "conta em pé"
  (armar a conta); contas ilustradas (🍎🍎🍎); dificuldade progressiva; e ler o resultado por voz
  quando o TTS entrar.
- Nomes/áudio: quando entrar o TTS, o mapa fica ótimo com o nome do habitat falado.

## 🗂️ Subcategorias das OUTRAS categorias (o campo `sub` do banco já vem preenchido)
- **Nomes:** de menino / de menina.
- **Objetos:** de casa / de rua.
- (Alimentos: dá pra criar depois — ex.: frutas / comidas / bebidas.)
- Mesma ideia do mapa de habitats, ou uma tela de filtro simples entre categoria e nível.

## 🔤 Áudio e figura (o que ficou de fora do MVP por escolha)
- **TTS** para falar a palavra ao tocar (mesmo fora do Modo Microfone).
- **Figura por palavra:** emoji (grátis/offline) ou ilustrações (assets). Ajuda muito a criança
  pequena a associar palavra↔coisa.

## ✍️ Melhorias na leitura
- **⭐ 2 níveis de dificuldade nas palavras (proposta do usuário 2026-08-19 — "pensar depois"):**
  1. **Minúsculas:** um nível/toggle que mostra a palavra em **minúsculas** (hoje é fixo em CAIXA
     ALTA). Fácil (reusa o `texto`; só remover o `.toUpperCase()` condicionalmente).
  2. **Completar a sílaba que falta:** mostra a palavra com uma **sílaba faltando** e a criança
     escolhe a certa entre **4 opções**. Regra: **nunca faltar a 1ª sílaba** (difícil demais) —
     faltar a **2ª ou 3ª**. Os dados de sílaba **já existem** (`Palavra.silabas`). Precisa de:
     tela nova de múltipla escolha; gerar 3 distratores plausíveis (sílabas de outras palavras do
     mesmo banco/nível); pontuar como as demais (V/X ou direto). É uma feature média (tela +
     gerador de distratores + seleção de nível). **Decidir escopo antes de construir.**
- **Sílabas coloridas** (BO·LA em cores alternadas) — os dados de sílaba **já existem**.
- Toggle **MAIÚSCULAS / minúsculas** (hoje é fixo em caixa alta).
- **Embaralhar** a ordem das palavras (botão "misturar").
- **Tocar na palavra** para avançar (além dos botões).

## 👶 Personalização
- **Nomes personalizados:** deixar o pai adicionar o nome do filho, da família e dos amigos
  (a categoria "Nomes" fica muito mais significativa). Guardar local.
- ✅ **Palavras próprias** (categoria "Escrever", v0.9.0): o usuário digita
  qualquer palavra e monta a lista. Falta poder adicionar em **qualquer**
  categoria/lista existente.
- Nome/ícone do app e **tema claro** (hoje só escuro).

## ☁️ Distribuição
- Criar repo GitHub + **CI** (compila APK na nuvem) e link de download perene — replicar o
  padrão do `carlog_app`/`calistenia_app`. Depois, **Play Store** (keystore de upload).
