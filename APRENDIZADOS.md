# APRENDIZADOS.md — técnico / gotchas (Primeiras Palavras)

Notas técnicas e decisões. Topo = mais recente.

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
