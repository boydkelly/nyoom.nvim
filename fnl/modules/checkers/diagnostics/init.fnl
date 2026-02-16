(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

 (lz-package! :nvimtools/none-ls.nvim
      {:nyoom-module checkers.diagnostics
              :event UIEnter
              :priority 1000 })
