local RAIZ = ...
local falhas = {}

local function igual(nome, obtido, esperado)
    if obtido ~= esperado then
        table.insert(falhas, string.format("%s: esperado %q, veio %q", nome, tostring(esperado), tostring(obtido)))
    end
end

local _ = require("fuxico/traducao")

igual("sem catálogo, devolve o original", (_.carregar("xx_YY", RAIZ)) , false)
igual("sem catálogo, texto", _("Who is this?"), "Who is this?")

igual("pt_BR carrega", _.carregar("pt_BR", RAIZ), true)
igual("texto simples", _("Who is this?"), "Quem é esse?")
igual("texto ausente cai no gettext", _("Nada disso"), "Nada disso")
igual("plural 1", _.ngettext("1 mention", "%1 mentions", 1), "1 menção")
igual("plural 2", _.ngettext("1 mention", "%1 mentions", 2), "%1 menções")
igual("plural 0 (pt_BR usa singular)", _.ngettext("1 mention", "%1 mentions", 0), "1 menção")
igual("plural ausente cai no gettext", _.ngettext("a", "as", 2), "as")

igual("pt_PT cai no pt", _.carregar("pt_PT", RAIZ), false)
igual("en não carrega", _.carregar("en_US", RAIZ), false)

local textos = _.lerMO(RAIZ .. "/l10n/pt_BR/fuxico.mo")
local quantos = 0
for _ in pairs(textos) do quantos = quantos + 1 end
igual("todas as entradas lidas", quantos, 34)

return falhas
