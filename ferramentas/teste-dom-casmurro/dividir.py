"""Divide Dom Casmurro (Gutenberg 55752) em capítulos e agrupa em blocos de ~2 mil palavras."""
import json, re, sys
from pathlib import Path

ALVO = 2000  # palavras por bloco
base = Path(__file__).resolve().parent.parent
txt = (base / "fonte" / "dom-casmurro.txt").read_text(encoding="utf-8").replace("\r\n", "\n")
txt = txt.split("*** START OF THE PROJECT GUTENBERG EBOOK 55752 ***")[1]
txt = txt.split("*** END OF THE PROJECT GUTENBERG EBOOK 55752 ***")[0]

# capítulo: linha só com numeral romano (com ou sem ponto), linha em branco, título
padrao = re.compile(r"\n\n\n+([IVXLC]+)\.?\n\n([^\n]+)\n", re.M)
marcas = list(padrao.finditer(txt))
caps = []
for i, m in enumerate(marcas):
    fim = marcas[i + 1].start() if i + 1 < len(marcas) else len(txt)
    corpo = txt[m.end():fim].strip()
    caps.append({"num": m.group(1), "titulo": m.group(2).strip(), "texto": corpo})

# agrupa capítulos inteiros em blocos de ~ALVO palavras (nunca corta capítulo)
blocos, atual = [], []
for c in caps:
    atual.append(c)
    if sum(len(x["texto"].split()) for x in atual) >= ALVO:
        blocos.append(atual); atual = []
if atual:
    blocos.append(atual)

saida = []
for n, bl in enumerate(blocos, 1):
    partes = [f"Capítulo {c['num']} — {c['titulo']}\n\n{c['texto']}" for c in bl]
    saida.append({
        "bloco": n,
        "capitulos": [c["num"] for c in bl],
        "palavras": sum(len(c["texto"].split()) for c in bl),
        "texto": "\n\n".join(partes),
    })

(base / "blocos.json").write_text(json.dumps(saida, ensure_ascii=False, indent=1), encoding="utf-8")
with open(base / "livro-em-blocos.txt", "w", encoding="utf-8") as f:
    for b in saida:
        f.write(f"===== BLOCO {b['bloco']} (capítulos {b['capitulos'][0]} a {b['capitulos'][-1]}) =====\n\n{b['texto']}\n\n")
total = sum(b["palavras"] for b in saida)
print(f"{len(caps)} capítulos, {len(saida)} blocos, {total} palavras")
print("primeiro e último capítulo:", caps[0]["num"], caps[0]["titulo"], "|", caps[-1]["num"], caps[-1]["titulo"])
for b in saida: print(b["bloco"], b["capitulos"][0], "-", b["capitulos"][-1], b["palavras"])
