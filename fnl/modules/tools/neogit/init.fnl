(import-macros {: lz-package! : vim-pack-spec!} :macros)

; Magit for neovim
(lz-package! :TimUntersberger/neogit
             {:nyoom-module tools.neogit :enabled false :cmd :Neogit})

