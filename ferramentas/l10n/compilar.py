"""Compila cada l10n/<idioma>/fuxico.po em fuxico.mo e confere se a tradução está completa.

Uso, na raiz do repositório:
  python3 -I ferramentas/l10n/compilar.py

Gera o mesmo .mo que o `msgfmt --no-hash` do gettext, sem precisar instalá-lo.
Falha (saída 1) se faltar tradução para algum texto do fuxico.pot ou se os
marcadores (%1, %2...) não baterem.
"""
import ast
import pathlib
import re
import struct
import sys

RAIZ = pathlib.Path(__file__).resolve().parents[2]
L10N = RAIZ / "l10n"


def ler_po(caminho):
    entradas = []
    atual = {}
    campo = None

    def fechar():
        nonlocal atual, campo
        if "msgid" in atual:
            entradas.append(atual)
        atual, campo = {}, None

    for linha in caminho.read_text(encoding="utf-8").splitlines():
        linha = linha.strip()
        if not linha:
            fechar()
            continue
        if linha.startswith("#"):
            continue
        m = re.match(r'^(msgid_plural|msgid|msgstr(?:\[(\d+)\])?)\s+(".*")$', linha)
        if m:
            nome = m.group(1)
            if nome == "msgid" and "msgid" in atual and ("msgstr" in atual or "plurais" in atual):
                fechar()
            valor = ast.literal_eval(m.group(3))
            if m.group(2) is not None:
                atual.setdefault("plurais", {})[int(m.group(2))] = valor
                campo = ("plurais", int(m.group(2)))
            else:
                atual[nome] = valor
                campo = nome
        elif linha.startswith('"') and campo:
            valor = ast.literal_eval(linha)
            if isinstance(campo, tuple):
                atual["plurais"][campo[1]] += valor
            else:
                atual[campo] += valor
    fechar()
    return entradas


def marcadores(s):
    return sorted(re.findall(r"%\d", s))


def conferir(entradas, modelo, idioma):
    problemas = []
    traduzidas = {(e["msgid"], e.get("msgid_plural")): e for e in entradas if e["msgid"]}
    for e in modelo:
        if not e["msgid"]:
            continue
        chave = (e["msgid"], e.get("msgid_plural"))
        t = traduzidas.get(chave)
        if t is None:
            problemas.append(f"{idioma}: falta {e['msgid']!r}")
            continue
        if chave[1] is None:
            if not t.get("msgstr"):
                problemas.append(f"{idioma}: vazio {e['msgid']!r}")
            elif marcadores(t["msgstr"]) != marcadores(e["msgid"]):
                problemas.append(f"{idioma}: marcadores diferentes em {e['msgid']!r}")
        else:
            plurais = t.get("plurais", {})
            if not plurais.get(0) or not plurais.get(1):
                problemas.append(f"{idioma}: plural incompleto {e['msgid']!r}")
            elif marcadores(plurais[1]) != marcadores(chave[1]):
                problemas.append(f"{idioma}: marcadores diferentes no plural de {e['msgid']!r}")
    return problemas


def gravar_mo(entradas, destino):
    pares = []
    for e in entradas:
        if e.get("msgid_plural") is not None:
            plurais = e.get("plurais", {})
            if not all(plurais.values()):
                continue
            chave = e["msgid"] + "\0" + e["msgid_plural"]
            valor = "\0".join(plurais[i] for i in sorted(plurais))
        else:
            if not e.get("msgstr"):
                continue
            chave, valor = e["msgid"], e["msgstr"]
            if chave == "":
                valor = "".join(l for l in valor.splitlines(keepends=True) if not l.startswith("POT-Creation-Date:"))
        pares.append((chave.encode("utf-8"), valor.encode("utf-8")))
    pares.sort(key=lambda p: p[0])
    n = len(pares)
    inicio_dados = 28 + n * 16
    originais, traducoes, dados = [], [], b""
    for chave, _ in pares:
        originais.append((len(chave), inicio_dados + len(dados)))
        dados += chave + b"\0"
    for _, valor in pares:
        traducoes.append((len(valor), inicio_dados + len(dados)))
        dados += valor + b"\0"
    saida = struct.pack("<7I", 0x950412DE, 0, n, 28, 28 + n * 8, 0, inicio_dados)
    for tamanho, offset in originais + traducoes:
        saida += struct.pack("<2I", tamanho, offset)
    destino.write_bytes(saida + dados)
    return n


def main():
    modelo = ler_po(L10N / "fuxico.pot")
    todos = []
    for po in sorted(L10N.glob("*/fuxico.po")):
        idioma = po.parent.name
        entradas = ler_po(po)
        todos += conferir(entradas, modelo, idioma)
        n = gravar_mo(entradas, po.with_suffix(".mo"))
        print(f"{idioma}: {n} entradas -> {po.with_suffix('.mo').relative_to(RAIZ)}")
    for p in todos:
        print(p)
    return 1 if todos else 0


if __name__ == "__main__":
    sys.exit(main())
