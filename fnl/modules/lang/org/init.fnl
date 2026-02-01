(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :nvim-orgmode/orgmode {:after lang.org
                                     :ft :org
                                     :after :nvim-treesitter})

(lz-package! :dhruvasagar/vim-table-mode {:cmd :TableModeToggle})
