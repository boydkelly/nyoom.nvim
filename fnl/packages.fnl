(import-macros {: packadd!
                : pack
                : rock
                : lz-package!
                : fake-module!
                : vim-pack-spec!
                : lz-unpack!
                : lz-load-specs!
                : rock!
                : colorscheme
                : lz-init-modules!
                : lz-compile-modules!
                : lz-config-modules!
                : autocmd!} :macros)

; (print "NYOOM: packages.fnl - START")
;; 1. Initialize the global registries
(set _G.nyoom/pack [])
(set _G.nyoom/specs [])

;; could be added to a general dependencies layer; or just added to telescope etc.
(vim-pack-spec! :nvim-lua/plenary.nvim)
(vim-pack-spec! :MunifTanjim/nui.nvim)

;(include :modules)
;(nyoom-init-modules!
;; install the stuff
;;
; (include :modules)
;(lz-compile-modules!)
(lz-unpack!)
(lz-config-modules!)
(lz-init-modules!)
; (lz-compile-modules!)
; (nyoom-compile-modules!) ;; precompiled in init.lua
;; precompiled in init.lua
(lz-load-specs!)
