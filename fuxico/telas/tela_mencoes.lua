local Button = require("ui/widget/button")
local Device = require("device")
local FrameContainer = require("ui/widget/container/framecontainer")
local Geom = require("ui/geometry")
local GestureRange = require("ui/gesturerange")
local HorizontalGroup = require("ui/widget/horizontalgroup")
local HorizontalSpan = require("ui/widget/horizontalspan")
local InputContainer = require("ui/widget/container/inputcontainer")
local OverlapGroup = require("ui/widget/overlapgroup")
local TextWidget = require("ui/widget/textwidget")
local TitleBar = require("ui/widget/titlebar")
local UIManager = require("ui/uimanager")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local Screen = Device.screen
local T = require("ffi/util").template
local _ = require("fuxico/traducao")
local N_ = _.ngettext

local Cartao = require("fuxico/componentes/cartao")
local Estilo = require("fuxico/componentes/estilo")
local GavetaQuemE = require("fuxico/telas/gaveta_quem_e")
local LinhaDoTempo = require("fuxico/componentes/linha_do_tempo")
local Semia = require("fuxico/semia")

local MAX_LINHAS = 4

local TelaMencoes = InputContainer:extend{
    resultado = nil,
    ordem = "recentes",
    pagina = 1,
    ao_ir = nil,
}

function TelaMencoes:init()
    self.largura = Screen:getWidth()
    self.altura = Screen:getHeight()
    self.interno = self.largura - 2 * Estilo.margem
    self.dimen = Geom:new{ x = 0, y = 0, w = self.largura, h = self.altura }
    self.ges_events = {
        Arrastar = { GestureRange:new{ ges = "swipe", range = self.dimen } },
    }
    if Device:hasKeys() then
        self.key_events = {
            Fechar = { { Device.input.group.Back } },
            PaginaSeguinte = { { Device.input.group.PgFwd } },
            PaginaAnterior = { { Device.input.group.PgBack } },
        }
    end
    self:_ordenar()
    self:_montar()
end

function TelaMencoes:_ordenar()
    local lista = {}
    for i, m in ipairs(self.resultado.mencoes) do
        if i ~= self.resultado.atual then
            table.insert(lista, m)
        end
    end
    if self.ordem == "recentes" then
        local invertida = {}
        for i = #lista, 1, -1 do
            table.insert(invertida, lista[i])
        end
        lista = invertida
    end
    self.lista = lista
    self.inicios = { 1 }
    self.pagina = 1
end

function TelaMencoes:_cabecalho()
    local r = self.resultado
    local subtitulo = T(N_("1 mention", "%1 mentions", r.total), r.total)
    if r.pagina_atual then
        subtitulo = subtitulo .. " · " .. T(_("up to page %1"), r.pagina_atual)
    end
    return TitleBar:new{
        width = self.largura,
        fullscreen = true,
        with_bottom_line = true,
        title = r.nome,
        subtitle = subtitulo,
        close_callback = function() self:fechar() end,
        show_parent = self,
    }
end

function TelaMencoes:_linhaDoTempo()
    local r = self.resultado
    local posicoes = {}
    for _i, m in ipairs(r.mencoes) do
        table.insert(posicoes, Semia.posicao(r, m.pagina))
    end
    local atual = Semia.posicao(r, r.pagina_atual)
    local legenda_esq = TextWidget:new{ text = _("start"), face = Estilo.pequeno(), fgcolor = Estilo.cinza_escuro }
    local legenda_meio = TextWidget:new{
        text = T(_("you are here · %1%"), math.floor(atual * 100 + 0.5)),
        face = Estilo.pequeno(),
        fgcolor = Estilo.cinza_escuro,
        overlap_align = "center",
    }
    local legenda_dir = TextWidget:new{ text = _("end"), face = Estilo.pequeno(), fgcolor = Estilo.cinza_escuro, overlap_align = "right" }
    return VerticalGroup:new{
        align = "left",
        LinhaDoTempo:new{ largura = self.interno, altura = Screen:scaleBySize(24), posicoes = posicoes, atual = atual },
        VerticalSpan:new{ width = Estilo.espaco_pequeno },
        OverlapGroup:new{
            dimen = Geom:new{ w = self.interno, h = legenda_esq:getSize().h },
            allow_mirroring = false,
            legenda_esq,
            legenda_meio,
            legenda_dir,
        },
    }
end

function TelaMencoes:_pilula(texto, ordem)
    local selecionada = self.ordem == ordem
    return Button:new{
        text = texto,
        radius = Estilo.raio_pilula,
        bordersize = selecionada and Estilo.borda_forte or Estilo.borda_fina,
        text_font_bold = selecionada,
        text_font_size = 18,
        padding_h = Estilo.espaco * 2,
        show_parent = self,
        callback = function()
            if self.ordem ~= ordem then
                self.ordem = ordem
                self:_ordenar()
                self:_remontar()
            end
        end,
    }
end

function TelaMencoes:_cartao(mencao)
    local distancia = (self.resultado.pagina_atual or mencao.pagina) - mencao.pagina
    return Cartao:new{
        largura = self.interno,
        antes = mencao.antes,
        nome = mencao.trecho,
        depois = mencao.depois,
        rodape_esquerda = GavetaQuemE.ondeEsta(self.resultado, mencao),
        rodape_direita = GavetaQuemE.distancia(distancia),
        max_linhas = MAX_LINHAS,
        ao_tocar = function()
            self:fechar()
            self.ao_ir(mencao)
        end,
    }
end

function TelaMencoes:_montar()
    local topo = VerticalGroup:new{
        align = "left",
        VerticalSpan:new{ width = Estilo.espaco },
        self:_linhaDoTempo(),
        VerticalSpan:new{ width = Estilo.espaco },
        HorizontalGroup:new{
            self:_pilula(_("Recent"), "recentes"),
            HorizontalSpan:new{ width = Estilo.espaco },
            self:_pilula(_("By chapter"), "capitulo"),
        },
        VerticalSpan:new{ width = Estilo.espaco },
    }
    local cabecalho = self:_cabecalho()
    local rodape_altura = Screen:scaleBySize(48)
    local livre = self.altura - cabecalho:getSize().h - topo:getSize().h - rodape_altura - Estilo.margem

    local cartoes = VerticalGroup:new{ align = "left" }
    local inicio = self.inicios[self.pagina] or 1
    local ocupado = 0
    self.primeiro_da_pagina, self.ultimo_da_pagina = inicio, inicio - 1
    for i = inicio, #self.lista do
        local cartao = self:_cartao(self.lista[i])
        local altura = cartao:getSize().h + Estilo.espaco
        if ocupado + altura > livre and i > inicio then
            cartao:free()
            break
        end
        table.insert(cartoes, cartao)
        table.insert(cartoes, VerticalSpan:new{ width = Estilo.espaco })
        ocupado = ocupado + altura
        self.ultimo_da_pagina = i
    end
    if self.ultimo_da_pagina < #self.lista then
        self.inicios[self.pagina + 1] = self.ultimo_da_pagina + 1
    end
    if #self.lista == 0 then
        table.insert(cartoes, TextWidget:new{ text = _("This is the first mention."), face = Estilo.texto() })
    end

    local corpo = FrameContainer:new{
        bordersize = 0,
        padding = 0,
        padding_left = Estilo.margem,
        padding_right = Estilo.margem,
        VerticalGroup:new{
            align = "left",
            topo,
            cartoes,
        },
    }

    self[1] = FrameContainer:new{
        width = self.largura,
        height = self.altura,
        bordersize = 0,
        padding = 0,
        background = Estilo.branco,
        OverlapGroup:new{
            dimen = Geom:new{ w = self.largura, h = self.altura },
            allow_mirroring = false,
            VerticalGroup:new{ align = "left", cabecalho, corpo },
            self:_rodape(rodape_altura),
        },
    }
end

function TelaMencoes:_rodape(altura)
    local largura_botao = Screen:scaleBySize(80)
    local grupo = HorizontalGroup:new{
        Button:new{
            text = "‹",
            width = largura_botao,
            bordersize = 0,
            enabled = self.pagina > 1,
            show_parent = self,
            callback = function() self:onPaginaAnterior() end,
        },
        TextWidget:new{
            text = #self.lista > 0 and T(_("%1–%2 of %3"), self.primeiro_da_pagina, self.ultimo_da_pagina, #self.lista) or "",
            face = Estilo.texto(),
        },
        Button:new{
            text = "›",
            width = largura_botao,
            bordersize = 0,
            enabled = self.ultimo_da_pagina < #self.lista,
            show_parent = self,
            callback = function() self:onPaginaSeguinte() end,
        },
    }
    local tamanho = grupo:getSize()
    grupo.overlap_offset = {
        math.floor((self.largura - tamanho.w) / 2),
        self.altura - altura + math.floor((altura - tamanho.h) / 2),
    }
    return grupo
end

function TelaMencoes:_remontar()
    self[1]:free()
    self:_montar()
    UIManager:setDirty(self, "ui")
end

function TelaMencoes:onShow()
    UIManager:setDirty(self, "full")
end

function TelaMencoes:onCloseWidget()
    UIManager:setDirty(nil, "full")
end

function TelaMencoes:fechar()
    UIManager:close(self)
end

function TelaMencoes:onFechar()
    self:fechar()
    return true
end

function TelaMencoes:onPaginaSeguinte()
    if self.inicios[self.pagina + 1] then
        self.pagina = self.pagina + 1
        self:_remontar()
    end
    return true
end

function TelaMencoes:onPaginaAnterior()
    if self.pagina > 1 then
        self.pagina = self.pagina - 1
        self:_remontar()
    end
    return true
end

function TelaMencoes:onArrastar(arg, ges)
    if ges.direction == "west" then
        return self:onPaginaSeguinte()
    elseif ges.direction == "east" then
        return self:onPaginaAnterior()
    elseif ges.direction == "south" then
        self:fechar()
    end
    return true
end

return TelaMencoes
