(import-macros {: lz-package! : vim-pack-spec!} :macros)

;; Neo-tree: Corrected table structure
(lz-package! :nvim-neo-tree/neo-tree.nvim
             {:nyoom-module! ui.neotree
              :module :neo-tree
              :cmd :Neotree})
