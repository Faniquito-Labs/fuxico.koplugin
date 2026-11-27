local FrameContainer = require("ui/widget/container/framecontainer")
local Geom = require("ui/geometry")
local GestureRange = require("ui/gesturerange")
local InputContainer = require("ui/widget/container/inputcontainer")
local OverlapGroup = require("ui/widget/overlapgroup")
local TextBoxWidget = require("ui/widget/textboxwidget")
local TextWidget = require("ui/widget/textwidget")
local VerticalGroup = require("ui/widget/verticalgroup")
local VerticalSpan = require("ui/widget/verticalspan")
local Estilo = require("fuxico/componentes/estilo")

local Cartao = InputContainer:extend{
    largura = nil,
    antes = "",
    nome = "",
    depois = "",
    rodape_esquerda = nil,
    rodape_direita = nil,
    forte = false,
    max_linhas = nil,
    ao_tocar = nil,
}

local function juntar(antes, nome, depois)
    local partes = { TextBoxWidget.PTF_HEADER }
    if antes ~= "" then
        table.insert(partes, antes)
        if not antes:match("[%s%(\"]$") and not antes:match("\226\128[\148\147\156]$") and not antes:match("\194\171$") then
            table.insert(partes, " ")
        end
    end
    table.insert(partes, TextBoxWidget.PTF_BOLD_START)
    table.insert(partes, nome)
    table.insert(partes, TextBoxWidget.PTF_BOLD_END)
    if depois ~= "" then
        if not depois:match("^[%s%p]") and not depois:match("^\226\128[\157\166]") and not depois:match("^\194\187") then
            table.insert(partes, " ")
        end
        table.insert(partes, depois)
    end
    return table.concat(partes)
end

function Cartao:init()
    local borda = self.forte and Estilo.borda_forte or Estilo.borda_fina
    local interno = self.largura - 2 * (borda + Estilo.espaco)
    local texto = juntar(self.antes or "", self.nome or "", self.depois or "")
    local caixa = TextBoxWidget:new{ text = texto, face = Estilo.trecho(), width = interno }
    local linha = caixa.line_height_px
    if self.max_linhas and linha and caixa:getSize().h > self.max_linhas * linha + 1 then
        caixa:free()
        caixa = TextBoxWidget:new{
            text = texto,
            face = Estilo.trecho(),
            width = interno,
            height = self.max_linhas * linha,
            height_overflow_show_ellipsis = true,
        }
    end
    local conteudo = VerticalGroup:new{ align = "left", caixa }
    if self.rodape_esquerda or self.rodape_direita then
        local esquerda = TextWidget:new{
            text = self.rodape_esquerda or "",
            face = Estilo.pequeno(),
            fgcolor = Estilo.cinza_escuro,
            max_width = math.floor(interno * 0.65),
        }
        local direita = TextWidget:new{
            text = self.rodape_direita or "",
            face = Estilo.pequeno(),
            fgcolor = Estilo.cinza_escuro,
            max_width = math.floor(interno * 0.35),
            overlap_align = "right",
        }
        table.insert(conteudo, VerticalSpan:new{ width = Estilo.espaco_pequeno })
        table.insert(conteudo, OverlapGroup:new{
            dimen = Geom:new{ w = interno, h = math.max(esquerda:getSize().h, direita:getSize().h) },
            allow_mirroring = false,
            esquerda,
            direita,
        })
    end
    self[1] = FrameContainer:new{
        bordersize = borda,
        radius = Estilo.raio_cartao,
        padding = Estilo.espaco,
        background = Estilo.branco,
        conteudo,
    }
    if self.ao_tocar then
        self.ges_events.TocarCartao = {
            GestureRange:new{
                ges = "tap",
                range = function() return self.area end,
            },
        }
    end
end

function Cartao:paintTo(bb, x, y)
    local tamanho = self[1]:getSize()
    self.area = Geom:new{ x = x, y = y, w = tamanho.w, h = tamanho.h }
    self[1]:paintTo(bb, x, y)
end

function Cartao:onTocarCartao()
    if self.ao_tocar then
        self.ao_tocar()
    end
    return true
end

return Cartao
