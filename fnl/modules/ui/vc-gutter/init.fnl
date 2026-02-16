(import-macros {: lz-package!
                : build-pack-table
                : build-before-all-hook
                : autocmd!} :macros)

(lz-package! :lewis6991/gitsigns.nvim
             {:nyoom-module ui.vc-gutter
              :ft :gitcommit
              :event :UIEnter
              :module :gitsigns})
