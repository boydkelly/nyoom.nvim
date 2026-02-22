(import-macros {: lz-package!
                : build-pack-table
                : build-before-all-hook
                : packadd!} :macros)

(lz-package! :L3MON4D3/luasnip
             {:nyoom-module completion.blink.+luasnip
              :requires [:rafamadriz/friendly-snippets]
              :run [:make :install_jsregexp]
              :build-file :deps/luasnip-jsregexp.so
              :event [:InsertEnter :CmdLineEnter]})

