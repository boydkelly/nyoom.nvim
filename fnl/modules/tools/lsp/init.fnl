(import-macros {: lz-package! : vim-pack-spec!} :macros)

; easy to use configurations for language servers

(lz-package! :neovim/nvim-lspconfig
              {:setup nvim-lspconfig
               :opt true

               :after tools.lsp
               :defer nvim-lspconfig})
               ;;:requires (pack :smjonas/inc-rename.nvim :after :nvim-lspconfig
               ;;                :call-setup inc_rename)})
