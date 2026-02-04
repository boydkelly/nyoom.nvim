(import-macros {: lz-package! : vim-pack-spec! : lz-pack! : pack} :macros)

(lz-package! :nvim-treesitter/nvim-treesitter
              {:nyoom-module tools.tree-sitter
               :event :BufReadPre
               :requires [
                          (lz-pack! :JoosepAlviste/nvim-ts-context-commentstring {:opt true})
                          (lz-pack! :nvim-treesitter/nvim-treesitter-context)
                          (lz-pack! :nvim-treesitter/nvim-treesitter-textobjects
                                {:opt true})]})

