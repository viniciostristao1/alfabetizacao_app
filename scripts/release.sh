#!/usr/bin/env bash
# release.sh — corta um release nomeado a partir do build mais recente do CI.
#
# Uso:
#   scripts/release.sh <versao> "<nota de changelog em 1 linha>"
#   ex: scripts/release.sh v0.1.0 "Primeira versão: 4 categorias + níveis + leitura"
#
# Pré-requisito: o commit já foi PUSHADO e o CI ficou VERDE (publica em 'ci-latest').
#   Acompanhe:  gh run watch <id> --exit-status   antes de chamar isto.
#
# O que faz:
#   1. baixa o APK do release rolling 'ci-latest';
#   2. cria o release <versao> com asset versionado + de NOME FIXO (primeiras-palavras.apk).
#
# O nome fixo faz o link abaixo apontar SEMPRE pro APK mais novo (sem trocar de URL):
#   https://github.com/viniciostristao1/alfabetizacao_app/releases/latest/download/primeiras-palavras.apk
set -euo pipefail
REPO=viniciostristao1/alfabetizacao_app

VER="${1:?uso: scripts/release.sh <versao> \"<nota>\"  (ex: v0.1.0)}"
NOTA="${2:-$VER}"
NUM="${VER#v}"; NUM="${NUM%%-*}"   # "0.1.0" a partir de "v0.1.0"

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

echo "→ Baixando o build de 'ci-latest'…"
gh release download ci-latest -R "$REPO" -p primeiras-palavras.apk --clobber

# sanidade: APK íntegro e assinado
unzip -t primeiras-palavras.apk >/dev/null || { echo "APK corrompido"; exit 1; }

cp primeiras-palavras.apk "primeiras-palavras-${NUM}.apk"

echo "→ Criando release ${VER}…"
gh release create "$VER" -R "$REPO" --title "$VER" --notes "$NOTA" \
  "primeiras-palavras-${NUM}.apk" "primeiras-palavras.apk"

echo
echo "✓ Release ${VER} publicado."
echo "  APK SEMPRE-A-ÚLTIMA (link fixo p/ o usuário):"
echo "      https://github.com/$REPO/releases/latest/download/primeiras-palavras.apk"
