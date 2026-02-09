(import-macros {: lz-package! : vim-pack-spec!} :macros)

 (lz-package! :nvimtools/none-ls.nvim
      {:nyoom-module checkers.diagnostics
              :event UIEnter
              :priority 1000 })
