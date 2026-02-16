(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :lukas-reineke/indent-blankline.nvim {:nyoom-module ui.indent-guides
                                                   :opt true
                                                   :defer indent-blankline.nvim})
