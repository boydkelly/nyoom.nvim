(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :lukas-reineke/indent-blankline.nvim
             {:nyoom-module ui.indent-guides
              :opt true
              :defer indent-blankline.nvim})
