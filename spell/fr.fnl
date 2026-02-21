(set vim.opt_local.keymap :fr)

(set vim.opt_local.spell true)

(set vim.g.languagetool_lang :fr_FR)

(set vim.b.minipairs_disable_map (or vim.b.minipairs_disable_map {}))

(tset vim.b.minipairs_disable_map "\"" true)

((. (require :utils.prose) :set_guillemets))

