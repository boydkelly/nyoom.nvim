(import-macros {: lz-package! : vim-pack-spec!} :macros)

;; Nvim-tree: Standardized structure
(lz-package! :kyazdani42/nvim-tree.lua
             {:after ui.nvimtree
              :module :nvim-tree
              :cmd :NvimTreeToggle})
