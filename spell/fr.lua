vim.opt_local.keymap = "fr"
vim.opt_local.spell = true
vim.g.languagetool_lang = "fr_FR"
vim.b.minipairs_disable_map = vim.b.minipairs_disable_map or {}
vim.b.minipairs_disable_map['"'] = true

require("utils.prose").set_guillemets()
