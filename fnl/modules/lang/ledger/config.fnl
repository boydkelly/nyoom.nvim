(import-macros {: set! : packadd!} :macros)
;; {:packadd! vim-ledger}

;; set options to your liking...
(set! foldmethod :syntax)
(set! foldenable true)
(tset vim.g :ledger_fillstring "........")
(tset vim.g :ledger_extra_options "")
(tset vim.g :ledger_maxwidth 80)
(tset vim.g :ledger_fold_blanks 1)
(tset vim.g :ledger_bin "hledger") ;; chose ledger or hledger
(tset vim.g :ledger_is_hledger true) ;; chose ledger or hledger (true or false)
