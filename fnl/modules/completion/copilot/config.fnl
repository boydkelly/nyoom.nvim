(local {: setup} (require :core.lib.setup))
(import-macros {: nyoom-module-ensure!} :macros)

; (nyoom-module-ensure! cmp)
; (nyoom-module-ensure! lsp)

(setup :copilot {:cmp {:enabled true}
       :panel {:enabled false}
                 :suggestion {:enabled false}
})
