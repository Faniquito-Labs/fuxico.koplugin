local Blitbuffer = require("ffi/blitbuffer")
local Font = require("ui/font")
local Screen = require("device").screen
local Size = require("ui/size")

local Estilo = {
    preto = Blitbuffer.COLOR_BLACK,
    branco = Blitbuffer.COLOR_WHITE,
    cinza = Blitbuffer.COLOR_GRAY,
    cinza_escuro = Blitbuffer.COLOR_DARK_GRAY,
    borda_forte = Size.border.thick,
    borda_fina = Size.border.default,
    raio_cartao = Screen:scaleBySize(10),
    raio_gaveta = Screen:scaleBySize(16),
    raio_pilula = Screen:scaleBySize(14),
    espaco = Screen:scaleBySize(8),
    espaco_pequeno = Screen:scaleBySize(4),
    margem = Screen:scaleBySize(14),
}

local faces = {}

local function face(nome, tamanho, reserva)
    local chave = nome .. tamanho
    if not faces[chave] then
        faces[chave] = Font:getFace(nome, tamanho) or Font:getFace(reserva or "cfont", tamanho)
    end
    return faces[chave]
end

function Estilo.titulo()
    return face("cfont", 26)
end

function Estilo.texto()
    return face("cfont", 18)
end

function Estilo.pequeno()
    return face("cfont", 15)
end

function Estilo.trecho()
    return face("NotoSerif-Regular.ttf", 18)
end

return Estilo
