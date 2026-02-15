(import-macros {: lz-package! : vim-pack-spec!} :macros)

; easy to use configurations for language servers

(lz-package! :neovim/nvim-lspconfig {:nyoom-module tools.lsp :event :UIEnter})

;;:requires (pack :smjonas/inc-rename.nvim :after :nvim-lspconfig
;;                :call-setup inc_rename)})
;;fix after
; (lz-package! :smjonas/inc-rename.nvim
;              {:nyoom-module tools.lsp.inc_rename})
;
