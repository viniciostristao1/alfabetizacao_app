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
- Ganhar **moedas** ao ler/acertar palavras; **troféus** por marcos (terminar um nível, uma
  categoria, sequência de acertos).
- Guardar em `shared_preferences` (Riverpod) — 1º uso real da persistência. Molde em ARQUITETURA.
- Ideias: barrinha de progresso por nível, "vitrine" de troféus, som/animação de recompensa.

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
- **Fazenda — FEITO (v0.8.0):** domésticos (vaca, cavalo, gato, cachorro…) viraram o habitat
  `fazenda` = fase na Am. do Norte no mapa-múndi; na grade entram junto de Aves ("Aves e Fazenda").
  Falta ainda **🐜 Insetos** (formiga, abelha…) — criar habitat/fase própria. E, se quiser, um
  habitat **🦘 Austrália** (a arte já tem canguru/coala) pra mover o canguru pra lá.
- **Configurações (v0.8.0):** engrenagem na home → reordenar as fases do mapa-múndi
  (`ConfigOrdem`). A tela pode crescer: escolher quais categorias entram, tema claro, toggle
  maiúsculas/minúsculas, etc.
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
- **Sílabas coloridas** (BO·LA em cores alternadas) — os dados de sílaba **já existem**.
- Toggle **MAIÚSCULAS / minúsculas** (hoje é fixo em caixa alta).
- **Embaralhar** a ordem das palavras (botão "misturar").
- **Tocar na palavra** para avançar (além dos botões).

## 👶 Personalização
- **Nomes personalizados:** deixar o pai adicionar o nome do filho, da família e dos amigos
  (a categoria "Nomes" fica muito mais significativa). Guardar local.
- Adicionar **palavras próprias** em qualquer categoria.
- Nome/ícone do app e **tema claro** (hoje só escuro).

## ☁️ Distribuição
- Criar repo GitHub + **CI** (compila APK na nuvem) e link de download perene — replicar o
  padrão do `carlog_app`/`calistenia_app`. Depois, **Play Store** (keystore de upload).
