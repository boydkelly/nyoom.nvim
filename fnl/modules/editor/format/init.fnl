(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :stevearc/conform.nvim
             {:nyoom-module checkers.conform
              :event [:BufReadPre :BufNewFile]
              :priority 1000})

