(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :kyazdani42/nvim-tree.lua {:after ui.nvimtree
                                         :cmd :NvimTreeToggle})
