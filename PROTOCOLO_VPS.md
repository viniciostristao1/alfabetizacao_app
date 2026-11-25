# PROTOCOLO_VPS.md — como rodar verificação sem derrubar a VPS

A VPS tem **3,8 GB de RAM** e roda o jogo do Davi, o trader e as sessões de
IA juntos. Em 2026-11-25, um `flutter analyze` com várias sessões abertas
provavelmente esgotou a memória e o `systemd-oomd` matou todos os tmux
(sessões perdidas) — causa provável, não confirmada.
Este protocolo existe para isso não se repetir. Vale para qualquer IA.

## 1. Antes de qualquer coisa pesada

```bash
free -h   # confirmar ~2 GB livres (estimativa) antes de analyze/test
ps aux | grep -Ei "dart|flutter|java|gradle" | grep -v grep
```

Só mate processo **órfão da sessão caída** (`kill <pid>`), um por vez, e
relate o que foi encerrado. Nunca `killall`, nunca mexa em processo alheio
(trader, apps, outras sessões).

## 2. Regras de execução (sempre)

- **Um comando por vez, sem paralelismo** — nunca dois `flutter` juntos.
- Testes sempre com **`--concurrency=1`**.
- `analyze` e cada `test` rodam em **segundo plano com log**:
  ```bash
  nohup /root/flutter/bin/flutter analyze lib/ test/ > /tmp/analyze.log 2>&1 &
  nohup /root/flutter/bin/flutter test test/<arquivo>_test.dart --concurrency=1 > /tmp/test-<nome>.log 2>&1 &
  ```
  Acompanhe o log por polling (`tail`); se a sessão cair, o processo
  costuma sobreviver — mas o `systemd-oomd` pode matar o processo junto.
  O log fica em `/tmp`.
- **NUNCA `flutter build apk` local** (memória/tempo) — o APK sai **só via
  CI** (ver `AGENTS.md` §4). `flutter analyze` + `flutter test` é a
  verificação local.
- Se qualquer passo falhar por memória (OOM, `dart` morto): **pare tudo e
  relate antes de tentar de novo**.

## 3. Recortar release de tag já publicada

`scripts/release.sh` **não** é idempotente: ele faz `gh release create`,
que falha se a tag já existe. O script (conferido em
`scripts/release.sh`) faz, nesta ordem: `gh release download ci-latest`
+ `unzip -t` de sanidade + `gh release create <ver>` com os 2 assets
(`primeiras-palavras-<NUM>.apk` e `primeiras-palavras.apk`).

Para republicar a **mesma versão** com um build novo (ex.: correção sob o
mesmo número):

```bash
# 1. apagar o release e a tag remota
gh release delete <ver> --cleanup-tag -y -R viniciostristao1/alfabetizacao_app
# 2. conferir que sumiu
gh release view <ver> -R viniciostristao1/alfabetizacao_app  # deve falhar
git ls-remote --tags origin <ver>                            # deve vir vazio
# 3. garantir que o ci-latest já tem o build novo (CI verde do push)
gh run watch <run-id> --repo viniciostristao1/alfabetizacao_app --exit-status
# 4. recortar
scripts/release.sh <ver> "<nota de 1 linha>"
```

Só use com ordem explícita: reescrever tag publicada troca o APK sob o
link perene.
