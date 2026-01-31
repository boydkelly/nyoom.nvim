(import-macros {: lz-package! : fake-module! : vim-pack-spec!} :macros)

(lz-package! :folke/which-key.nvim
              {:after config.default.+which-key
               :module :which-key
               :event :UIEnter})
