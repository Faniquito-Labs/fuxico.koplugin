local DataStorage = require("datastorage")
local LuaSettings = require("luasettings")

local PADROES = {
    so_nomes_proprios = true,
    aviso_sumico_paginas = 30,
    mostrar_miniatura = true,
    abrir_tela_completa = false,
}

local Configuracoes = {}

function Configuracoes:_arquivo()
    if not self._dados then
        self._dados = LuaSettings:open(DataStorage:getSettingsDir() .. "/fuxico.lua")
    end
    return self._dados
end

function Configuracoes:ler(chave)
    local valor = self:_arquivo():readSetting(chave)
    if valor == nil then
        return PADROES[chave]
    end
    return valor
end

function Configuracoes:gravar(chave, valor)
    local dados = self:_arquivo()
    dados:saveSetting(chave, valor)
    dados:flush()
end

function Configuracoes:alternar(chave)
    self:gravar(chave, not self:ler(chave))
end

function Configuracoes:padrao(chave)
    return PADROES[chave]
end

return Configuracoes
