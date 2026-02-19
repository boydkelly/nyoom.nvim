(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :mfussenegger/nvim-lint
             {:nyoom-module editor.lint
              :event [:BufReadPre :BufNewFile]
              :ft [:sh :json :yaml :python]})
