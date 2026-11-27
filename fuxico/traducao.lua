local gettext = require("gettext")
local logger = require("logger")

local RAIZ = debug.getinfo(1, "S").source:match("^@(.*)/fuxico/[^/]*$") or "."

local Traducao = {}

local catalogo
local plural

local function inteiro(dados, posicao, little_endian)
    local a, b, c, d = dados:byte(posicao + 1, posicao + 4)
    if little_endian then
        return a + b * 0x100 + c * 0x10000 + d * 0x1000000
    end
    return d + c * 0x100 + b * 0x10000 + a * 0x1000000
end

local function separar(texto)
    local partes = {}
    for parte in (texto .. "\0"):gmatch("(.-)%z") do
        table.insert(partes, parte)
    end
    return partes
end

local function formaPlural(cabecalho)
    local expressao = cabecalho and cabecalho:match("Plural%-Forms:[^\n]-plural=([^;\n]+)")
    if expressao and not expressao:find("?", 1, true) then
        expressao = expressao:gsub("&&", " and "):gsub("||", " or "):gsub("!=", "~=")
        local funcao = loadstring("local n = ... return " .. expressao)
        if funcao then
            return function(n)
                local ok, resultado = pcall(funcao, n)
                if not ok then
                    return n == 1 and 0 or 1
                end
                if type(resultado) == "boolean" then
                    return resultado and 1 or 0
                end
                return tonumber(resultado) or 0
            end
        end
    end
    return function(n)
        return n == 1 and 0 or 1
    end
end

function Traducao.lerMO(caminho)
    local arquivo = io.open(caminho, "rb")
    if not arquivo then
        return nil
    end
    local dados = arquivo:read("*a")
    arquivo:close()
    if #dados < 28 then
        return nil
    end

    local little_endian
    if inteiro(dados, 0, true) == 0x950412de then
        little_endian = true
    elseif inteiro(dados, 0, false) == 0x950412de then
        little_endian = false
    else
        return nil
    end

    local total = inteiro(dados, 8, little_endian)
    local originais = inteiro(dados, 12, little_endian)
    local traduzidos = inteiro(dados, 16, little_endian)
    local textos, cabecalho = {}, nil

    for i = 0, total - 1 do
        local tamanho_original = inteiro(dados, originais + i * 8, little_endian)
        local inicio_original = inteiro(dados, originais + i * 8 + 4, little_endian)
        local tamanho_traduzido = inteiro(dados, traduzidos + i * 8, little_endian)
        local inicio_traduzido = inteiro(dados, traduzidos + i * 8 + 4, little_endian)
        local original = dados:sub(inicio_original + 1, inicio_original + tamanho_original)
        local traduzido = dados:sub(inicio_traduzido + 1, inicio_traduzido + tamanho_traduzido)
        if original == "" then
            cabecalho = traduzido
        elseif traduzido ~= "" then
            local chave = original:match("^(.-)%z") or original
            if chave ~= original then
                textos[chave] = separar(traduzido)
            else
                textos[chave] = traduzido
            end
        end
    end
    return textos, formaPlural(cabecalho)
end

local function idioma()
    local escolhido
    if rawget(_G, "G_reader_settings") then
        local ok, valor = pcall(function()
            return G_reader_settings:readSetting("language")
        end)
        if ok and type(valor) == "string" then
            escolhido = valor
        end
    end
    escolhido = escolhido or gettext.current_lang
    if not escolhido or escolhido == "" or escolhido == "C" then
        return nil
    end
    return (escolhido:gsub("[.:].*$", ""))
end

function Traducao.carregar(lingua, raiz)
    catalogo, plural = {}, nil
    lingua = lingua or idioma()
    if not lingua or lingua:match("^en") then
        return false
    end
    local candidatos = { lingua }
    local base = lingua:match("^(%a+)_")
    if base then
        table.insert(candidatos, base)
    end
    for _, candidato in ipairs(candidatos) do
        local caminho = string.format("%s/l10n/%s/fuxico.mo", raiz or RAIZ, candidato)
        local textos, forma = Traducao.lerMO(caminho)
        if textos then
            catalogo, plural = textos, forma
            logger.info("Fuxico: tradução carregada de", caminho)
            return true
        end
    end
    logger.info("Fuxico: sem tradução para", lingua)
    return false
end

local function garantir()
    if not catalogo then
        Traducao.carregar()
    end
end

function Traducao.ngettext(singular, plural_original, n)
    garantir()
    local formas = catalogo[singular]
    if type(formas) == "table" and plural then
        local escolhida = formas[plural(n) + 1]
        if escolhida and escolhida ~= "" then
            return escolhida
        end
    end
    return gettext.ngettext(singular, plural_original, n)
end

return setmetatable(Traducao, {
    __call = function(_, texto)
        garantir()
        local traduzido = catalogo[texto]
        if type(traduzido) == "string" then
            return traduzido
        end
        return gettext(texto)
    end,
})
