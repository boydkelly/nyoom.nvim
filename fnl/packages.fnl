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
                : nyoom-module-count!
                : nyoom-module-count-runtime!
                : nyoom-package-count!
                : nyoom-init-modules!
                : nyoom-compile-modules!
                : autocmd!} :macros)

; (print "NYOOM: packages.fnl - START")
;; 1. Initialize the global registries

;; could be added to a general dependencies layer; or just added to telescope etc.
(vim-pack-spec! :nvim-lua/plenary.nvim)
(vim-pack-spec! :MunifTanjim/nui.nvim)

(include :modules)
(nyoom-init-modules!)
; (local module-counter (nyoom-module-count-runtime!))
; (vim.notify module-counter)
;; install the stuff
(lz-unpack!)
; (print (.. "DEBUG: Module count from packages.fnl is " (nyoom-module-count!)));;
; (nyoom-compile-modules!) ;; precompiled in init.lua
(lz-load-specs!)
;; oxocarbon could either be added to core install with tangerine and lz.n or as a regular module
; (packadd! :plenary.nvim)
; (packadd! :nui.nvim)
