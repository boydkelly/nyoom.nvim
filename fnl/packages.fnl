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
                : nyoom-init-modules!
                : autocmd!} :macros)

;; could be added to a general dependencies layer; or just added to telescope etc.
(vim-pack-spec! :nvim-lua/plenary.nvim)
(vim-pack-spec! :MunifTanjim/nui.nvim)

(include :modules)
(nyoom-init-modules!)
(lz-unpack!)
(lz-load-specs!)
