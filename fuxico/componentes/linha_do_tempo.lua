local Geom = require("ui/geometry")
local Screen = require("device").screen
local Widget = require("ui/widget/widget")
local Estilo = require("fuxico/componentes/estilo")

local LinhaDoTempo = Widget:extend{
    largura = nil,
    altura = Screen:scaleBySize(16),
    posicoes = nil,
    atual = 0,
}

function LinhaDoTempo:init()
    self.dimen = Geom:new{ w = self.largura, h = self.altura }
end

function LinhaDoTempo:getSize()
    return self.dimen
end

function LinhaDoTempo:paintTo(bb, x, y)
    self.dimen.x, self.dimen.y = x, y
    local w, h = self.largura, self.altura
    local meio = y + math.floor(h / 2)
    local espessura = Screen:scaleBySize(4)
    local marca_w = Screen:scaleBySize(3)
    local cursor_w = Screen:scaleBySize(9)
    local x_atual = x + math.floor(self.atual * (w - cursor_w))

    bb:paintRect(x, meio - math.floor(espessura / 2), x_atual - x, espessura, Estilo.cinza)

    local traco = Screen:scaleBySize(4)
    local cx = x_atual + cursor_w
    while cx < x + w do
        bb:paintRect(cx, meio - 1, math.min(traco, x + w - cx), Screen:scaleBySize(2), Estilo.cinza)
        cx = cx + traco * 2
    end

    local marca_h = math.floor(h * 0.75)
    for _, posicao in ipairs(self.posicoes or {}) do
        local mx = x + math.floor(posicao * (w - cursor_w))
        if mx + marca_w < x_atual then
            bb:paintRect(mx, meio - math.floor(marca_h / 2), marca_w, marca_h, Estilo.preto)
        end
    end

    bb:paintRect(x_atual, y, cursor_w, h, Estilo.preto)
    local miolo = Screen:scaleBySize(2)
    bb:paintRect(x_atual + miolo, y + miolo, cursor_w - 2 * miolo, h - 2 * miolo, Estilo.branco)
end

return LinhaDoTempo
