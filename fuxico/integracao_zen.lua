--[[
Integração com o Zen OS (xZenLabs/zen-os).

O Zen OS redesenha o dicionário e o menu de seleção. Os botões de plugins que ele não
conhece só aparecem com "Mostrar outros itens" ligado, e no menu de seleção ficam atrás
do botão "Mais" (⋮). Os plugins que ele conhece (X-Ray, KOAssistant, AI Assistant)
aparecem logo embaixo dos ícones.

O Zen OS decide quem é conhecido em modules/reader/lookup_plugin_items.lua, pelas funções
settingForHighlightKey e settingForDictButton. Aqui o Fuxico embrulha essas duas funções
para responder "show_fuxico" quando o item é o "Quem é esse?". Com isso:
- o botão aparece embaixo dos ícones nos dois lugares, sem precisar de "Mostrar outros itens";
- se o Zen OS um dia tiver a opção show_fuxico em highlight_lookup, ela passa a valer.

Só os itens do Fuxico mudam: para todo o resto as funções originais respondem como antes.
Se o Zen OS não estiver instalado ou mudar esse módulo, nada acontece.
]]

local M = {}

M.MODULO = "modules/reader/lookup_plugin_items"
M.AJUSTE = "show_fuxico"
M.ID = "fuxico_quem_e"

local function eDoFuxico(nome)
    return type(nome) == "string" and (nome:match("^%d+_(.*)$") or nome) == M.ID
end

-- Devolve true se aplicou agora ou já estava aplicada.
function M.aplicar(modulo)
    modulo = modulo or package.loaded[M.MODULO]
    if type(modulo) ~= "table" then
        return false
    end
    if modulo._fuxico_integrado then
        return true
    end
    local original_destaque = modulo.settingForHighlightKey
    local original_dicionario = modulo.settingForDictButton
    if type(original_destaque) ~= "function" or type(original_dicionario) ~= "function" then
        return false
    end

    modulo.settingForHighlightKey = function(chave, ...)
        if eDoFuxico(chave) then
            return M.AJUSTE
        end
        return original_destaque(chave, ...)
    end
    modulo.settingForDictButton = function(botao, ...)
        if type(botao) == "table" and eDoFuxico(botao.id) then
            return M.AJUSTE
        end
        return original_dicionario(botao, ...)
    end
    modulo._fuxico_integrado = true
    return true
end

return M
