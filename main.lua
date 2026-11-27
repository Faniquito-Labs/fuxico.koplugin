local InfoMessage = require("ui/widget/infomessage")
local Trapper = require("ui/trapper")
local UIManager = require("ui/uimanager")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local util = require("util")
local _ = require("fuxico/traducao")

local Configuracoes = require("fuxico/configuracoes")
local GavetaQuemE = require("fuxico/telas/gaveta_quem_e")
local Menu = require("fuxico/menu")
local Semia = require("fuxico/semia")
local TelaMencoes = require("fuxico/telas/tela_mencoes")

local Fuxico = WidgetContainer:extend{
    name = "fuxico",
    is_doc_only = true,
}

function Fuxico:init()
    self.ui.menu:registerToMainMenu(self)
    if self.ui.highlight then
        self.ui.highlight:addToHighlightDialog("13_fuxico_quem_e", function(destaque)
            return self:_botaoQuemE(destaque)
        end)
    end
    if self.ui.dictionary and self.ui.dictionary.addToDictButtons then
        self.ui.dictionary:addToDictButtons(self:_botaoDicionario())
    end
end

function Fuxico:addToMainMenu(menu_items)
    menu_items.fuxico = Menu.itens(self)
end

function Fuxico:_disponivel()
    return self.ui.rolling ~= nil and self.ui.document ~= nil
end

function Fuxico:_botaoQuemE(destaque)
    return {
        text = _("Who is this?"),
        show_in_highlight_dialog_func = function()
            return destaque.selected_text ~= nil and self:_mostrarBotao(destaque.selected_text.text)
        end,
        callback = function()
            local texto = util.cleanupSelectedText(destaque.selected_text.text)
            local corte = destaque.selected_text.pos0
            destaque:onClose()
            self:quemE(texto, corte)
        end,
    }
end

function Fuxico:_mostrarBotao(texto)
    if not self:_disponivel() or not texto or texto == "" then
        return false
    end
    if not Configuracoes:ler("so_nomes_proprios") then
        return true
    end
    return Semia.pareceNome(texto)
end

function Fuxico:_botaoDicionario()
    return {
        id = "fuxico_quem_e",
        text = _("Who is this?"),
        conditional = true,
        show_func = function(janela)
            return not janela.is_wiki and self:_mostrarBotao(janela.word)
        end,
        callback = function(janela)
            local texto = util.cleanupSelectedText(janela.word)
            local selecao = janela.highlight and janela.highlight.selected_text
            local corte = selecao and selecao.pos0 or self.ui.document:getXPointer()
            janela:onClose()
            self:quemE(texto, corte)
        end,
    }
end

function Fuxico:quemE(texto, corte, forcar)
    Trapper:wrap(function()
        local documento = self.ui.document
        local completo, resultados = Trapper:dismissableRunInSubprocess(function()
            return Semia.buscarNoLivro(documento, texto)
        end, _("Looking for mentions… (tap to cancel)"))
        if not completo then
            return
        end
        local resultado = Semia.montar(self:_contexto(), texto, resultados, corte)
        if resultado.total == 0 then
            UIManager:show(InfoMessage:new{ text = _("No mentions found up to this point.") })
            return
        end
        if Configuracoes:ler("abrir_tela_completa") and (resultado.parece_nome or forcar or not Configuracoes:ler("so_nomes_proprios")) then
            self:_mostrarTela(resultado)
        else
            self:_mostrarGaveta(resultado, texto, corte, forcar)
        end
    end)
end

function Fuxico:_contexto()
    local documento = self.ui.document
    local toc = self.ui.toc
    return {
        comparar = function(a, b) return documento:compareXPointers(a, b) end,
        pagina = function(xp) return documento:getPageFromXPointer(xp) end,
        capitulo = function(xp) return toc and toc:getTocTitleByPage(xp) or "" end,
        pagina_atual = self.ui:getCurrentPage(),
        total_paginas = documento:getPageCount(),
    }
end

function Fuxico:_mostrarGaveta(resultado, texto, corte, forcar)
    UIManager:show(GavetaQuemE:new{
        resultado = resultado,
        forcar = forcar,
        ao_ir = function(mencao) self:_irPara(mencao) end,
        ao_ver_todas = function() self:_mostrarTela(resultado) end,
        ao_dicionario = function() self.ui.dictionary:onLookupWord(texto) end,
        ao_buscar = function() self.ui.search:onShowFulltextSearchInput(texto) end,
        ao_mostrar_mesmo_assim = function() self:_mostrarGaveta(resultado, texto, corte, true) end,
    })
end

function Fuxico:_mostrarTela(resultado)
    UIManager:show(TelaMencoes:new{
        resultado = resultado,
        ao_ir = function(mencao) self:_irPara(mencao) end,
    })
end

function Fuxico:_irPara(mencao)
    self.ui.link:addCurrentLocationToStack()
    self.ui.rolling:onGotoXPointer(mencao.xp, mencao.xp)
end

return Fuxico
