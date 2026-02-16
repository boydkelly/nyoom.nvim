(import-macros {: packadd! : vim-pack! : lz-load! : nyoom-init-modules!}
               :macros)

;; could be added to a general dependencies layer; or just added to telescope etc.
(vim-pack! :nvim-lua/plenary.nvim)
(vim-pack! :MunifTanjim/nui.nvim)
;
(include :modules)
(nyoom-init-modules!)
(lz-load!)
