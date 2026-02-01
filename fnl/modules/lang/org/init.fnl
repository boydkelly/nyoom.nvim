(import-macros {: lz-package! : vim-pack-spec!} :macros)

(use-package! :nvim-orgmode/orgmode {:after lang.org
                                     :ft :org
                                     :after :nvim-treesitter})

(use-package! :dhruvasagar/vim-table-mode {:cmd :TableModeToggle})
