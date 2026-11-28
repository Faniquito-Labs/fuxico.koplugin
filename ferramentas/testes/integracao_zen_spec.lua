local falhas = {}

local function igual(nome, obtido, esperado)
    if obtido ~= esperado then
        table.insert(falhas, string.format("%s: esperado %q, veio %q", nome, tostring(esperado), tostring(obtido)))
    end
end

local Integracao = require("fuxico/integracao_zen")

-- Imita o lookup_plugin_items.lua do Zen OS.
local function moduloFalso()
    return {
        settingForHighlightKey = function(chave)
            local nome = chave:match("^%d+_(.*)$") or chave
            if nome == "xray_lookup" then return "show_xray" end
        end,
        settingForDictButton = function(botao)
            if botao.id == "xray_lookup" then return "show_xray" end
        end,
    }
end

igual("sem Zen OS não faz nada", Integracao.aplicar(nil), false)
igual("módulo diferente não é mexido", Integracao.aplicar({ outra = true }), false)

local zen = moduloFalso()
igual("aplica", Integracao.aplicar(zen), true)
igual("destaque do Fuxico", zen.settingForHighlightKey("13_fuxico_quem_e"), "show_fuxico")
igual("destaque sem número", zen.settingForHighlightKey("fuxico_quem_e"), "show_fuxico")
igual("dicionário do Fuxico", zen.settingForDictButton({ id = "fuxico_quem_e" }), "show_fuxico")
igual("X-Ray continua igual (destaque)", zen.settingForHighlightKey("12_xray_lookup"), "show_xray")
igual("X-Ray continua igual (dicionário)", zen.settingForDictButton({ id = "xray_lookup" }), "show_xray")
igual("outro plugin continua desconhecido", zen.settingForHighlightKey("20_outro"), nil)
igual("botão sem id", zen.settingForDictButton({ text = "Algo" }), nil)

local embrulho = zen.settingForHighlightKey
igual("aplicar de novo não embrulha duas vezes", Integracao.aplicar(zen), true)
igual("mesma função depois da segunda vez", zen.settingForHighlightKey, embrulho)

return falhas
