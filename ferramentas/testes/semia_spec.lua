local Semia = require("fuxico/semia")

local falhas = {}
local function confere(descricao, obtido, esperado)
    if obtido ~= esperado then
        table.insert(falhas, string.format("%s: esperado %s, veio %s", descricao, tostring(esperado), tostring(obtido)))
    end
end

for texto, esperado in pairs({
    ["Capitu"] = true,
    ["capitu"] = false,
    ["Então"] = false,
    ["Ele"] = false,
    ["Senhor"] = false,
    ["Eu"] = false,
    ["José Dias"] = true,
    ["Rio de Janeiro"] = true,
    ["Ezequiel de Sousa Escobar"] = true,
    ["de Janeiro"] = false,
    ["Rio de"] = false,
    ["Ângela"] = true,
    ["Élio"] = true,
    ["\226\128\156Capitu,\226\128\157"] = true,
    ["Matacavalos."] = true,
    ["cerca"] = false,
    ["Dom Casmurro"] = true,
    ["Quando ela chegou ao fim da rua"] = false,
}) do
    confere("pareceNome(" .. texto .. ")", Semia.pareceNome(texto), esperado)
end

confere("limpar com aspas", Semia.limpar("\226\128\156Capitu,\226\128\157"), "Capitu")
confere("limpar com ponto", Semia.limpar("  Capitu. "), "Capitu")
confere("limpar com travessão", Semia.limpar("\226\128\148 José Dias"), "José Dias")

confere("inicioDeFrase vazio", Semia.inicioDeFrase(""), true)
confere("inicioDeFrase ponto", Semia.inicioDeFrase("e riu. "), true)
confere("inicioDeFrase travessão", Semia.inicioDeFrase("disse \226\128\148 "), true)
confere("inicioDeFrase meio", Semia.inicioDeFrase("a filha do vizinho, a "), false)

confere("cortarAntes com ponto", Semia.cortarAntes("Ele saiu. Depois viu a "), "Depois viu a")
confere("cortarAntes sem ponto", Semia.cortarAntes("a filha do vizinho, a"), "\226\128\166a filha do vizinho, a")
confere("cortarDepois com ponto", Semia.cortarDepois(" riu e voltou. Depois saiu"), "riu e voltou.")
confere("cortarDepois sem ponto", Semia.cortarDepois(" riu e voltou"), "riu e voltou\226\128\166")

confere("ehTodaMaiuscula CAPITU", Semia.ehTodaMaiuscula("CAPITU"), true)
confere("ehTodaMaiuscula Capitu", Semia.ehTodaMaiuscula("Capitu"), false)
confere("ehTodaMaiuscula ÂNGELA", Semia.ehTodaMaiuscula("ÂNGELA"), true)

local contexto = {
    comparar = function(a, b)
        a, b = tonumber(a), tonumber(b)
        if a == b then return 0 end
        return b > a and 1 or -1
    end,
    pagina = function(xp) return tonumber(xp) * 10 end,
    capitulo = function(xp) return "Cap. " .. xp end,
    pagina_atual = 30,
    total_paginas = 101,
}
local function ocorrencia(xp, antes, texto, depois)
    return { start = xp, ["end"] = xp, prev_text = antes, matched_text = texto, next_text = depois }
end

local nome = Semia.montar(contexto, "Capitu", {
    ocorrencia("1", "Era uma vez. ", "Capitu", " riu."),
    ocorrencia("2", "a filha do vizinho, a", "Capitu", ", e isso."),
    ocorrencia("3", "olhou para", "Capitu", " sem dizer nada."),
    ocorrencia("4", "depois", "Capitu", " saiu."),
}, "3")
confere("montar total até o corte", nome.total, 3)
confere("montar atual", nome.atual, 3)
confere("montar anterior", nome.anterior and nome.anterior.xp, "2")
confere("montar primeira", nome.primeira and nome.primeira.xp, "1")
confere("montar parece nome", nome.parece_nome, true)
confere("capítulo só quando pedido", nome.primeira.capitulo, nil)
confere("montar capítulo", Semia.capitulo(nome, nome.primeira), "Cap. 1")
confere("montar frase antes", nome.mencoes[2].antes, "\226\128\166a filha do vizinho, a")
confere("montar frase depois", nome.mencoes[2].depois, ", e isso.")

local comum = Semia.montar(contexto, "Cerca", {
    ocorrencia("1", "Fim. ", "Cerca", " de dez."),
    ocorrencia("2", "voltou à", "cerca", " do quintal."),
    ocorrencia("3", "pulou a", "cerca", " outra vez."),
}, "3")
confere("palavra comum não parece nome", comum.parece_nome, false)

local titulo = Semia.montar(contexto, "Capitu", {
    ocorrencia("1", "olhou para", "CAPITU", ""),
    ocorrencia("2", "viu", "Capitu", " rir."),
}, "2")
confere("título em maiúsculas não conta", titulo.meio, 1)

confere("posicao início", Semia.posicao({ total_paginas = 101 }, 1), 0)
confere("posicao fim", Semia.posicao({ total_paginas = 101 }, 101), 1)
confere("posicao meio", Semia.posicao({ total_paginas = 101 }, 51), 0.5)

return falhas
