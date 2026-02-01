(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :jose-elias-alvarez/null-ls.nvim
              {:after checkers.diagnostics :after :nvim-lspconfig})

;; floating diagnostics as lines instead
(lz-package! "https://git.sr.ht/~whynothugo/lsp_lines.nvim"
              {:call-setup lsp_lines :after :nvim-lspconfig})
