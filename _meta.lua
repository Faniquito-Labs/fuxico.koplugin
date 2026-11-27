local ok, _ = pcall(require, "fuxico/traducao")
if not ok then
    _ = require("gettext")
end
return {
    fullname = _("Fuxico"),
    description = _([[Remembers the story for you: who is who, what happened and where you stopped, without spoilers.]]),
    version = "0.1.0",
}
