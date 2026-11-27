local ok_utf8proc, Utf8Proc = pcall(require, "ffi/utf8proc")
local minusculo = ok_utf8proc and function(s) return Utf8Proc.lowercase(s) end or string.lower

local Semia = {}

local CARACTERE = "[%z\1-\127\194-\244][\128-\191]*"
local RETICENCIAS = "\226\128\166"
local ABERTURAS = { ["\226\128\148"] = true, ["\226\128\147"] = true, ["\226\128\156"] = true, ["\194\171"] = true, ['"'] = true }
local PONTAS = {
    ["\226\128\156"] = true, ["\226\128\157"] = true, ["\226\128\152"] = true, ["\226\128\153"] = true,
    ["\194\171"] = true, ["\194\187"] = true, ["\226\128\148"] = true, ["\226\128\147"] = true,
    [RETICENCIAS] = true,
}

local LIGACOES = { de = true, da = true, ["do"] = true, das = true, dos = true, e = true }

local COMUNS = {}
for palavra in ([[
    eu tu ele ela nos vos eles elas voce voces você vocês nós vós
    meu minha meus minhas teu tua seu sua seus suas nosso nossa dele dela
    este esta estes estas esse essa esses essas aquele aquela aqueles aquelas isto isso aquilo
    quando entao então mas porem porém pois porque como onde quem que qual quanto
    depois antes agora aqui ali ainda tambem também talvez assim nunca sempre jamais
    tudo nada cada outro outra outros outras algum alguma ninguem ninguém
    sim nao não ora enfim logo apenas so só
    senhor senhora senhores senhoras deus
    domingo segunda terça terca quarta quinta sexta sábado sabado
    janeiro fevereiro março marco abril maio junho julho agosto setembro outubro novembro dezembro
]]):gmatch("%S+") do
    COMUNS[palavra] = true
end

local function caracteres(s)
    return s:gmatch(CARACTERE)
end

function Semia.primeiroCaractere(s)
    return (s or ""):match("^" .. CARACTERE) or ""
end

function Semia.contarCaracteres(s)
    local n = 0
    for _ in caracteres(s or "") do
        n = n + 1
    end
    return n
end

function Semia.ehMaiuscula(c)
    if c == "" then
        return false
    end
    if #c == 1 then
        return c:match("%u") ~= nil
    end
    return minusculo(c) ~= c
end

function Semia.ehTodaMaiuscula(palavra)
    local letras = 0
    for c in caracteres(palavra or "") do
        if #c == 1 then
            if c:match("%l") then
                return false
            elseif c:match("%u") then
                letras = letras + 1
            end
        elseif not PONTAS[c] then
            if minusculo(c) == c then
                return false
            end
            letras = letras + 1
        end
    end
    return letras >= 2
end

function Semia.limpar(texto)
    local s = (texto or ""):gsub("%s+", " ")
    local mudou = true
    while mudou do
        mudou = false
        s = s:gsub("^%s+", ""):gsub("%s+$", "")
        local primeiro = Semia.primeiroCaractere(s)
        if primeiro ~= "" and (primeiro:match("^%p$") or PONTAS[primeiro]) then
            s = s:sub(#primeiro + 1)
            mudou = true
        end
        for ponta in pairs(PONTAS) do
            if s:sub(-#ponta) == ponta then
                s = s:sub(1, -#ponta - 1)
                mudou = true
            end
        end
        if s:match("%p$") then
            s = s:sub(1, -2)
            mudou = true
        end
    end
    return s
end

function Semia.pareceNome(texto)
    local limpo = Semia.limpar(texto)
    if limpo == "" then
        return false
    end
    local palavras = {}
    for p in limpo:gmatch("%S+") do
        table.insert(palavras, p)
    end
    if #palavras > 5 then
        return false
    end
    for i, p in ipairs(palavras) do
        local ligacao = LIGACOES[p] and i > 1 and i < #palavras
        if not ligacao and not Semia.ehMaiuscula(Semia.primeiroCaractere(p)) then
            return false
        end
    end
    if #palavras == 1 then
        if Semia.contarCaracteres(limpo) < 3 then
            return false
        end
        if COMUNS[minusculo(limpo)] then
            return false
        end
    end
    return true
end

local function ultimaPosicao(s, padrao, simples)
    local fim
    local inicio = 1
    while true do
        local a, b = s:find(padrao, inicio, simples)
        if not a then
            break
        end
        fim = b
        inicio = b + 1
    end
    return fim
end

local function primeiraPosicao(s, padrao, simples)
    local _, b = s:find(padrao, 1, simples)
    return b
end

function Semia.inicioDeFrase(antes)
    local s = (antes or ""):gsub("%s+$", "")
    if s == "" then
        return true
    end
    if s:match("[%.!?:;]$") or s:sub(-#RETICENCIAS) == RETICENCIAS then
        return true
    end
    for abertura in pairs(ABERTURAS) do
        if s:sub(-#abertura) == abertura then
            return true
        end
    end
    return false
end

function Semia.cortarAntes(antes)
    local s = (antes or ""):gsub("%s+$", "")
    if s == "" then
        return ""
    end
    local fim = ultimaPosicao(s, "[%.!?]%s")
    local fim_reticencias = ultimaPosicao(s, RETICENCIAS .. " ", true)
    if fim_reticencias and (not fim or fim_reticencias > fim) then
        fim = fim_reticencias
    end
    if fim then
        return (s:sub(fim + 1):gsub("^%s+", ""))
    end
    return RETICENCIAS .. s:gsub("^%s+", "")
end

function Semia.cortarDepois(depois)
    local s = (depois or ""):gsub("^%s+", "")
    if s == "" then
        return ""
    end
    local fim = primeiraPosicao(s, "[%.!?]")
    local fim_reticencias = primeiraPosicao(s, RETICENCIAS, true)
    if fim_reticencias and (not fim or fim_reticencias < fim) then
        fim = fim_reticencias
    end
    if fim then
        return s:sub(1, fim)
    end
    return s .. RETICENCIAS
end

function Semia.buscarNoLivro(documento, texto)
    return documento:findAllText(Semia.limpar(texto), true, 30, 5000, false, 0x00FF + 0x1000)
end

function Semia.montar(contexto, texto, resultados, corte)
    local resultado = {
        nome = Semia.limpar(texto),
        mencoes = {},
        pagina_atual = contexto.pagina_atual,
        total_paginas = contexto.total_paginas,
        meio = 0,
        meio_maiusculas = 0,
        capitulo_de = contexto.capitulo,
    }
    for _, r in ipairs(resultados or {}) do
        local comparacao = corte and contexto.comparar(r.start, corte) or 1
        if comparacao == 1 or comparacao == 0 then
            local encontrado = (r.matched_word_prefix or "") .. (r.matched_text or "") .. (r.matched_word_suffix or "")
            local inicio = Semia.inicioDeFrase(r.prev_text)
            local mencao = {
                xp = r.start,
                xp_fim = r["end"],
                pagina = contexto.pagina(r.start),
                antes = Semia.cortarAntes(r.prev_text),
                trecho = encontrado,
                depois = Semia.cortarDepois(r.next_text),
            }
            table.insert(resultado.mencoes, mencao)
            if comparacao == 0 then
                resultado.atual = #resultado.mencoes
            end
            if not inicio and not Semia.ehTodaMaiuscula(encontrado) then
                resultado.meio = resultado.meio + 1
                if Semia.ehMaiuscula(Semia.primeiroCaractere(encontrado)) then
                    resultado.meio_maiusculas = resultado.meio_maiusculas + 1
                end
            end
        end
    end
    resultado.total = #resultado.mencoes
    resultado.primeira = resultado.mencoes[1]
    local ultima_antes = resultado.atual and resultado.atual - 1 or resultado.total
    if ultima_antes >= 1 then
        resultado.anterior = resultado.mencoes[ultima_antes]
    end
    if resultado.meio == 0 then
        resultado.parece_nome = true
    else
        resultado.parece_nome = resultado.meio_maiusculas / resultado.meio >= 0.8
    end
    return resultado
end

function Semia.capitulo(resultado, mencao)
    if mencao.capitulo == nil then
        mencao.capitulo = resultado.capitulo_de and resultado.capitulo_de(mencao.xp) or ""
    end
    return mencao.capitulo
end

function Semia.posicao(resultado, pagina)
    local total = resultado.total_paginas or 0
    if total <= 1 or not pagina then
        return 0
    end
    return math.max(0, math.min(1, (pagina - 1) / (total - 1)))
end

return Semia
