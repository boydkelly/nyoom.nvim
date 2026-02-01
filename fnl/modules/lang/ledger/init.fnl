(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :ledger/vim-ledger
              {:after lang.ledger
               :branch :main
               :after :nvim-treesitter
               })
