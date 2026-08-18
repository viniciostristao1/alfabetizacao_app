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

## 🗂️ Subcategorias (o campo `sub` do banco já vem preenchido)
- **Animais:** aquáticos / terrestres / voadores.
- **Nomes:** de menino / de menina.
- **Objetos:** de casa / de rua.
- (Alimentos: dá pra criar depois — ex.: frutas / comidas / bebidas.)
- Basta uma tela de filtro entre categoria e nível (ver ARQUITETURA §Subcategorias).

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
