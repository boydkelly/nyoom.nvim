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

(vim-pack-spec! :nvim-lua/plenary.nvim)
(vim-pack-spec! :MunifTanjim/nui.nvim)
(vim-pack-spec! :nyoom-engineering/oxocarbon.nvim)
(packadd! oxocarbon.nvim)
(colorscheme oxocarbon)

(include :fnl.modules)
(nyoom-init-modules!)

(lz-unpack!)

(packadd! :plenary.nvim)
(packadd! :nui.nvim)
(packadd! :oxocarbon.nvim)

;; Compile modules
; (nyoom-compile-modules!) ;; not ding anything

(lz-load!)
