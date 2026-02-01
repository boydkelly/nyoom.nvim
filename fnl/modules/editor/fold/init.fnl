(import-macros {: lz-package! : vim-pack-spec! : pack} :macros)

(use-package! :kevinhwang91/nvim-ufo
              {:after editor.fold
               :after :nvim-treesitter
               :requires [(pack :kevinhwang91/promise-async {:opt true})]})
