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
3. **CI montado** (`.github/workflows/build-apk.yml`): todo push no `main` que toca `app/**`
   compila o APK release universal **na nuvem** (a VPS é fraca — NUNCA `flutter build apk` local)
   e publica no release rolling `ci-latest` (asset de nome fixo `primeiras-palavras.apk`).
4. **⭐ REGRA DO USUÁRIO (2026-09-01): SEMPRE que concluir uma versão nova, ENTREGAR a ele o
   link direto do APK.** Passos (o `gh` já está autenticado como `viniciostristao1`):
   ```bash
   git add -A && git commit -m "vX.Y.Z — <resumo>"
   git push                                    # dispara o CI
   # espera o CI ficar VERDE (publica em ci-latest) antes de cortar o release:
   gh run watch "$(gh run list -L1 --json databaseId -q '.[0].databaseId')" --exit-status
   scripts/release.sh vX.Y.Z "<nota de 1 linha>"   # cria o release nomeado a partir do ci-latest
   ```
   **Link perene pra mandar (aponta SEMPRE pro APK mais novo, sem trocar de URL):**
   `https://github.com/viniciostristao1/alfabetizacao_app/releases/latest/download/primeiras-palavras.apk`
5. **Play Store:** ainda não — falta a keystore de upload via secrets (o CI hoje assina com a
   chave de DEBUG, que instala mas não serve pra loja). Ver IDEIAS.

## 5. Definition of Done (checklist)
- [ ] `flutter analyze lib/ test/` limpo e `flutter test` verde.
- [ ] Texto de UI em pt-BR; cores via `AppColors`/enums; nada fora de `/root/alfabetizacao_app/`.
- [ ] Se mexeu no banco de palavras: sílabas corretas (2–4), sem duplicata; teste passa.
- [ ] Versão subida (`pubspec.yaml` + `versao.dart`) se a mudança é visível.
- [ ] 1 linha em `ATUALIZACOES.md` (se visível) + nota em `APRENDIZADOS.md`.
