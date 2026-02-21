(import-macros {: lz-package! } :macros)

(lz-package! :DrKJeff16/project.nvim
             {:nyoom-module tools.project
              :cmd [:Project :ProjectRecents]
              :event :UIEnter})
