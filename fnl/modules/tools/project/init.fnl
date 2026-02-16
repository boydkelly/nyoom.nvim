(import-macros {: lz-package! : vim-pack-spec! } :macros)
; add keys here
(lz-package! :DrKJeff16/project.nvim
             {:nyoom-module tools.project
             ; :cmd [:Project :ProjectRecents]
              :module :project
              :event :UIEnter})
