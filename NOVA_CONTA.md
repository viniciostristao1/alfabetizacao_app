# NOVA_CONTA.md — como criar uma categoria de Contas (matemática)

Processo fechado, aprendido criando a **Multiplicação** (v0.101.0 → v0.102.0).
Categorias de **palavras** seguem [`NOVA_CATEGORIA.md`](NOVA_CATEGORIA.md);
categorias de **contas** (operações + gerador + grade + teclado) seguem
este arquivo, do início ao fim — sem reinventar. Molde de referência:
multiplicação "2 à 7 • fácil" + "8 a 15 • Médio".

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

## 1. Modelo — `app/lib/models/conta.dart`

- `enum OperacaoConta { soma, subtracao, mistas, multiplicacao }` — operação
  nova entra aqui. `gerarContas` **nunca** gera `×`: o branch `multiplicacao`
  dá `throw ArgumentError('Use gerarMultiplicacaoFacil()/gerarMultiplicacaoMedio()')`
  (Mistas segue sem multiplicação).
- `Conta(a, b, soma, pontos, [vezes = false])` — `vezes = true` é
  multiplicação: `resultado => a * b`, `sinal => '×'`, `enunciado => 'a × b'`.
  `soma` é ignorado quando `vezes` é true. Pontos: **+1** fácil (2–7 × 2–7),
  **+2** médio (8–15 × 8–15).

## 2. Gerador — `app/lib/services/gerador_contas.dart`

- Conjuntos **fechados e ordenados**, sem repetição dentro da sessão:
  `gerarMultiplicacaoFacil()` → 36 pares 2–7 (produto 4–49), tudo embaralhado;
  `gerarMultiplicacaoMedio()` → 64 pares 8–15 em escala (nível 8–9: 4 pares;
  N = 10..15 com ao menos um fator N: 5+7+9+11+13+15), cada nível embaralhado.
- Assinatura `({int? quantidade, Random? rng})` — `quantidade` omitido =
  conjunto cheio; informado, fatia da frente (ordem/escala respeitadas).
  `rng` existe para os testes serem determinísticos (`Random(seed)`).
- Não tocar em `gerarContas`/`gerarContasAte`/`parseConta` (Soma, Subtração,
  Mistas, Até 20 e Escrever ficam intactos).

## 3. Card e cor na grade — `app/lib/features/contas/contas_menu_screen.dart`

- Cada item é `(rótulo, sub, cor, ação)`: `('× 2 à 7', 'fácil', _multi, ...)` e
  `('× 8 a 15', 'Médio', _medio, ...)` → `_estudo(context, '🧮  2 à 7 • fácil',
  gerarMultiplicacaoFacil())` (mesmo padrão dos demais; títulos do estudo
  usam os nomes exatos do pedido).
- Posições: operações agrupadas — **7ª fácil, 8ª médio**, antes de Até 20 (a
  grade de 4 colunas vai a 10 cards e rola; ver §7 telas).
- Cores: fácil `_multi = Color(0xFF009688)` (teal), médio
  `_medio = Color(0xFFE91E63)` (rosa) — distintas das 6 em uso
  (`#4CAF50`, `#F44336`, `#2196F3`, `#9C27B0`, `#FF9800` + teal).
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

- `totalBolinhas(conta)` = `a * b` (todas verdes) para `vezes`.
- `kMaxBolinhasInline = 40`: até 40, inline embaixo da conta; acima,
  `mostrarBolinhasDialogo` (janela central **com scroll** —
  `SingleChildScrollView` + `maxHeight 0.85`). `15×15 = 225` vai ao diálogo.

## 6. Resposta e pontuação — `app/lib/features/contas/conta_estudo_screen.dart`

- Reuso total, sem mudar a tela: teclado numérico (limite 3 dígitos — cabe
  `210`), `_conferir()` compara `int.parse(_resposta) == conta.resultado`,
  `ProgressoRepository.registrarAcerto(conta.pontos)` (+1 fácil, +2 médio).
  Nenhuma fiação nova (Contas não usa fases/medalhas/coleção).

## 7. Testes (obrigatórios)

- `contas_test.dart` → grupos por gerador: tamanho exato do conjunto
  (36/64), intervalo dos fatores, produto certo, pontos, sinal `×`,
  cobertura total sem repetição (`pares.toSet().length == N`,
  `containsAll` dos extremos e de `6×7`/`7×6`/`14×15`), regra de ordem
  (fácil: tudo embaralhado; médio: blocos 4+5+7+9+11+13+15 com maior fator
  crescente por bloco) e fatia (`quantidade` = frente da lista cheia).
- `conta_estudo_test.dart` → certa aceita (+moedas), errada recusa e fica.
  **Gotcha:** não digitar 2× o mesmo dígito em sequência no teste
  (`find.text('1')` ambigua resposta exibida × tecla) — usar dígitos
  distintos (ex.: erra `13`, acerta `12`; médio: erra `200`, acerta `210`).
- `bolinhas_conta_test.dart` → `totalBolinhas` (inclui `15×15 = 225`) +
  diálogo com 225: `findsNWidgets(225)`, `takeException()` nulo (sem
  estouro) e tempo impresso/com teto generoso.
- `contas_menu_test.dart` → nº exato de cards, subs (`1 dígito` ×3, `fácil`,
  `Médio`), cores exatas dos cards, navegação até o estudo com `×` —
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
