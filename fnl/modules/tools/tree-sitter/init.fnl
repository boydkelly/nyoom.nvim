(import-macros {: lz-package! : build-pack-table : build-before-all-hook}
               :macros)

(lz-package! :nvim-treesitter/nvim-treesitter
             {:nyoom-module tools.tree-sitter
              :event [:BufReadPost :BufNewFile]
              :cmd :TSUpdateSync
              :requires [:JoosepAlviste/nvim-ts-context-commentstring
                         :nvim-treesitter/nvim-treesitter-context
                         :nvim-treesitter/nvim-treesitter-textobjects]})
