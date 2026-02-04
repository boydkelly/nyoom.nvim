(import-macros {: lz-package! : vim-pack-spec! : lz-pack!} :macros)
;; standard completion for neovim
(lz-package! :L3MON4D3/LuaSnip
       {:event [:InsertEnter :CmdLineEnter]}
       :nyoom-module completion.luasnip
       :requires [(lz-pack! :rafamadriz/friendly-snippets)])

(lz-package! :saghen/blink.cmp
              {:nyoom-module completion.blink
               :version :v1.8.0
               :module :blink
               :event [:InsertEnter :CmdLineEnter]
               :requires [(lz-pack! :onsails/lspkind.nvim)
                          (lz-pack! :zbirenbaum/copilot.lua)
                          (lz-pack! :PaterJason/cmp-conjure)
                          (lz-pack! :kirasok/cmp-hledger)
                          (lz-pack! :ribru17/blink-cmp-spell)
                          (lz-pack! :saghen/blink.compat)]})
