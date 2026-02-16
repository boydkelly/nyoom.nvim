(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :sindrets/diffview.nvim
              {:nyoom-module tools.neogit.+diffview
               :cmd [:DiffviewFileHistory
                     :DiffviewOpen
                     :DiffviewClose
                     :DiffviewToggleFiles
                     :DiffviewFocusFiles
                     :DiffviewRefresh]})
