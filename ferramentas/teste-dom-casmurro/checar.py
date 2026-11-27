"""Checa as respostas de uma IA no teste do Fuxico (memória da história).

Uso:  python -I scripts/checar.py respostas/gemini.txt
      (cole no .txt todas as respostas da IA, uma depois da outra, como vieram)

Gera respostas/<nome>-relatorio.md com:
  1. Spoiler de nome: nome ou apelido citado no bloco N que só aparece no texto depois de N.
  2. Palavra do futuro: palavra (6+ letras) da memória do bloco N que não está no texto
     até N mas aparece mais adiante no livro. Lista para revisão manual, tem ruído.
  3. Nomes que nunca aparecem no livro (grafia moderna ou invenção).
  4. Blocos faltando, repetidos e limites de palavras estourados.
  5. Os 10 blocos sorteados para conferir fatos à mão.
"""
import json, random, re, sys, unicodedata
from pathlib import Path

base = Path(__file__).resolve().parent.parent
blocos = json.loads((base / "blocos.json").read_text(encoding="utf-8"))
TOTAL = len(blocos)
SORTEIO_SEMENTE = 1899  # ano da edição; igual para as duas IAs


def norm(s: str) -> str:
    """Minúsculas, sem acento e com a ortografia de 1899 aproximada da atual."""
    s = unicodedata.normalize("NFD", s.lower())
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")
    s = s.replace("ph", "f").replace("th", "t").replace("y", "i").replace("z", "s")
    s = re.sub(r"([a-z])\1", r"\1", s)  # letras dobradas: elle -> ele, Matacavallos
    s = s.replace("-", "")
    return s


def palavras(s: str):
    return re.findall(r"[a-z]+", norm(s))


# primeiro bloco em que cada palavra aparece no texto
primeira = {}
for b in blocos:
    for w in set(palavras(b["texto"])):
        primeira.setdefault(w, b["bloco"])
texto_norm = [" ".join(palavras(b["texto"])) for b in blocos]


def primeiro_bloco_da_expressao(expr: str):
    alvo = " ".join(palavras(expr))
    if not alvo:
        return None
    pat = re.compile(r"\b" + re.escape(alvo) + r"\b")
    for i, t in enumerate(texto_norm):
        if pat.search(t):
            return i + 1
    return None


def primeiro_bloco_do_nome(nome: str):
    """Frase exata; se não achar, o bloco em que a última palavra do nome aparece (None se alguma nunca aparece)."""
    pb = primeiro_bloco_da_expressao(nome)
    if pb is not None:
        return pb
    ws = [w for w in palavras(nome) if len(w) > 2]
    if not ws or any(w not in primeira for w in ws):
        return None
    return max(primeira[w] for w in ws)


_NOME = r"[A-ZÁÉÍÓÚÂÊÔÃÕÇ][a-záéíóúâêôãõçü]+"
# palavras que o livro escreve com maiúscula no meio da frase (nomes próprios)
NOMES_LIVRO = set()
for _b in blocos:
    for _m in re.finditer(r"(?<=[a-záéíóúâêôãõçü,] )([A-ZÁÉÍÓÚÂÊÔÃÕÇ][a-záéíóúâêôãõçü]+)", _b["texto"]):
        NOMES_LIVRO.add(norm(_m.group(1)))
_SEQ = re.compile(_NOME + r"(?:\s+(?:(?:de|da|do|dos|das)\s+)?" + _NOME + r")*")


def nomes_no_texto(txt: str):
    """Sequências de palavras com maiúscula, ignorando a primeira palavra de cada frase."""
    for frase in re.split(r"(?<=[.!?])\s+", txt):
        for m in _SEQ.finditer(frase):
            nome = m.group(0)
            if m.start() == 0 and norm(nome.split()[0]) not in NOMES_LIVRO:
                # primeira palavra da frase e não é nome do livro: tira ela
                partes = nome.split(None, 1)
                if len(partes) == 1:
                    continue
                nome = partes[1]
                if nome.split()[0] in ("de", "da", "do", "dos", "das"):
                    continue
            yield nome


def ler_respostas(caminho: Path):
    bruto = caminho.read_text(encoding="utf-8")
    dec = json.JSONDecoder(strict=False)  # aceita quebra de linha dentro do texto (cópia do AI Studio)
    achados, i = [], 0
    while i < len(bruto):
        if bruto[i] in "[{":
            try:
                obj, fim = dec.raw_decode(bruto, i)
            except json.JSONDecodeError:
                i += 1
                continue
            itens = obj if isinstance(obj, list) else [obj]
            for it in itens:
                if isinstance(it, dict) and "bloco" in it:
                    achados.append(it)
            i = fim
        else:
            i += 1
    return achados


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    caminho = Path(sys.argv[1])
    itens = ler_respostas(caminho)
    por_bloco, repetidos = {}, []
    for it in itens:
        n = int(it["bloco"])
        if n in por_bloco:
            repetidos.append(n)
        por_bloco[n] = it  # vale a última versão
    faltando = [n for n in range(1, TOTAL + 1) if n not in por_bloco]

    spoiler_nome, nunca, futuro, limites = [], {}, [], []
    STOP = set(palavras("""capitulo bloco narrador leitor livro historia memoria resumo
        personagem personagens enquanto durante depois antes ainda sobre entre quando""" ))

    for n in sorted(por_bloco):
        it = por_bloco[n]
        r_ate = it.get("resumo_ate_aqui", "") or ""
        r_bl = it.get("resumo_do_bloco", "") or ""
        pers = it.get("personagens", []) or []
        if len(r_ate.split()) > 120:
            limites.append(f"bloco {n}: resumo_ate_aqui com {len(r_ate.split())} palavras")
        if len(r_bl.split()) > 50:
            limites.append(f"bloco {n}: resumo_do_bloco com {len(r_bl.split())} palavras")
        if len(pers) > 10:
            limites.append(f"bloco {n}: {len(pers)} personagens")

        nomes = []
        for p in pers:
            nomes.append(("nome", p.get("nome", "")))
            nomes += [("apelido", a) for a in (p.get("apelidos") or [])]
        for tipo, nome in nomes:
            if not nome.strip():
                continue
            pb = primeiro_bloco_do_nome(nome)
            if pb is None:
                nunca.setdefault(nome, n)
            elif pb > n:
                spoiler_nome.append(f"bloco {n}: {tipo} **{nome}** só aparece no texto no bloco {pb}")

        for campo, txt in (("resumo_ate_aqui", r_ate), ("resumo_do_bloco", r_bl)):
            for nome in nomes_no_texto(txt):
                if nome in ("Dom",):
                    continue
                pb = primeiro_bloco_do_nome(nome)
                if pb is not None and pb > n:
                    spoiler_nome.append(f"bloco {n}: **{nome}** citado em {campo}, só aparece no texto no bloco {pb}")

        memoria = " ".join([r_ate, r_bl] + [p.get("quem_e_ate_aqui", "") or "" for p in pers])
        vistos = set()
        for w in palavras(memoria):
            if len(w) < 6 or w in STOP or w in vistos:
                continue
            vistos.add(w)
            pb = primeira.get(w)
            if pb is not None and pb > n:
                futuro.append((n, w, pb))

    sorteio = sorted(random.Random(SORTEIO_SEMENTE).sample(range(1, TOTAL + 1), 10))

    nome_ia = caminho.stem
    linhas = [f"# Relatório: {nome_ia}", "",
              f"- Blocos recebidos: {len(por_bloco)} de {TOTAL}",
              f"- Faltando: {faltando or 'nenhum'}",
              f"- Repetidos (valeu a última versão): {sorted(set(repetidos)) or 'nenhum'}",
              "", f"## 1. Spoiler de nome ({len(spoiler_nome)})", ""]
    linhas += [f"- {s}" for s in spoiler_nome] or ["Nenhum."]
    linhas += ["", f"## 2. Palavras do futuro ({len(futuro)}, revisar à mão)", "",
               "Palavra usada na memória do bloco N que só aparece no texto depois. "
               "Muitas são vocabulário comum da IA; procure as que entregam enredo.", ""]
    linhas += [f"- bloco {n}: `{w}` (no texto só a partir do bloco {pb})" for n, w, pb in futuro] or ["Nenhuma."]
    linhas += ["", f"## 3. Nomes que não aparecem no livro ({len(nunca)})", "",
               "Pode ser grafia moderna (o texto é de 1899) ou invenção. Conferir.", ""]
    linhas += [f"- {k} (primeiro uso no bloco {v})" for k, v in nunca.items()] or ["Nenhum."]
    linhas += ["", f"## 4. Limites estourados ({len(limites)})", ""]
    linhas += [f"- {l}" for l in limites] or ["Nenhum."]
    linhas += ["", "## 5. Blocos sorteados para conferir fatos", "",
               f"Os mesmos para as duas IAs: {', '.join(map(str, sorteio))}.", ""]
    for n in sorteio:
        b = blocos[n - 1]
        it = por_bloco.get(n, {})
        linhas += [f"### Bloco {n} (capítulos {b['capitulos'][0]} a {b['capitulos'][-1]})", "",
                   f"**Resumo do bloco:** {it.get('resumo_do_bloco', '(faltando)')}", "",
                   "Fatos corretos? ( ) sim ( ) com erro: ____", ""]

    saida = caminho.with_name(f"{nome_ia}-relatorio.md")
    saida.write_text("\n".join(linhas), encoding="utf-8")
    print(f"{nome_ia}: {len(por_bloco)}/{TOTAL} blocos, {len(spoiler_nome)} spoilers de nome, "
          f"{len(futuro)} palavras do futuro, {len(nunca)} nomes fora do livro")
    print(f"Relatório: {saida}")


if __name__ == "__main__":
    main()
