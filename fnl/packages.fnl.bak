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
                : lz-virtual-disk!
                : lz-bake-configs!
                : lz-config-modules!
                : autocmd!} :macros)

; (print "NYOOM: packages.fnl - START")
;; 1. Initialize the global registries

;; could be added to a general dependencies layer; or just added to telescope etc.
(vim-pack-spec! :nvim-lua/plenary.nvim)
(vim-pack-spec! :MunifTanjim/nui.nvim)

;; install the stuff
(lz-unpack!)

;; loads the modules.fnl file containing the nyoom! macro to get us going
(include :modules)

;;processes the config files (precompiled on disk fron the init.lua bootstrap)
; (lz-compile-modules-v1!)
; (lz-bake-configs!)

; (lz-virtual-disk!)

;; This runs during compilation to prep the disk
;; processes the init files from compile time calls lz-package for each enabled module
;;(lz-bake-configs!)
(lz-init-modules!)
;; Add this at the bottom of packages.fnl before lz-load-specs!
; (each [name _ (pairs _G.nyoom/modules)]
;   (pcall require (.. :modules. (name:gsub "%." "/"))))

;; let lz.n now process the _G.nyoom/specs generated
(lz-load-specs!)
