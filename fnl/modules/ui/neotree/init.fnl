(import-macros {: lz-package! : vim-pack-spec!} :macros)

(use-package! :nvim-neo-tree/neo-tree.nvim
              {:after ui.neotree :cmd :Neotree})
