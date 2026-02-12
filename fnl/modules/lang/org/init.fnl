(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :nvim-orgmode/orgmode {:nyoom-module lang.org} :module :orgmode
             :ft :org)

;; this wont load without an event
(lz-package! :dhruvasagar/vim-table-mode {:cmd :TableModeToggle})

