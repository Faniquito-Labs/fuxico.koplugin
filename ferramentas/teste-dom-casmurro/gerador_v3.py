"""Simula o gerador do Bulhufas no modo "aos poucos" (prompt v3.1).

Fica na mesma pasta que checar.py (na pasta do teste: scripts/). A IA é quem
responde cada pedido; este script só monta os pedidos, checa e junta as respostas.

Uso (sempre com PYTHONIOENCODING=utf-8 python -I):
  scripts/gerador_v3.py pedido N      monta v3/pedidos/bloco-NN.txt a partir de v3/memoria.json
  scripts/gerador_v3.py checar N      checa v3/respostas/bloco-NN.json; se falhar (saída 3), grava
                                      v3/correcoes/bloco-NN.txt (pedido de correção) e guarda
                                      a resposta original em v3/respostas/bloco-NN-original.json
  scripts/gerador_v3.py incorporar N  incorpora a resposta em v3/memoria.json (e registra em v3/log.json)
  scripts/gerador_v3.py final         gera respostas/claude-v3.txt (formato antigo) e estatísticas

O prompt é lido de prompts/memoria-aos-poucos.md do repositório: o do repositório
em que o script está ou, se ele foi copiado para a pasta do teste, o de uma pasta
irmã bulhufas.koplugin (ou a indicada em BULHUFAS_REPO).
"""
import importlib.util, json, os, re, shutil, sys
from datetime import date
from pathlib import Path

AQUI = Path(__file__).resolve().parent
BASE = AQUI.parent  # pasta do teste: blocos.json, respostas/, v3/


def achar_prompt():
    candidatos = []
    if os.environ.get("BULHUFAS_REPO"):
        candidatos.append(Path(os.environ["BULHUFAS_REPO"]))
    candidatos += [AQUI.parent.parent, BASE.parent / "bulhufas.koplugin"]
    for repo in candidatos:
        p = repo / "prompts" / "memoria-aos-poucos.md"
        if p.exists():
            return p
    sys.exit("não achei prompts/memoria-aos-poucos.md; defina BULHUFAS_REPO")


PROMPT_MD = achar_prompt()
V3 = BASE / "v3"
MEMORIA = V3 / "memoria.json"
LOG = V3 / "log.json"
LIM_ATE, LIM_BLOCO, LIM_FICHA, LIM_PRESENTES, LIM_LISTA = 150, 50, 30, 10, 30

# reaproveita a lógica de nomes do checar.py (o main dele não roda no import)
_spec = importlib.util.spec_from_file_location("checar", AQUI / "checar.py")
checar = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(checar)
BLOCOS = checar.blocos
TOTAL = len(BLOCOS)


def nn(n):
    return f"{int(n):02d}"


def partes_do_prompt():
    md = PROMPT_MD.read_text(encoding="utf-8")
    cods = re.findall(r"```\n(.*?)```", md, re.S)
    instr = next(c for c in cods if c.startswith("Você escreve"))
    pedido = next(c for c in cods if c.startswith("BLOCO {{n}}"))
    correcao = next(c for c in cods if c.startswith("A resposta precisa"))
    return instr.strip(), pedido.strip(), correcao.strip()


def ler_json(p, padrao=None):
    return json.loads(p.read_text(encoding="utf-8")) if p.exists() else padrao


def gravar_json(p, obj):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(obj, ensure_ascii=False, indent=2), encoding="utf-8")


def memoria_vazia():
    return {
        "formato": 1,
        "livro": {"titulo": "Dom Casmurro", "autor": "Machado de Assis", "idioma": "pt-BR",
                  "isbn": None, "chave": None, "impressoes": []},
        "geracao": {"modo": "nuvem", "servico": "claude", "modelo": "claude-opus-5-5",
                    "prompt": "v3.1", "data": date.today().isoformat()},
        "blocos": [],
        "personagens": [],
    }


def carregar_memoria():
    return ler_json(MEMORIA) or memoria_vazia()


def nps(s):
    return len((s or "").split())


def ultima_ficha(p, ate=None):
    fs = [f for f in p["fichas"] if ate is None or f["bloco"] <= ate]
    return fs[-1]["quem_e_ate_aqui"] if fs else ""


def apelidos_ate(p, ate=None):
    return [a["apelido"] for a in p["apelidos"] if ate is None or a["desde_bloco"] <= ate]


def recente(p):
    return max([p["desde_bloco"]] + [f["bloco"] for f in p["fichas"]])


def lista_conhecidos(mem):
    """Até 30 com ficha (os mais recentes); os outros só com id, nome e apelidos."""
    ps = mem["personagens"]
    if not ps:
        return "(nenhum ainda)", 0
    escolhidos = set(id(p) for p in sorted(ps, key=recente, reverse=True)[:LIM_LISTA])
    linhas, outros = [], []
    for p in ps:  # mantém a ordem de entrada
        ap = ", ".join(apelidos_ate(p)) or "—"
        if id(p) in escolhidos:
            linhas.append(f"- {p['id']} | {p['nome']} | apelidos: {ap} | {ultima_ficha(p)}")
        else:
            outros.append(f"- {p['id']} | {p['nome']} | apelidos: {ap}")
    if outros:
        linhas += ["", "Outros personagens (sem ficha):"] + outros
    return "\n".join(linhas), len(outros)


def cmd_pedido(n):
    mem = carregar_memoria()
    if len(mem["blocos"]) != n - 1:
        sys.exit(f"memória tem {len(mem['blocos'])} blocos; esperado {n - 1}")
    instr, modelo, _ = partes_do_prompt()
    b = BLOCOS[n - 1]
    conhecidos, fora = lista_conhecidos(mem)
    resumo_ant = mem["blocos"][-1]["resumo_ate_aqui"] if mem["blocos"] else "(início do livro)"
    pedido = (modelo.replace("{{n}}", str(n)).replace("{{total}}", str(TOTAL))
              .replace("{{capitulo_inicial}}", b["capitulos"][0])
              .replace("{{capitulo_final}}", b["capitulos"][-1])
              .replace("{{resumo_ate_aqui_anterior}}", resumo_ant)
              .replace("{{personagens_conhecidos}}", conhecidos)
              .replace("{{texto_do_bloco}}", b["texto"].strip()))
    texto = instr + "\n\n---\n\n" + pedido + "\n"
    saida = V3 / "pedidos" / f"bloco-{nn(n)}.txt"
    saida.parent.mkdir(parents=True, exist_ok=True)
    saida.write_text(texto, encoding="utf-8")
    print(f"pedido {n}: {len(texto)} caracteres, {len(mem['personagens'])} personagens na memória"
          f"{f', {fora} sem ficha no pedido' if fora else ''} ->{saida.relative_to(BASE)}")


def ler_resposta(n):
    p = V3 / "respostas" / f"bloco-{nn(n)}.json"
    bruto = p.read_text(encoding="utf-8")
    try:
        return json.loads(bruto), None
    except json.JSONDecodeError as e:
        itens = checar.ler_respostas(p)  # tolera texto antes/depois
        if itens:
            return itens[-1], f"JSON com texto em volta ({e})"
        return None, f"JSON inválido ({e})"


def problemas(n, r, mem):
    """Devolve (problemas que pedem correção, avisos, contagens)."""
    probs, avisos = [], []
    cont = {"spoiler_nome": 0, "limites": 0, "duplicatas": 0}
    if int(r.get("bloco", -1)) != n:
        avisos.append(f'"bloco" veio como {r.get("bloco")}')
    por_id = {p["id"]: p for p in mem["personagens"]}
    nomes_exist = {}
    for p in mem["personagens"]:
        for nm in [p["nome"]] + apelidos_ate(p):
            nomes_exist.setdefault(checar.norm(nm), p["id"])

    for campo, lim in (("resumo_ate_aqui", LIM_ATE), ("resumo_do_bloco", LIM_BLOCO)):
        k = nps(r.get(campo))
        if k > lim:
            probs.append((campo, f"tem {k} palavras; o limite é {lim}"))
            cont["limites"] += 1
        if k == 0:
            probs.append((campo, "está vazio"))
    pres = r.get("presentes") or []
    if len(pres) > LIM_PRESENTES:
        probs.append(("presentes", f"tem {len(pres)} ids; o limite é {LIM_PRESENTES}"))
        cont["limites"] += 1

    novos = r.get("personagens_novos_ou_atualizados") or []
    ids_resp = set()
    for p in novos:
        pid = p.get("id", "")
        ids_resp.add(pid)
        k = nps(p.get("quem_e_ate_aqui"))
        if k > LIM_FICHA:
            probs.append((f"quem_e_ate_aqui de {pid}", f"tem {k} palavras; o limite é {LIM_FICHA}"))
            cont["limites"] += 1
        nomes = [("nome", p["nome"])] if p.get("nome") else []
        nomes += [("apelido", a) for a in (p.get("apelidos_novos") or [])]
        if pid in por_id:
            if p.get("nome") and checar.norm(p["nome"]) != checar.norm(por_id[pid]["nome"]):
                avisos.append(f'{pid} já existia e veio com outro "nome": {p["nome"]}')
            elif p.get("nome"):
                avisos.append(f'{pid} já existia e repetiu o "nome"')
            nomes = [x for x in nomes if x[0] == "apelido"]
        else:
            if not p.get("nome"):
                probs.append((f"personagens_novos_ou_atualizados ({pid})",
                              f'traz o id "{pid}", que não está na lista, sem "nome"'))
            # id novo com nome/apelido de alguém que já está na lista = duplicata
            for _, nm in nomes:
                dono = nomes_exist.get(checar.norm(nm))
                if dono and not nm[:1].isupper():
                    # descrição genérica ("uma senhora"): não prova que é a mesma pessoa
                    avisos.append(f'id novo "{pid}" com a descrição "{nm}", igual à de "{dono}" (não conta como duplicata)')
                    continue
                if dono:
                    probs.append((f"personagens_novos_ou_atualizados ({pid})",
                                  f'cria o id novo "{pid}" para "{nm}", que já está na lista como "{dono}"'))
                    cont["duplicatas"] += 1
                    break
        for tipo, nm in nomes:
            if not nm.strip():
                continue
            pb = checar.primeiro_bloco_do_nome(nm)
            if pb is None:
                probs.append((f"personagens_novos_ou_atualizados ({pid})",
                              f'traz o {tipo} "{nm}", que não aparece no texto'))
                cont["spoiler_nome"] += 1
            elif pb > n:
                probs.append((f"personagens_novos_ou_atualizados ({pid})",
                              f'cita "{nm}", que ainda não apareceu no texto'))
                cont["spoiler_nome"] += 1
    for campo in ("resumo_ate_aqui", "resumo_do_bloco"):
        for nm in checar.nomes_no_texto(r.get(campo) or ""):
            if nm == "Dom":
                continue
            pb = checar.primeiro_bloco_do_nome(nm)
            if pb is not None and pb > n:
                probs.append((campo, f'cita "{nm}", que ainda não apareceu no texto'))
                cont["spoiler_nome"] += 1
    for pid in pres:
        if pid not in por_id and pid not in ids_resp:
            probs.append(("presentes", f'traz o id "{pid}", que não está na lista nem entre os novos'))
    return probs, avisos, cont


def mensagem_correcao(probs):
    _, _, modelo = partes_do_prompt()
    vistos, linhas = set(), []
    for campo, prob in probs:
        if (campo, prob) in vistos:
            continue
        vistos.add((campo, prob))
        linhas.append(f'- o campo "{campo}" {prob}')
    return modelo.replace("{{problemas}}", "\n".join(linhas))


def cmd_checar(n):
    mem = carregar_memoria()
    r, erro = ler_resposta(n)
    if r is None:
        probs, avisos, cont = [("JSON", "não é um objeto JSON válido")], [erro], {}
    else:
        probs, avisos, cont = problemas(n, r, mem)
        if erro:
            avisos.append(erro)
    for a in avisos:
        print("aviso:", a)
    if not probs:
        print(f"bloco {n}: OK", cont)
        return
    print(f"bloco {n}: {len(probs)} problema(s)", cont)
    for c, p in probs:
        print(f"  - {c}: {p}")
    orig = V3 / "respostas" / f"bloco-{nn(n)}-original.json"
    if not orig.exists():
        shutil.copyfile(V3 / "respostas" / f"bloco-{nn(n)}.json", orig)
    msg = mensagem_correcao(probs)
    cp = V3 / "correcoes" / f"bloco-{nn(n)}.txt"
    cp.parent.mkdir(parents=True, exist_ok=True)
    cp.write_text(msg + "\n", encoding="utf-8")
    print(f"pedido de correção -> {cp.relative_to(BASE)}")
    sys.exit(3)


def cmd_incorporar(n):
    mem = carregar_memoria()
    if len(mem["blocos"]) != n - 1:
        sys.exit(f"memória tem {len(mem['blocos'])} blocos; esperado {n - 1}")
    r, erro = ler_resposta(n)
    if r is None:
        sys.exit(erro)
    probs, avisos, cont = problemas(n, r, mem)
    refeito = (V3 / "respostas" / f"bloco-{nn(n)}-original.json").exists()
    probs_orig = []
    if refeito:
        ro = json.loads((V3 / "respostas" / f"bloco-{nn(n)}-original.json").read_text(encoding="utf-8"))
        probs_orig = problemas(n, ro, mem)[0]
    b = BLOCOS[n - 1]
    mem["blocos"].append({
        "bloco": n,
        "inicio": None, "fim": None,  # posição no EPUB: o teste usa blocos.json, sem fragmentos
        "capitulos": [b["capitulos"][0], b["capitulos"][-1]],
        "resumo_ate_aqui": r.get("resumo_ate_aqui", ""),
        "resumo_do_bloco": r.get("resumo_do_bloco", ""),
        "presentes": list(r.get("presentes") or []),
        "checagem": {"spoiler_nome": cont["spoiler_nome"], "limites": cont["limites"], "refeito": refeito},
    })
    por_id = {p["id"]: p for p in mem["personagens"]}
    for p in r.get("personagens_novos_ou_atualizados") or []:
        pid = p["id"]
        alvo = por_id.get(pid)
        if alvo is None:
            alvo = {"id": pid, "nome": p.get("nome") or pid, "desde_bloco": n, "apelidos": [], "fichas": []}
            mem["personagens"].append(alvo)
            por_id[pid] = alvo
        ja = {checar.norm(a["apelido"]) for a in alvo["apelidos"]} | {checar.norm(alvo["nome"])}
        for a in p.get("apelidos_novos") or []:
            if a.strip() and checar.norm(a) not in ja:
                alvo["apelidos"].append({"apelido": a, "desde_bloco": n})
                ja.add(checar.norm(a))
        q = p.get("quem_e_ate_aqui") or ""
        if q and q != ultima_ficha(alvo):
            alvo["fichas"].append({"bloco": n, "quem_e_ate_aqui": q})
    gravar_json(MEMORIA, mem)
    log = ler_json(LOG, [])
    log = [x for x in log if x["bloco"] != n]
    pedido = V3 / "pedidos" / f"bloco-{nn(n)}.txt"
    log.append({"bloco": n, "refeito": refeito,
                "problemas_original": [f"{c}: {p}" for c, p in probs_orig],
                "problemas_final": [f"{c}: {p}" for c, p in probs],
                "avisos": avisos, "contagens": cont,
                "chars_pedido": len(pedido.read_text(encoding="utf-8")) if pedido.exists() else None,
                "novos_ou_atualizados": len(r.get("personagens_novos_ou_atualizados") or []),
                "total_personagens": len(mem["personagens"])})
    gravar_json(LOG, sorted(log, key=lambda x: x["bloco"]))
    print(f"bloco {n} incorporado: {len(mem['personagens'])} personagens, refeito={refeito}, "
          f"problemas restantes={len(probs)}")


def cmd_final():
    mem = carregar_memoria()
    por_id = {p["id"]: p for p in mem["personagens"]}
    saida = []
    for b in mem["blocos"]:
        n = b["bloco"]
        pers = []
        for pid in b["presentes"]:
            p = por_id.get(pid)
            if not p:
                continue
            pers.append({"nome": p["nome"], "apelidos": apelidos_ate(p, n),
                         "quem_e_ate_aqui": ultima_ficha(p, n)})
        saida.append({"bloco": n, "resumo_ate_aqui": b["resumo_ate_aqui"],
                      "resumo_do_bloco": b["resumo_do_bloco"], "personagens": pers})
    dest = BASE / "respostas" / "claude-v3.txt"
    dest.write_text(json.dumps(saida, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"{len(saida)} blocos -> {dest.relative_to(BASE)}")
    # estatísticas
    ate = [nps(b["resumo_ate_aqui"]) for b in mem["blocos"]]
    bl = [nps(b["resumo_do_bloco"]) for b in mem["blocos"]]
    print("resumo_ate_aqui: máx", max(ate), "média", round(sum(ate) / len(ate), 1),
          "| >120:", [b["bloco"] for b in mem["blocos"] if nps(b["resumo_ate_aqui"]) > 120],
          "| >150:", [b["bloco"] for b in mem["blocos"] if nps(b["resumo_ate_aqui"]) > 150])
    print("resumo_do_bloco: máx", max(bl), "| >50:", [b["bloco"] for b in mem["blocos"] if nps(b["resumo_do_bloco"]) > 50])
    fichas = [(p["id"], f["bloco"], nps(f["quem_e_ate_aqui"])) for p in mem["personagens"] for f in p["fichas"]]
    print("fichas >30:", [x for x in fichas if x[2] > 30])
    print("presentes >10:", [b["bloco"] for b in mem["blocos"] if len(b["presentes"]) > 10])
    print("personagens:", len(mem["personagens"]))
    log = ler_json(LOG, [])
    ch = [x["chars_pedido"] for x in log if x["chars_pedido"]]
    print("pedidos: média", round(sum(ch) / len(ch)), "mín", min(ch), "máx", max(ch))
    print("refeitos:", [x["bloco"] for x in log if x["refeito"]])


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    c = sys.argv[1]
    if c == "final":
        cmd_final()
    else:
        {"pedido": cmd_pedido, "checar": cmd_checar, "incorporar": cmd_incorporar}[c](int(sys.argv[2]))
