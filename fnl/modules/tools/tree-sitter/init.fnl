(import-macros {: lz-package! : vim-pack-spec! : lz-trigger-load!} :macros)

(lz-package! :nvim-treesitter/nvim-treesitter
             {:nyoom-module tools.tree-sitter
              :event [:BufReadPost :BufNewFile]
              :cmd :TSUpdateSync
              :requires [(lz-trigger-load! :JoosepAlviste/nvim-ts-context-commentstring
                                           {:opt true})
                         (lz-trigger-load! :nvim-treesitter/nvim-treesitter-context)
                         (lz-trigger-load! :nvim-treesitter/nvim-treesitter-textobjects
                                           {:opt true})]})

