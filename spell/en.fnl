(set vim.opt_local.keymap "")
(set vim.opt_local.spell true)
(set vim.g.languagetool_lang :en_CA)
(set vim.b.minipairs_disable_map nil)

;; Only run if we are "Live"
(when (= vim.g.prose_is_live true)
  ((. (require :utils.prose) :set_quotes)))

