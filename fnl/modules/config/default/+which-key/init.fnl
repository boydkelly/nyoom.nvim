(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :folke/which-key.nvim
              {:after config.default.+which-key
               :module :which-key
               :event :UIEnter})
