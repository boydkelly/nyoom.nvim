(import-macros {: packadd!
                : pack
                : rock
                : lz-package!
                : fake-module!
                : vim-pack-spec!
                : lz-unpack!
                : lz-load!
                : rock!
                : colorscheme
                : nyoom-init-modules!
                : nyoom-compile-modules!
                : autocmd!} :macros)

; (print "NYOOM: packages.fnl - START")
;; 1. Initialize the global registries
(set _G.nyoom/pack [])
(set _G.nyoom/specs [])
(set _G.nyoom/modules [])

;; could be added to a general dependencies layer; or just added to telescope etc.
(vim-pack-spec! :nvim-lua/plenary.nvim)
(vim-pack-spec! :MunifTanjim/nui.nvim)
(vim-pack-spec! :nyoom-engineering/oxocarbon.nvim)

;;
(include :modules)
(nyoom-init-modules!)
(lz-unpack!)

;; install the stuff

; (packadd! :plenary.nvim)
; (packadd! :nui.nvim)

;; Compile modules
; (nyoom-compile-modules!) ;; not ding anything... it just works

;;(nyoom-compile-modules!)
(lz-load!)
;; oxocarbon could either be added to core install with tangerine and lz.n or as a regular module
; (packadd! :plenary.nvim)
; (packadd! :nui.nvim)
(packadd! oxocarbon.nvim)
(colorscheme oxocarbon)

