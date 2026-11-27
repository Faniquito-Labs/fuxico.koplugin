local Event = require("ui/event")
local UIManager = require("ui/uimanager")
local logger = require("logger")
local Screen = require("device").screen

local SAIDA = os.getenv("FUXICO_TESTE_SAIDA") or "/tmp"

local function log(...)
    logger.info("FUXICO-TESTE", ...)
    local f = io.open(SAIDA .. "/log.txt", "a")
    if f then
        local partes = {}
        for i = 1, select("#", ...) do
            table.insert(partes, tostring((select(i, ...))))
        end
        f:write(table.concat(partes, " "), "\n")
        f:close()
    end
end

local function foto(nome)
    UIManager:forceRePaint()
    local ok, err = Screen:shot(SAIDA .. "/" .. nome .. ".png")
    log("foto", nome, ok, err)
end

local function topo()
    local pilha = UIManager._window_stack
    return pilha[#pilha] and pilha[#pilha].widget
end

local passos = {}
local function passo(espera, f)
    table.insert(passos, { espera = espera, f = f })
end

local function rodar(i)
    local p = passos[i]
    if not p then
        log("fim")
        UIManager:quit()
        return
    end
    UIManager:scheduleIn(p.espera, function()
        local ok, err = xpcall(p.f, debug.traceback)
        if not ok then
            log("ERRO no passo", i, err)
        end
        rodar(i + 1)
    end)
end

local ReaderUI = require("apps/reader/readerui")
local estado = {}

local function primeiraAntesDaPagina(texto, pagina)
    local ui = ReaderUI.instance
    local doc = ui.document
    local achados = doc:findAllText(texto, false, 5, 5000, false, 0x00FF + 0x1000) or {}
    local escolhido
    for _, r in ipairs(achados) do
        if doc:getPageFromXPointer(r.start) <= pagina then
            escolhido = r
        end
    end
    log("ocorrências de", texto, #achados, "escolhida", escolhido and escolhido.start)
    return escolhido
end

passo(4, function()
    local ui = ReaderUI.instance
    log("leitor", ui ~= nil, "fuxico", ui and ui.fuxico ~= nil, "páginas", ui and ui.document:getPageCount())
    ui:handleEvent(Event:new("GotoPage", 60))
end)

passo(2, function()
    local ui = ReaderUI.instance
    estado.pagina = ui:getCurrentPage()
    log("página atual", estado.pagina)
    foto("01-pagina")
    local r = primeiraAntesDaPagina("Capitu", estado.pagina + 1)
    estado.capitu = r
    ui.highlight.selected_text = { text = "Capitu", pos0 = r.start, pos1 = r["end"] }
    local botao = ui.highlight._highlight_buttons["13_fuxico_quem_e"](ui.highlight)
    log("botão para Capitu", botao.text, botao.show_in_highlight_dialog_func())
    ui.highlight:onShowHighlightMenu()
end)

passo(2, function()
    foto("02-menu-selecao-capitu")
    local dialogo = topo()
    if dialogo and dialogo.onClose then dialogo:onClose() end
    local ui = ReaderUI.instance
    local r = primeiraAntesDaPagina("cerca", estado.pagina + 1)
    ui.highlight.selected_text = { text = "cerca", pos0 = r.start, pos1 = r["end"] }
    local botao = ui.highlight._highlight_buttons["13_fuxico_quem_e"](ui.highlight)
    log("botão para cerca", botao.show_in_highlight_dialog_func())
    ui.highlight:onShowHighlightMenu()
end)

passo(2, function()
    foto("03-menu-selecao-cerca")
    local dialogo = topo()
    if dialogo and dialogo.onClose then dialogo:onClose() end
    local ui = ReaderUI.instance
    ui.highlight.selected_text = nil
    ui.fuxico:quemE("Capitu", estado.capitu.start)
end)

passo(5, function()
    foto("04-gaveta-capitu")
    local gaveta = topo()
    log("topo depois do quemE", gaveta and gaveta.name or tostring(gaveta), gaveta and gaveta.resultado and gaveta.resultado.total)
    if gaveta and gaveta.ao_ver_todas then
        gaveta:fechar()
        gaveta.ao_ver_todas()
    end
end)

passo(3, function()
    foto("05-tela-mencoes")
    local tela = topo()
    if tela and tela.onPaginaSeguinte then tela:onPaginaSeguinte() end
end)

passo(2, function()
    foto("06-tela-mencoes-pagina-2")
    local tela = topo()
    if tela and tela.lista then
        tela.ordem = "capitulo"
        tela.pagina = 1
        tela:_ordenar()
        tela:_remontar()
    end
end)

passo(2, function()
    foto("07-tela-mencoes-por-capitulo")
    local tela = topo()
    if tela and tela.lista and tela.lista[1] then
        local mencao = tela.lista[1]
        tela:fechar()
        tela.ao_ir(mencao)
    end
end)

passo(3, function()
    local ui = ReaderUI.instance
    log("depois de ir até a menção, página", ui:getCurrentPage())
    foto("08-pulou-para-mencao")
    ui:handleEvent(Event:new("GoBackLink"))
end)

passo(2, function()
    local ui = ReaderUI.instance
    log("depois do voltar, página", ui:getCurrentPage())
    local r = primeiraAntesDaPagina("Cerca", estado.pagina + 1)
    ui.fuxico:quemE("Cerca", r.start)
end)

passo(4, function()
    foto("09-gaveta-nao-parece-nome")
    local gaveta = topo()
    if gaveta and gaveta.fechar then gaveta:fechar() end
    local ui = ReaderUI.instance
    local r
    for _, achado in ipairs(ui.document:findAllText("Escobar", false, 5, 5000, false, 0x00FF + 0x1000) or {}) do
        if achado.start:find("DocFragment%[28%]") then r = achado break end
    end
    log("primeira do Escobar no capítulo 28", r and r.start)
    ui:handleEvent(Event:new("GotoPage", ui.document:getPageFromXPointer(r.start)))
    estado.escobar = r
end)

passo(2, function()
    local ui = ReaderUI.instance
    ui.fuxico:quemE("Escobar", estado.escobar.start)
end)

passo(4, function()
    foto("10-gaveta-escobar-sumico")
    local gaveta = topo()
    if gaveta and gaveta.fechar then gaveta:fechar() end
    local ui = ReaderUI.instance
    local itens = ui.fuxico and require("fuxico/menu").itens(ui.fuxico)
    log("menu", itens and itens.text, itens and #itens.sub_item_table)
    itens.sub_item_table[2].callback()
end)

passo(2, function()
    foto("11-sobre")
    local janela = topo()
    if janela and janela.onClose then janela:onClose() end
end)

if os.getenv("FUXICO_TESTE_SAIDA") then
    rodar(1)
end
