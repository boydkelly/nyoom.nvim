(import-macros {: lz-package! : vim-pack-spec! : lz-trigger-load!} :macros)

(lz-package! :L3MON4D3/LuaSnip
       {:event [:UIEnter :InsertEnter :CmdLineEnter]}
       :nyoom-module completion.luasnip
       :requires [(lz-trigger-load! :rafamadriz/friendly-snippets)])

(lz-package! :saghen/blink.cmp
              {:nyoom-module completion.blink
               :version :v1.8.0
               :module :blink
               :lazy false
               :event [:InsertEnter :CmdLineEnter]
               :requires [(lz-trigger-load! :onsails/lspkind.nvim)
                          (lz-trigger-load! :zbirenbaum/copilot.lua)
                          (lz-trigger-load! :giuxtaposition/blink-cmp-copilot)
                          ; (lz-trigger-load! :PaterJason/cmp-conjure)
                          (lz-trigger-load! :kirasok/cmp-hledger)
                          (lz-trigger-load! :ribru17/blink-cmp-spell)
                          (lz-trigger-load! :saghen/blink.compat)]})



