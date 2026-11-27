"""Gera l10n/fuxico.pot com os textos traduzíveis do plugin.

Uso, na raiz do repositório:
  python3 -I ferramentas/l10n/extrair.py

Procura chamadas _("..."), _([[...]]) e N_("...", "...", n) nos arquivos .lua.
"""
import pathlib
import re
import sys

RAIZ = pathlib.Path(__file__).resolve().parents[2]
STR = r'"((?:[^"\\\n]|\\.)*)"'
SIMPLES = re.compile(r'(?<![\w.])_\(\s*' + STR + r'\s*\)')
LONGA = re.compile(r'(?<![\w.])_\(\s*\[\[(.*?)\]\]\s*\)', re.S)
PLURAL = re.compile(r'(?<![\w.])N_\(\s*' + STR + r'\s*,\s*' + STR)


def lua_para_po(s):
    return s.replace("\\'", "'")


def longa_para_po(s):
    if s.startswith("\n"):
        s = s[1:]
    return s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")


def po_string(s):
    partes = s.split("\\n")
    if len(partes) == 1:
        return f'"{s}"'
    linhas = [p + "\\n" for p in partes[:-1]]
    if partes[-1]:
        linhas.append(partes[-1])
    return '""\n' + "\n".join(f'"{l}"' for l in linhas)


def coletar():
    entradas = {}
    for arquivo in sorted(RAIZ.rglob("*.lua")):
        if any(p.startswith(".") for p in arquivo.relative_to(RAIZ).parts):
            continue
        rel = arquivo.relative_to(RAIZ).as_posix()
        texto = arquivo.read_text(encoding="utf-8")
        for padrao, conv in ((SIMPLES, lua_para_po), (LONGA, longa_para_po)):
            for m in padrao.finditer(texto):
                linha = texto.count("\n", 0, m.start()) + 1
                chave = (conv(m.group(1)), None)
                entradas.setdefault(chave, []).append(f"{rel}:{linha}")
        for m in PLURAL.finditer(texto):
            linha = texto.count("\n", 0, m.start()) + 1
            chave = (lua_para_po(m.group(1)), lua_para_po(m.group(2)))
            entradas.setdefault(chave, []).append(f"{rel}:{linha}")
    return entradas


def main():
    entradas = coletar()
    saida = [
        "msgid \"\"",
        "msgstr \"\"",
        "\"Project-Id-Version: Fuxico\\n\"",
        "\"MIME-Version: 1.0\\n\"",
        "\"Content-Type: text/plain; charset=UTF-8\\n\"",
        "\"Content-Transfer-Encoding: 8bit\\n\"",
        "",
    ]
    for (msgid, plural), refs in entradas.items():
        saida.append("#: " + " ".join(refs))
        saida.append("msgid " + po_string(msgid))
        if plural is None:
            saida.append('msgstr ""')
        else:
            saida.append("msgid_plural " + po_string(plural))
            saida.append('msgstr[0] ""')
            saida.append('msgstr[1] ""')
        saida.append("")
    destino = RAIZ / "l10n" / "fuxico.pot"
    destino.parent.mkdir(parents=True, exist_ok=True)
    destino.write_text("\n".join(saida), encoding="utf-8")
    print(f"{len(entradas)} textos -> {destino.relative_to(RAIZ)}")


if __name__ == "__main__":
    sys.exit(main())
