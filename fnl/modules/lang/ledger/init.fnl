(import-macros {: use-package!} :macros)

(use-package! :ledger/vim-ledger
              {:after lang.ledger
               :branch :main
               :after :nvim-treesitter
               })
