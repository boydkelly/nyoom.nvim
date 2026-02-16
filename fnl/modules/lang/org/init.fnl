(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :nvim-orgmode/orgmode {:nyoom-module lang.org
                                     :ft :org})

;; this wont load without an event
(lz-package! :dhruvasagar/vim-table-mode {:cmd :TableModeToggle})
