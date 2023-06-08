(import-macros {: use-package!} :macros)

(use-package! :ledger/vim-ledger
              {:nyoom-module app.ledger
               :branch :main
               :after :nvim-treesitter
               })
