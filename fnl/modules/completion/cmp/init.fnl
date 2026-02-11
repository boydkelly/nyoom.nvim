(import-macros {: lz-package! : vim-pack-spec! : lz-trigger-load!} :macros)
;; standard completion for neovim

(lz-package! :hrsh7th/nvim-cmp
              {:nyoom-module completion.cmp
               :module :cmp
               :event [:UIEnter :InsertEnter :CmdLineEnter]
               :requires [(lz-trigger-load! :onsails/lspkind.nvim {:opt true})
                          (lz-trigger-load! :zbirenbaum/copilot-cmp {:opt true})
                          (lz-trigger-load! :hrsh7th/cmp-path {:after :nvim-cmp})
                          (lz-trigger-load! :hrsh7th/cmp-buffer {:after :nvim-cmp})
                          (lz-trigger-load! :hrsh7th/cmp-cmdline {:after :nvim-cmp})
                          (lz-trigger-load! :hrsh7th/cmp-nvim-lsp {:after :nvim-cmp})
                          (lz-trigger-load! :hrsh7th/cmp-nvim-lsp-signature-help
                                {:after :nvim-cmp})
                          (lz-trigger-load! :PaterJason/cmp-conjure {:after :conjure})
                          (lz-trigger-load! :saadparwaiz1/cmp_luasnip {:after :nvim-cmp})
                          (lz-trigger-load! :L3MON4D3/LuaSnip
                                {:event [:InsertEnter :CmdLineEnter]
                                 :wants :friendly-snippets
                                 :requires [(lz-trigger-load! :rafamadriz/friendly-snippets)]})]})
