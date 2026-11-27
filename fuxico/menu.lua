local InfoMessage = require("ui/widget/infomessage")
local SpinWidget = require("ui/widget/spinwidget")
local UIManager = require("ui/uimanager")
local T = require("ffi/util").template
local _ = require("fuxico/traducao")
local N_ = _.ngettext

local Configuracoes = require("fuxico/configuracoes")

local REPOSITORIO = "https://github.com/Faniquito-Labs/fuxico.koplugin"

local Menu = {}

local function caixa(texto, chave)
    return {
        text = texto,
        checked_func = function() return Configuracoes:ler(chave) end,
        callback = function() Configuracoes:alternar(chave) end,
    }
end

local function versao(plugin)
    local ok, meta = pcall(dofile, plugin.path .. "/_meta.lua")
    return ok and meta and meta.version or "?"
end

function Menu.itens(plugin)
    return {
        text = _("Fuxico"),
        sorting_hint = "tools",
        sub_item_table = {
            {
                text = _("Who is this?"),
                sub_item_table = {
                    caixa(_("Only on proper names"), "so_nomes_proprios"),
                    {
                        text_func = function()
                            local paginas = Configuracoes:ler("aviso_sumico_paginas")
                            return T(N_("Warn when missing for: 1 page", "Warn when missing for: %1 pages", paginas), paginas)
                        end,
                        keep_menu_open = true,
                        callback = function(touchmenu_instance)
                            UIManager:show(SpinWidget:new{
                                title_text = _("Pages without mentions before the warning"),
                                value = Configuracoes:ler("aviso_sumico_paginas"),
                                value_min = 5,
                                value_max = 300,
                                value_step = 5,
                                value_hold_step = 25,
                                default_value = Configuracoes:padrao("aviso_sumico_paginas"),
                                callback = function(spin)
                                    Configuracoes:gravar("aviso_sumico_paginas", spin.value)
                                    if touchmenu_instance then
                                        touchmenu_instance:updateItems()
                                    end
                                end,
                            })
                        end,
                    },
                    caixa(_("Show the timeline thumbnail"), "mostrar_miniatura"),
                    caixa(_("Open the full screen directly"), "abrir_tela_completa"),
                },
            },
            {
                text = _("About and privacy"),
                keep_menu_open = true,
                callback = function()
                    UIManager:show(InfoMessage:new{
                        text = T(_([[Fuxico %1

"Who is this?" only searches the book on this device. No text from the book leaves your e-reader.

%2]]), versao(plugin), REPOSITORIO),
                    })
                end,
            },
        },
    }
end

return Menu
