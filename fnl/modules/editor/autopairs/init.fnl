(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :windwp/nvim-autopairs
             {:nyoom-module editor.autopairs
              :event [:BufReadPre :BufNewFile]
              })
