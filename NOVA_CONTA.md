# NOVA_CONTA.md — como criar uma categoria de Contas (matemática)

Processo fechado, aprendido criando a **Multiplicação** (v0.101.0 → v0.102.0)
e a **Divisão** (v0.103.0: divisão exata + bolinhas em dois tons).
Categorias de **palavras** seguem [`NOVA_CATEGORIA.md`](NOVA_CATEGORIA.md);
categorias de **contas** (operações + gerador + grade + teclado) seguem
este arquivo, do início ao fim — sem reinventar. Moldes de referência:
multiplicação "2 à 7 • fácil" + "8 a 15 • Médio"; divisão "÷ até 20 • fácil"
+ "÷ até 100 • difícil".

## 0. O que pedir ao usuário ANTES de começar

Não comece sem isso:

1. **Nome exato** de cada categoria/subcategoria (copiar ipsis litteris para
   card e título do estudo — ex.: `2 à 7 • fácil`, `8 a 15 • Médio`).
2. **Intervalo dos fatores** e se a ordem conta (`6×7` ≠ `7×6`) — define o
   tamanho do conjunto (ex.: 2–7 ordenado = 36; 8–15 ordenado = 64).
3. **Regra de ordem**: tudo embaralhado ou em níveis (ex.: escala pelo maior
   fator: 8–9, 10, …, 15). Sem regra explícita, **não invente sequência**.
4. **Pontos por acerto** (+1/+2) e **tamanho da sessão** (padrão = conjunto
   cheio, sem repetir; `quantidade` fatia da frente).
5. **Cor** de cada card (não repetir as da grade) e **posição** na grade.
6. **A nova operação entra em Mistas?** (na Multiplicação, não — `gerarContas`
   rejeita `×` com `throw ArgumentError`; decidir e registrar antes de codar).

## 1. Modelo — `app/lib/models/conta.dart`

- `enum OperacaoConta { soma, subtracao, mistas, multiplicacao, divisao }` —
  operação nova entra aqui. `gerarContas` **nunca** gera `×` nem `÷`: os
  branches `multiplicacao`/`divisao` dão `throw ArgumentError`
  (Mistas segue sem multiplicação e sem divisão).
- `Conta(a, b, soma, pontos, [vezes = false, divisao = false])` —
  `vezes = true` é multiplicação (`resultado => a * b`, `sinal => '×'`);
  `divisao = true` é divisão exata (`resultado => a ~/ b`, `sinal => '÷'`).
  `soma` é ignorado quando `vezes`/`divisao`. `assert(!(vezes && divisao))`
  (opção (a) do §9: mais um booleano, sem refatorar o modelo). Pontos:
  **+1** fácil (2–7 × 2–7; ÷ até 20), **+2** médio/difícil (8–15 × 8–15;
  ÷ até 100).

## 2. Gerador — `app/lib/services/gerador_contas.dart`

- Conjuntos **fechados e ordenados**, sem repetição dentro da sessão:
  `gerarMultiplicacaoFacil()` → 36 pares 2–7 (produto 4–49), tudo embaralhado;
  `gerarMultiplicacaoMedio()` → 64 pares 8–15 em escala (nível 8–9: 4 pares;
  N = 10..15 com ao menos um fator N: 5+7+9+11+13+15), cada nível embaralhado.
- Assinatura `({int? quantidade, Random? rng})` — `quantidade` omitido =
  conjunto cheio; informado, fatia da frente (ordem/escala respeitadas).
  `rng` existe para os testes serem determinísticos (`Random(seed)`).
- Não tocar em `gerarContas`/`gerarContasAte` (Soma, Subtração,
  Mistas, Até 20 ficam intactos). `parseConta` lê as 4 operações **só na
  tela Escrever** (exceção autorizada T001: `xX*`→`×`, `/:`→`÷`, divisão só
  exata sem 0, ×/÷ até 999, `interpretarConta()` devolve `(conta, erro)`).
- Divisão: `gerarDivisaoFacil()` → 27 pares exatos de dividendo 2–20
  (divisor 2–d−1: sem 0/1/próprio; quocientes 2–10), embaralhados, +1 pto,
  conjunto cheio; `gerarDivisaoDificil({quantidade = 20})` → pool de 283
  pares exatos de dividendo 2–100, fatia embaralhada de 20 por sessão
  (conjunto cheio inviável p/ criança), +2 ptos. Sem `÷` em `parseConta`
  (Escrever inalterado, como o `×`).

## 3. Card e cor na grade — `app/lib/features/contas/contas_menu_screen.dart`

- Cada item é `(rótulo, sub, cor, ação)`: `('× 2 à 7', 'fácil', _multi, ...)` e
  `('× 8 a 15', 'Médio', _medio, ...)` → `_estudo(context, '🧮  2 à 7 • fácil',
  gerarMultiplicacaoFacil())` (mesmo padrão dos demais; títulos do estudo
  usam os nomes exatos do pedido).
- Posições: operações agrupadas — **7ª fácil, 8ª médio, 9ª ÷ até 20, 10ª
  ÷ até 100**, antes de Até 20 (a grade de 4 colunas vai a 12 cards e rola;
  ver §7 telas).
- Cores: fácil `_multi = Color(0xFF009688)` (teal), médio
  `_medio = Color(0xFFE91E63)` (rosa), divisão fácil `_divF = Color(0xFF795548)`
  (marrom), divisão difícil `_divD = Color(0xFF3F51B5)` (índigo) — distintas
  das 8 em uso (`#4CAF50`, `#F44336`, `#2196F3`, `#9C27B0`, `#FF9800`,
  teal, rosa + teal do enum `Categoria.contas`). Títulos do estudo usam os
  nomes exatos (`🧮  ÷ até 20 • fácil`, `🧮  ÷ até 100 • difícil`); branch
  `÷ ` novo no `_TituloComSimbolo` (igual ao `× `).
- ⚠️ **Exceção documentada à regra de cores** (`AGENTS.md` §2: "cores só via
  `AppColors`"): os cards de Contas usam `const`s locais neste arquivo (e o
  enum `Categoria` usa `Color(0x...)` próprio, ex. `contas #2DD4BF`,
  diferente do teal do card). Opção adotada: **documentar a exceção, sem
  alterar nenhuma cor** — `AppColors` vale para o resto do app.

## 4. Título e símbolo — `_TituloComSimbolo` (mesmo arquivo)

- Títulos `× ...` caem no branch `if (titulo.startsWith('× '))` → `RichText`
  de 2 spans (símbolo grande + resto). **Gotcha de teste:** `find.text()`
  não acha `RichText` — usar `find.textContaining(s, findRichText: true)`.

## 5. Bolinhas — `app/lib/features/contas/bolinhas_conta.dart`

- `totalBolinhas(conta)` = `a * b` para `vezes` (fileiras), `a` (dividendo)
  para `divisao` (fileiras), `a + b` soma, `a` subtração.
- Mult/divisão em **dois tons**: `kGrupoEscuro #1C7A44` + `kGrupoClaro #62E68C`
  (consts locais, mesma exceção de cor do §3). Fileiras = grupos (mult: `a`
  fileiras de `b`; divisão: `b` fileiras de `a÷b`); a **1ª de cada fileira é
  escura** (conta os grupos), o resto é claro (posição redundante com a cor:
  legível p/ daltônicos e em cinza). Ex.: 3×4 = 3 fileiras de (1 escura +
  3 claras); 12÷3 idem.
- `kMaxBolinhasInline = 40`: até 40, inline embaixo da conta; acima,
  `mostrarBolinhasDialogo` (janela central **com scroll** —
  `SingleChildScrollView` + `maxHeight 0.85`). `15×15 = 225` e `100÷2 = 100`
  vão ao diálogo. O gatilho não muda — só o diâmetro adapta via
  `diametroFileiras()` (inline: teto 460×110; diálogo: largura 700, base 28,
  piso 8px).

## 6. Resposta e pontuação — `app/lib/features/contas/conta_estudo_screen.dart`

- Reuso total, sem mudar a tela: teclado numérico (limite 3 dígitos — cabe
  `210`), `_conferir()` compara `int.parse(_resposta) == conta.resultado`,
  `ProgressoRepository.registrarAcerto(conta.pontos)` (+1 fácil, +2 médio).
  Nenhuma fiação nova (Contas não usa fases/medalhas/coleção).

## 7. Testes (obrigatórios)

- `contas_test.dart` → grupos por gerador: tamanho exato do conjunto
  (36/64; divisão: 27 fácil, pool 283/fatia 20 difícil), intervalo dos
  fatores/dividendos, exatidão (`%` zero na divisão; sem 0/1/próprio),
  produto/quociente certo, pontos, sinal `×`/`÷`,
  cobertura total sem repetição (`pares.toSet().length == N`,
  `containsAll` dos extremos e de `6×7`/`7×6`/`14×15`, `12÷3`/`100÷2`),
  regra de ordem (fácil: tudo embaralhado; médio: blocos 4+5+7+9+11+13+15
  com maior fator crescente por bloco) e fatia (`quantidade` = frente da
  lista cheia).
- `conta_estudo_test.dart` → certa aceita (+moedas: +1 fácil, +2 médio/
  difícil), errada recusa e fica. Dígitos distintos (mult: erra `13`,
  acerta `12`; médio: erra `200`, acerta `210`; divisão: fácil erra `5`,
  acerta `4`; difícil erra `26`, acerta `25`).
- `bolinhas_conta_test.dart` → `totalBolinhas` (inclui `15×15 = 225` e
  `100÷2 = 100`) + diálogos com `findsNWidgets` exato, tons exatos por
  posição (líder escura nos índices `0, b, 2b…`), `takeException()` nulo
  (sem estouro) e tempo impresso/com teto generoso.
- `contas_menu_test.dart` → nº exato de cards (12), subs (`1 dígito` ×3,
  `fácil` ×2, `Médio`, `difícil`), cores exatas dos 4 cards de ×/÷,
  navegação até o estudo com `×`/`÷` —
  **nos dois tamanhos**: celular deitado `800×360` e tablet `1280×800`
  (`scrollUntilVisible` + `pumpAndSettle` antes do toque).

## 8. Fechamento (fluxo padrão do repo)

- `flutter analyze lib/ test/` limpo + `flutter test` verde (ver
  `PROTOCOLO_VPS.md`: 1 comando por vez, `--concurrency=1`, fundo + log).
- Versão (`app/pubspec.yaml` + `kVersao` em `app/lib/util/versao.dart`),
  1 linha em `ATUALIZACOES.md` + nota em `APRENDIZADOS.md`, commit + push +
  CI + `scripts/release.sh` + link do APK (ver `AGENTS.md` §4).
- Tamanho padrão da sessão = **conjunto cheio** (36/64); se o usuário pedir
  fatias, `quantidade` já suporta.

## 9. Variações futuras (só registro)

**Divisão → FEITA na v0.103.0.** Decisões tomadas (valem de molde): só exata;
`0`, `1` e o próprio número fora; `assert(!(vezes && divisao))` no modelo;
fácil 27 em sessão cheia, difícil pool 283 em fatias de 20. Se chegar uma 4ª
operação, reavaliar o campo único de operação (opção (b) abaixo).

**Registro original (resolvido):** o modelo `Conta` usava **um booleano por
operação** (`soma`, `vezes`) — padrão que não escala: cada operação nova pede
mais um flag e mais branches em `resultado`/`sinal`. Decidido: opção (a)
(outro booleano) agora, migração conjunta só com a 4ª operação:
1. **Só divisão exata ou com resto?** → só exata (teclado não tem vírgula).
2. **Campo de operação em vez de flags?** → não agora; migrar `soma`/`vezes`/
   `divisao` juntos se preciso.
