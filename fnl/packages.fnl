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
                : nyoom-package-count!
                : nyoom-init-modules!
                : lz-init-modules!
                : autocmd!} :macros)

; (print "NYOOM: packages.fnl - START")
;; 1. Initialize the global registries

;; could be added to a general dependencies layer; or just added to telescope etc.
(vim-pack-spec! :nvim-lua/plenary.nvim)
(vim-pack-spec! :MunifTanjim/nui.nvim)

(include :modules)
(nyoom-init-modules!)
(packadd! :lz.n)
(lz-unpack!)
(lz-load-specs!)

