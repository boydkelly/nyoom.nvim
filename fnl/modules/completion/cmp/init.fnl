(import-macros {: lz-package! : vim-pack-spec! : lz-pack!} :macros)
;; standard completion for neovim

(lz-package! :hrsh7th/nvim-cmp
              {:nyoom-module completion.cmp
               :module :cmp
               :event [:UIEnter :InsertEnter :CmdLineEnter]
               :requires [(lz-pack! :onsails/lspkind.nvim {:opt true})
                          (lz-pack! :zbirenbaum/copilot-cmp {:opt true})
                          (lz-pack! :hrsh7th/cmp-path {:after :nvim-cmp})
                          (lz-pack! :hrsh7th/cmp-buffer {:after :nvim-cmp})
                          (lz-pack! :hrsh7th/cmp-cmdline {:after :nvim-cmp})
                          (lz-pack! :hrsh7th/cmp-nvim-lsp {:after :nvim-cmp})
                          (lz-pack! :hrsh7th/cmp-nvim-lsp-signature-help
                                {:after :nvim-cmp})
                          (lz-pack! :PaterJason/cmp-conjure {:after :conjure})
                          (lz-pack! :saadparwaiz1/cmp_luasnip {:after :nvim-cmp})
                          (lz-pack! :L3MON4D3/LuaSnip
                                {:event [:InsertEnter :CmdLineEnter]
                                 :wants :friendly-snippets
                                 :requires [(lz-pack! :rafamadriz/friendly-snippets)]})]})
