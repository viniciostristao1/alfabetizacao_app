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
- **⭐ Arte nova do mapa-múndi (pendente):** o `mapa_mundi.jpg` atual (1024², baixa qualidade) precisa
  virar um mapa **relevo/profundidade, estilo infográfico**, de preferência em **paisagem** (~1536×1024
  ou mais largo, pra esticar menos). Claude no CLI **não gera imagem** → duas vias: (a) o usuário gera
  a arte (prompt sugerido: *"stylized infographic world map, top-down, subtle relief/bathymetry,
  soft depth shadows, warm kid-friendly palette, no labels, landscape 3:2"*) e solta em
  `app/assets/habitats/mapa_mundi.jpg` (aí re-tunar `fx`/`fy` dos habitats se o desenho mudar);
  ou (b) desenhar um mapa vetorial em `CustomPaint` (crisp em qualquer resolução, porém trabalhoso).
- **Animais que ficaram de fora** (domésticos: gato, cachorro, vaca…; insetos: formiga, abelha…)
  não cabem nos 5 habitats da imagem. Criar habitats **🚜 Fazenda** e **🐜 Insetos** (nova imagem
  ou células extras) pra readmiti-los.
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
