(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :folke/which-key.nvim
              {:nyoom-module config.default.+which-key
               :module :which-key
               :after config.default.+which-key.custom
               :event :UIEnter})
