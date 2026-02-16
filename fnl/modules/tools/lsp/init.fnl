(import-macros {: lz-package! : lz-pack! : vim-pack-spec!} :macros)

; easy to use configurations for language servers

(lz-package! :neovim/nvim-lspconfig {:nyoom-module tools.lsp
             :event :UIEnter
             :enabled true
             })

(lz-pack! :smjonas/inc-rename.nvim {:call-setup inc_rename :event :UIEnter})
;;fix after
; (lz-package! :smjonas/inc-rename.nvim
;              {:nyoom-module tools.lsp.inc_rename})
;
