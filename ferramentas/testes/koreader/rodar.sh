#!/bin/sh
# Roda o Fuxico dentro do KOReader do computador e tira fotos de cada tela.
# Uso: ferramentas/testes/koreader/rodar.sh <pasta koreader do KOReader para computador> <pasta de saída>
# No Mac, a pasta koreader fica em KOReader.app/Contents/koreader.
set -e
KOREADER="$(cd "$1" && pwd)"
SAIDA="$(mkdir -p "$2" && cd "$2" && pwd)"
AQUI="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$AQUI/../../.." && pwd)"
CASA="$SAIDA/casa"

rm -rf "$CASA" "$SAIDA"/*.png "$SAIDA/log.txt"
mkdir -p "$CASA/plugins" "$CASA/patches" "$SAIDA/livros"
rsync -a --exclude .git --exclude .venv --exclude __pycache__ "$REPO/" "$CASA/plugins/fuxico.koplugin/"
cp "$AQUI/2-fuxico-teste.lua" "$CASA/patches/"
python3 -I "$AQUI/gerar_livro.py" "$SAIDA/livros/livro-teste.epub"
cat > "$CASA/settings.reader.lua" <<CONFIG
return {
    ["language"] = "pt_BR",
    ["quickstart_shown_version"] = 999999999,
    ["home_dir"] = "$SAIDA/livros",
}
CONFIG

cd "$KOREADER"
KO_HOME="$CASA" FUXICO_TESTE_SAIDA="$SAIDA" EMULATE_READER_W=600 EMULATE_READER_H=800 EMULATE_BW_SCREEN=1 \
    ./luajit reader.lua "$SAIDA/livros/livro-teste.epub" > "$SAIDA/stdout.txt" 2>&1
cat "$SAIDA/log.txt"
if grep -q "ERRO" "$SAIDA/log.txt" || ! grep -q "^fim" "$SAIDA/log.txt"; then
    exit 1
fi
