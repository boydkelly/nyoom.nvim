(import-macros {: packadd! : pack : rock : use-package!
                : lz-package! : fake-module! : vim-pack-spec!
                : lz-unpack! : lz-load!
                : rock! : nyoom-init-modules!
                : nyoom-compile-modules! : autocmd!} :macros)

; (print "NYOOM: packages.fnl - START")
;; 1. Initialize the global registries
(set _G.nyoom/pack [])
(set _G.nyoom/specs [])

(vim-pack-spec! :nvim-lua/plenary.nvim {:module :plenary})
(vim-pack-spec! :MunifTanjim/nui.nvim {:module :nui})
(vim-pack-spec! :nyoom-engineering/oxocarbon.nvim)

(include :fnl.modules)
(nyoom-init-modules!)
(nyoom-compile-modules!)

(lz-unpack!)

(packadd! :plenary.nvim)
(packadd! :nui.nvim)
(packadd! :oxocarbon.nvim)

;; Compile modules
(nyoom-compile-modules!)

(lz-load!)
