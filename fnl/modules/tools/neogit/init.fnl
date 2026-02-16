(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

; Magit for neovim
(lz-package! :TimUntersberger/neogit
             {:nyoom-module tools.neogit :enabled false :cmd :Neogit})
