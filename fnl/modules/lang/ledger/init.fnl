(import-macros {: lz-package! : vim-pack-spec!} :macros)

(use-package! :ledger/vim-ledger
              {:after lang.ledger
               :branch :main
               :after :nvim-treesitter
               })
