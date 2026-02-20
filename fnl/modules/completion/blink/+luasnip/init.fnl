(import-macros {: lz-package! : build-pack-table : build-before-all-hook}
               :macros)

(lz-package! :L3MON4D3/LuaSnip
             {:nyoom-module completion.blink.+luasnip
              :requires [:rafamadriz/friendly-snippets]
              :event [:InsertEnter :CmdLineEnter]})

