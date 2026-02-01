(import-macros {: lz-package! : vim-pack-spec!} :macros)

; Magit for neovim
(lz-package! :TimUntersberger/neogit {:after tools.neogit :cmd :Neogit})
