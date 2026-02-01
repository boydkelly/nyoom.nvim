(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :nvim-neo-tree/neo-tree.nvim
              {:after ui.neotree :cmd :Neotree})
