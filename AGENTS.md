# AGENTS.md — como contribuir em Primeiras Palavras (guia p/ IA e pessoas)

Fluxo de trabalho para qualquer agente (ou pessoa) melhorar o app. O repositório é
**self-contained**: tudo que você precisa está aqui.

## 0. Ordem de leitura (sempre)
1. [`INICIO.md`](INICIO.md) — o que é o app, estado atual, estrutura.
2. **Este `AGENTS.md`** — regras e fluxo.
3. [`ARQUITETURA.md`](ARQUITETURA.md) — padrões (como adicionar tela/palavra/subcategoria).
4. [`APRENDIZADOS.md`](APRENDIZADOS.md) — gotchas técnicos.
5. O código da feature que vai tocar (`app/lib/features/<feature>/`).

## 1. Regras de ouro (NÃO violar)
- **Projeto isolado.** Só `/root/alfabetizacao_app/`. NUNCA tocar em `/root/trading*`,
  `/root/calistenia_app`, `/root/carlog_app`, `/root/lista_app`, `/root/adm-projetos`.
- **Não** compilar APK localmente (VPS fraca) — verifique com `analyze` + `test`. O build
  de release sai na **nuvem** quando houver CI.
- **Não** apagar/editar arquivos sem necessidade; derive/adicione.
- **Nunca commitar segredos** de assinatura (`*.jks`, `key.properties`) — já no `.gitignore`.
- **Público = criança.** UI simples, texto grande, nada de fluxo confuso; erro **nunca**
  frustra (regra do futuro Modo Microfone: 3 tentativas + o app fala a palavra).

## 2. Convenções de código
- **Português (pt-BR)** em todo texto de UI.
- **Cores só via `AppColors`** (`theme/app_colors.dart`) — nunca `Color(0x...)` solto numa
  tela. (As cores de categoria/nível moram nos enums `Categoria`/`Nivel`.)
- **Estado = Riverpod** (já há `ProviderScope`); persistência local = **shared_preferences**
  (entra com a gamificação).
- **Arquitetura feature-based:** telas em `features/<x>/`, modelos em `models/`, dados/lógica
  em `services/`.
- **Palavras novas** vão em `services/banco_palavras.dart` como lista de **sílabas** (o nível
  = nº de sílabas). Ver ARQUITETURA. O teste garante 2–4 sílabas, sem vazio/duplicata.

## 3. Verificação local (obrigatória — as "conferências")
```bash
cd /root/alfabetizacao_app/app
/root/flutter/bin/flutter analyze lib/ test/   # tem de dar "No issues found!"
/root/flutter/bin/flutter test                 # tem de passar (hoje 7 testes)
```
Rodar como root só emite um aviso; funciona. **Não** rode `flutter build apk` (memória/tempo).

## 4. Fluxo de versão/release
1. Toda mudança visível: subir a versão em `app/pubspec.yaml` (`X.Y.Z+N`, o `+N`/versionCode
   **cresce**) e o `kVersao` em `app/lib/util/versao.dart`.
2. 1 linha em [`ATUALIZACOES.md`](ATUALIZACOES.md) (se visível) + nota técnica em
   [`APRENDIZADOS.md`](APRENDIZADOS.md). Planos → [`IDEIAS.md`](IDEIAS.md).
3. **CI/loja:** ainda NÃO montado. Quando for distribuir, replicar o padrão do `carlog_app`
   (GitHub Actions compila o APK na nuvem; `scripts/release.sh` corta o release). Ver INICIO.

## 5. Definition of Done (checklist)
- [ ] `flutter analyze lib/ test/` limpo e `flutter test` verde.
- [ ] Texto de UI em pt-BR; cores via `AppColors`/enums; nada fora de `/root/alfabetizacao_app/`.
- [ ] Se mexeu no banco de palavras: sílabas corretas (2–4), sem duplicata; teste passa.
- [ ] Versão subida (`pubspec.yaml` + `versao.dart`) se a mudança é visível.
- [ ] 1 linha em `ATUALIZACOES.md` (se visível) + nota em `APRENDIZADOS.md`.
