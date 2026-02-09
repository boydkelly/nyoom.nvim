(import-macros {: lz-package! : vim-pack-spec! : autocmd!} :macros)

(lz-package! :lewis6991/gitsigns.nvim
              {:nyoom-module ui.vc-gutter
               :event :UIEnter
               :module :gitsigns
               })
