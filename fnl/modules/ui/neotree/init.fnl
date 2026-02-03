(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :nvim-neo-tree/neo-tree.nvim
             {:nyoom-module ui.neotree
              :module :neo-tree
              :cmd :Neotree})
