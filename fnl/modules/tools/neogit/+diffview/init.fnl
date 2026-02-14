(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :sindrets/diffview.nvim
              {:nyoom-module tools.neogit.+diffview
               :cmd [:DiffviewFileHistory
                     :DiffviewOpen
                     :DiffviewClose
                     :DiffviewToggleFiles
                     :DiffviewFocusFiles
                     :DiffviewRefresh]})
