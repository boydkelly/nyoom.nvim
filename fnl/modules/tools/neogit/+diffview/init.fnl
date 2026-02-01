(import-macros {: lz-package! : vim-pack-spec!} :macros)

(use-package! :sindrets/diffview.nvim
              {:after tools.neogit.+diffview
               :cmd [:DiffviewFileHistory
                     :DiffviewOpen
                     :DiffviewClose
                     :DiffviewToggleFiles
                     :DiffviewFocusFiles
                     :DiffviewRefresh]})
