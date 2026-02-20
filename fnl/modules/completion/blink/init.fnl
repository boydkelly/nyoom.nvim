(import-macros {: lz-package! : build-pack-table : build-before-all-hook}
               :macros)

(lz-package! :L3MON4D3/LuaSnip
             {:nyoom-module completion.luasnip
              :requires [:rafamadriz/friendly-snippets]
              :event [:InsertEnter :CmdLineEnter]})

(lz-package! :saghen/blink.cmp
             {:nyoom-module completion.blink
              :version :v1.8.0
              :module :blink
              :event [:UIEnter :InsertEnter :CmdLineEnter]
              :requires [:onsails/lspkind.nvim
                         :saghen/blink.compat
                         ; :Olical/conjure loaded from eval.  here will overwrite lz.n keys
                         :zbirenbaum/copilot.lua
                         :giuxtaposition/blink-cmp-copilot
                         :PaterJason/cmp-conjure
                         :kirasok/cmp-hledger
                         :ribru17/blink-cmp-spell]})

