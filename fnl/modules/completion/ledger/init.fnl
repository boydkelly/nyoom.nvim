(import-macros {: use-package!} :macros)

;; standard completion for neovim
(use-package! :kirasok/cmp-hledger
              {:nyoom-module ledger :event :InsertEnter})
