(import-macros {: lz-package! : build-pack-table : build-before-all-hook } :macros)
; add keys here
(lz-package! :DrKJeff16/project.nvim
             {:nyoom-module tools.project
              :cmd [:Project :ProjectRecents]
              :event :UIEnter})
