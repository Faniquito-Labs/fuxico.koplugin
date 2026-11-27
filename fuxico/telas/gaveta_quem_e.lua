local BottomContainer = require("ui/widget/container/bottomcontainer")
local Button = require("ui/widget/button")
local ButtonTable = require("ui/widget/buttontable")
local CenterContainer = require("ui/widget/container/centercontainer")
local Device = require("device")
local FrameContainer = require("ui/widget/container/framecontainer")
local Geom = require("ui/geometry")
local GestureRange = require("ui/gesturerange")
local InputContainer = require("ui/widget/container/inputcontainer")
local LineWidget = require("ui/widget/linewidget")
local TextBoxWidget = require("ui/widget/textboxwidget")
local TextWidget = require("ui/widget/textwidget")
local UIManager = require("ui/uimanager")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local Screen = Device.screen
local T = require("ffi/util").template
local _ = require("gettext")
local N_ = _.ngettext

local Cartao = require("fuxico/componentes/cartao")
local Configuracoes = require("fuxico/configuracoes")
local Estilo = require("fuxico/componentes/estilo")
local LinhaDoTempo = require("fuxico/componentes/linha_do_tempo")
local Semia = require("fuxico/semia")

local GavetaQuemE = InputContainer:extend{
    resultado = nil,
    forcar = false,
    ao_ir = nil,
    ao_ver_todas = nil,
    ao_dicionario = nil,
    ao_buscar = nil,
    ao_mostrar_mesmo_assim = nil,
}

local function rotulo(texto, largura)
    return TextWidget:new{
        text = texto,
        face = Estilo.pequeno(),
        fgcolor = Estilo.cinza_escuro,
        bold = true,
        max_width = largura,
    }
end

local function linhaPequena(texto, largura)
    return TextBoxWidget:new{
        text = texto,
        face = Estilo.pequeno(),
        fgcolor = Estilo.cinza_escuro,
        width = largura,
    }
end

local function espaco(altura)
    return VerticalSpan:new{ width = altura or Estilo.espaco }
end

function GavetaQuemE.distancia(paginas)
    if paginas <= 0 then
        return _("on this page")
    end
    return T(N_("1 page ago", "%1 pages ago", paginas), paginas)
end

function GavetaQuemE.ondeEsta(resultado, mencao)
    local capitulo = Semia.capitulo(resultado, mencao)
    if capitulo ~= "" then
        return capitulo
    end
    return T(_("page %1"), mencao.pagina)
end

function GavetaQuemE:init()
    self.largura_tela = Screen:getWidth()
    self.altura_tela = Screen:getHeight()
    local largura = self.largura_tela
    local interno = largura - 2 * (Estilo.borda_forte + Estilo.margem)

    local conteudo = VerticalGroup:new{ align = "left" }
    table.insert(conteudo, CenterContainer:new{
        dimen = Geom:new{ w = interno, h = Screen:scaleBySize(12) },
        LineWidget:new{ dimen = Geom:new{ w = Screen:scaleBySize(36), h = Screen:scaleBySize(4) } },
    })
    table.insert(conteudo, TextWidget:new{
        text = self.resultado.nome,
        face = Estilo.titulo(),
        bold = true,
        max_width = interno,
    })

    local so_nomes = Configuracoes:ler("so_nomes_proprios")
    if so_nomes and not self.forcar and not self.resultado.parece_nome then
        self:_montarNaoPareceNome(conteudo, interno)
    else
        self:_montarMencoes(conteudo, interno)
    end

    self.gaveta = FrameContainer:new{
        bordersize = Estilo.borda_forte,
        radius = Estilo.raio_gaveta,
        padding = Estilo.margem,
        margin = 0,
        background = Estilo.branco,
        conteudo,
    }
    self[1] = BottomContainer:new{
        dimen = Geom:new{ x = 0, y = 0, w = self.largura_tela, h = self.altura_tela },
        self.gaveta,
    }

    local tela_inteira = Geom:new{ x = 0, y = 0, w = self.largura_tela, h = self.altura_tela }
    self.ges_events = {
        TocarFora = { GestureRange:new{ ges = "tap", range = tela_inteira } },
        SegurarFora = { GestureRange:new{ ges = "hold", range = tela_inteira } },
        Arrastar = { GestureRange:new{ ges = "swipe", range = tela_inteira } },
    }
    if Device:hasKeys() then
        self.key_events = { Fechar = { { Device.input.group.Back } } }
    end
end

function GavetaQuemE:_montarNaoPareceNome(conteudo, interno)
    table.insert(conteudo, espaco())
    table.insert(conteudo, TextBoxWidget:new{
        text = _("Doesn't look like a name"),
        face = Estilo.texto(),
        bold = true,
        width = interno,
    })
    table.insert(conteudo, espaco(Estilo.espaco_pequeno))
    table.insert(conteudo, linhaPequena(_("In the middle of sentences, this word usually appears in lowercase, so it's probably not a name."), interno))
    table.insert(conteudo, espaco())
    table.insert(conteudo, ButtonTable:new{
        width = interno,
        show_parent = self,
        buttons = {
            {
                { text = _("Dictionary"), callback = function() self:fechar(); self.ao_dicionario() end },
                { text = _("Search"), callback = function() self:fechar(); self.ao_buscar() end },
            },
            {
                { text = _("Show anyway"), callback = function() self:fechar(); self.ao_mostrar_mesmo_assim() end },
            },
        },
    })
end

function GavetaQuemE:_montarMencoes(conteudo, interno)
    local r = self.resultado
    local partes = { T(N_("1 mention", "%1 mentions", r.total), r.total) }
    if r.primeira and Semia.capitulo(r, r.primeira) ~= "" then
        table.insert(partes, T(_("since %1"), Semia.capitulo(r, r.primeira)))
    end
    if r.pagina_atual then
        table.insert(partes, T(_("up to page %1"), r.pagina_atual))
    end
    table.insert(conteudo, linhaPequena(table.concat(partes, " · "), interno))

    local anterior = r.anterior
    local sumico = anterior and r.atual and r.pagina_atual and (r.pagina_atual - anterior.pagina)
    if sumico and sumico >= Configuracoes:ler("aviso_sumico_paginas") then
        table.insert(conteudo, espaco())
        table.insert(conteudo, FrameContainer:new{
            bordersize = 0,
            radius = Estilo.raio_cartao,
            padding = Estilo.espaco,
            background = Estilo.preto,
            TextBoxWidget:new{
                text = T(_("Missing for %1 pages. Last time: %2."), sumico, GavetaQuemE.ondeEsta(r, anterior)),
                face = Estilo.texto(),
                fgcolor = Estilo.branco,
                bgcolor = Estilo.preto,
                width = interno - 2 * Estilo.espaco,
            },
        })
    end

    if Configuracoes:ler("mostrar_miniatura") and r.total > 0 then
        local posicoes = {}
        for __, m in ipairs(r.mencoes) do
            table.insert(posicoes, Semia.posicao(r, m.pagina))
        end
        table.insert(conteudo, espaco())
        table.insert(conteudo, LinhaDoTempo:new{
            largura = interno,
            posicoes = posicoes,
            atual = Semia.posicao(r, r.pagina_atual),
        })
    end

    table.insert(conteudo, espaco())
    if anterior then
        table.insert(conteudo, rotulo(_("Before this one, the last time"), interno))
        table.insert(conteudo, espaco(Estilo.espaco_pequeno))
        table.insert(conteudo, self:_cartao(anterior, interno, true,
            GavetaQuemE.distancia((r.pagina_atual or anterior.pagina) - anterior.pagina)))
    else
        table.insert(conteudo, linhaPequena(_("This is the first mention."), interno))
    end

    if r.primeira and r.primeira ~= anterior and r.primeira ~= r.mencoes[r.atual or 0] then
        table.insert(conteudo, espaco())
        table.insert(conteudo, rotulo(_("First appearance"), interno))
        table.insert(conteudo, espaco(Estilo.espaco_pequeno))
        table.insert(conteudo, self:_cartao(r.primeira, interno, false, T(_("page %1"), r.primeira.pagina)))
    end

    if r.total > 1 then
        table.insert(conteudo, espaco())
        table.insert(conteudo, Button:new{
            text = T(N_("See the mention", "See all %1 mentions", r.total), r.total),
            width = interno,
            radius = Estilo.raio_pilula,
            bordersize = Estilo.borda_forte,
            text_font_bold = false,
            show_parent = self,
            callback = function()
                self:fechar()
                self.ao_ver_todas()
            end,
        })
    end
end

function GavetaQuemE:_cartao(mencao, interno, forte, direita)
    return Cartao:new{
        largura = interno,
        antes = mencao.antes,
        nome = mencao.trecho,
        depois = mencao.depois,
        rodape_esquerda = Semia.capitulo(self.resultado, mencao) ~= "" and mencao.capitulo or nil,
        rodape_direita = direita,
        forte = forte,
        ao_tocar = function()
            self:fechar()
            self.ao_ir(mencao)
        end,
    }
end

function GavetaQuemE:_areaGaveta()
    return self[1]:contentRange()
end

function GavetaQuemE:onShow()
    UIManager:setDirty(self, function()
        return "ui", self:_areaGaveta()
    end)
end

function GavetaQuemE:onCloseWidget()
    local area = self:_areaGaveta()
    UIManager:setDirty(nil, function()
        return "flashui", area
    end)
end

function GavetaQuemE:fechar()
    UIManager:close(self)
end

function GavetaQuemE:onTocarFora(arg, ges)
    if ges.pos:notIntersectWith(self:_areaGaveta()) then
        self:fechar()
    end
    return true
end

function GavetaQuemE:onSegurarFora()
    return true
end

function GavetaQuemE:onArrastar(arg, ges)
    if ges.direction == "south" then
        self:fechar()
    end
    return true
end

function GavetaQuemE:onFechar()
    self:fechar()
    return true
end

return GavetaQuemE
