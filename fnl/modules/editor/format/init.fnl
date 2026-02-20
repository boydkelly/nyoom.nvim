(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :stevearc/conform.nvim
             {:nyoom-module editor.format
              :event [:BufReadPre :BufNewFile]
              })
