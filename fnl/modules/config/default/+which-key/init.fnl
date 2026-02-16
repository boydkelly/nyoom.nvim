(import-macros {: lz-package! : build-pack-table : build-before-all-hook}
               :macros)

(lz-package! :folke/which-key.nvim
             {:nyoom-module config.default.+which-key
              :module :which-key
              :event :UIEnter})

