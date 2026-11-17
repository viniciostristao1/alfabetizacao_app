# ARQUITETURA.md — padrões de Primeiras Palavras (como fazer as coisas)

Mapa dos padrões recorrentes. Leia junto com [`AGENTS.md`](AGENTS.md).

## Fluxo de telas
```
HomeScreen (retrato)         → escolhe Categoria
    └─ XxxMenuScreen (paisagem) → Fácil/Médio/Difícil em cima, Temas embaixo
         ├─ EstudoScreen (PAISAGEM) → uma palavra por vez + botões
         └─ XxxTemasScreen (paisagem) → foto + 4 anéis de fase + botões
              └─ EstudoScreen (PAISAGEM, fase concluível + baú)
```
(O `NivelScreen` genérico está aposentado — categoria nova tem menu próprio.
Ver [`NOVA_CATEGORIA.md`](NOVA_CATEGORIA.md).)
- Só a **EstudoScreen** gira: força paisagem no `initState` e **garante paisagem
  no `dispose`** (o app todo é deitado — ver `main.dart`; nunca restaura retrato).
  Vale o mesmo para telas de jogo em paisagem (ex.: quiz das posições).

## Modelo de dados
- **`Categoria`** e **`Nivel`** são `enum`s (`models/categoria.dart`) que carregam rótulo,
  emoji e cor — a UI lê tudo daí (nada de string/cor solta nas telas).
- **`Palavra`** (`models/palavra.dart`) guarda **`silabas: List<String>`** (não só o texto):
  - `texto` = `silabas.join()` (é o que a tela mostra, em CAIXA ALTA);
  - `nivelSilabas` = `silabas.length` (define o nível);
  - `sub` = subcategoria futura (opcional), **já pré-preenchida** no banco.

## ➕ Criar CATEGORIA nova (Fácil/Médio/Difícil + Temas + Coleção)
Processo fechado em [`NOVA_CATEGORIA.md`](NOVA_CATEGORIA.md) (aprendido no Espaço,
v0.91.0 → v0.96.0) — **siga-o do início ao fim**. Resumo: enum em `categoria.dart` →
palavras por sílabas + frases no banco → menu próprio com 4 cenas
(`NivelScreen` genérico aposentado) + Selecionar → 4 temas com foto, anéis e
coleção → fiação no `EstudoScreen` → testes (contagem, cobertura dos temas, widget
sem `pumpAndSettle` nos Temas).

## ➕ Adicionar/editar PALAVRAS (o mais comum)
Tudo em `services/banco_palavras.dart`. Uma palavra = uma lista de sílabas:
```dart
Palavra(['ca', 'va', 'lo'], Categoria.animais, sub: 'terrestre'),
```
- O **nível** sai do nº de sílabas (1–2 = fácil, 3 = média, 4 = difícil). Não há campo de nível.
- Nomes próprios: inicial maiúscula nas sílabas (`['Da', 'vi']`) — a tela deixa tudo em
  CAIXA ALTA na exibição, mas o dado guarda a forma correta (útil p/ o futuro).
- Rode `flutter test` — o teste reprova sílaba vazia, palavra com nº de sílabas fora de 2–4,
  duplicata na mesma categoria+nível, e `sub` fora do conjunto previsto.

## ➕ Ativar as SUBCATEGORIAS (fase futura)
O campo `sub` **já existe e já vem preenchido**:
- animais: `aquatico` | `terrestre` | `voador`
- nomes: `menino` | `menina`
- objetos: `casa` | `rua`
Para usar: entre a HomeScreen e a NivelScreen (ou dentro da NivelScreen), adicione um filtro
por `sub` e passe-o ao `palavrasDe(...)` (crie uma variante que também filtre por `sub`).
Nenhuma reescrita do banco é necessária.

## ➕ Adicionar uma TELA/feature
- Pasta `features/<x>/`, tela `StatelessWidget`/`StatefulWidget` (ou `ConsumerWidget` quando
  precisar de Riverpod, ex.: ler moedas/troféus).
- Navegação por `Navigator.push(MaterialPageRoute(...))`.
- Se a tela precisar girar, siga o molde da EstudoScreen (força no `initState`, restaura no `dispose`).

## Gamificação (quando entrar) — molde sugerido
- Um `services/progresso_repository.dart` com Riverpod + `shared_preferences` (fonte da verdade
  local): moedas, troféus, palavras já vistas. É o primeiro uso real do Riverpod/persistência.
- Ganho de moeda/troféu é evento de UI (ex.: terminar um nível) — dispare no `.notifier`.

## Modo Microfone (quando entrar) — ver IDEIAS
- `speech_to_text` (ouvir a criança) + `flutter_tts` (falar a palavra ao errar). Permissão de
  microfone no `AndroidManifest`. Matching **tolerante** (sem acento, distância curta).
  **3 tentativas**; nunca trava. Ficará em `services/voz.dart` + um modo/feature próprio.

## Tema
- Tema **escuro único** por enquanto (`theme/app_theme.dart` → `buildAppTheme()`), lido via
  `AppColors`. Um seletor claro/escuro pode entrar depois; por isso as telas nunca fixam cor.
