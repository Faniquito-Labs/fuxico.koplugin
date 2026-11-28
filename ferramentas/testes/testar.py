"""Confere a sintaxe de todos os .lua e roda os testes da lógica sem IA (fuxico/semia.lua)
e do catálogo de tradução próprio (fuxico/traducao.lua).

Precisa do pacote lupa (Lua dentro do Python):
  python3 -m venv .venv && .venv/bin/pip install lupa
  .venv/bin/python -I ferramentas/testes/testar.py

Usa Lua 5.1, a versão de linguagem do LuaJIT que o KOReader usa. As telas dependem
do KOReader e não rodam aqui: só a sintaxe delas é conferida.
"""
import pathlib
import sys

from lupa import lua51

RAIZ = pathlib.Path(__file__).resolve().parents[2]
TESTES = pathlib.Path(__file__).with_name("semia_spec.lua")
TESTES_TRADUCAO = pathlib.Path(__file__).with_name("traducao_spec.lua")
TESTES_ZEN = pathlib.Path(__file__).with_name("integracao_zen_spec.lua")


def conferir_sintaxe(lua):
    carregar = lua.eval("function(codigo, nome) local f, erro = loadstring(codigo, nome); return erro end")
    erros = []
    arquivos = [p for p in sorted(RAIZ.rglob("*.lua")) if ".venv" not in p.parts]
    for arquivo in arquivos:
        erro = carregar(arquivo.read_text(encoding="utf-8"), "@" + arquivo.relative_to(RAIZ).as_posix())
        if erro:
            erros.append(erro)
    return len(arquivos), erros


def main():
    lua = lua51.LuaRuntime(unpack_returned_tuples=True)
    total, erros = conferir_sintaxe(lua)
    print(f"sintaxe: {total} arquivos, {len(erros)} com erro")
    for e in erros:
        print("  " + e)

    lua.execute(f"package.path = {str(RAIZ) + '/?.lua'!r} .. ';' .. package.path")
    lua.globals().py_minusculo = lambda s: s.lower()
    lua.execute('package.preload["ffi/utf8proc"] = function() return { lowercase = py_minusculo } end')
    falhas = lua.execute(TESTES.read_text(encoding="utf-8"))
    falhas = list(falhas.values()) if falhas else []
    print(f"semia: {len(falhas)} falha(s)")
    for f in falhas:
        print("  " + f)

    lua.execute("""
        package.preload["logger"] = function() return { info = function() end, warn = function() end } end
        package.preload["gettext"] = function()
            return setmetatable({
                current_lang = "C",
                ngettext = function(s, p, n) if n == 1 then return s end return p end,
            }, { __call = function(_, s) return s end })
        end
    """)
    falhas_traducao = lua.execute(TESTES_TRADUCAO.read_text(encoding="utf-8"), str(RAIZ))
    falhas_traducao = list(falhas_traducao.values()) if falhas_traducao else []
    print(f"tradução: {len(falhas_traducao)} falha(s)")
    for f in falhas_traducao:
        print("  " + f)
    falhas_zen = lua.execute(TESTES_ZEN.read_text(encoding="utf-8"))
    falhas_zen = list(falhas_zen.values()) if falhas_zen else []
    print(f"integração com o Zen OS: {len(falhas_zen)} falha(s)")
    for f in falhas_zen:
        print("  " + f)
    return 1 if erros or falhas or falhas_traducao or falhas_zen else 0


if __name__ == "__main__":
    sys.exit(main())
