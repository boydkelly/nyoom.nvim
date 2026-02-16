(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :folke/which-key.nvim
              {:nyoom-module config.default.+which-key
               :module :which-key
               ; :keys [:<leader> "\"" "'" "`"]
               :event :UIEnter})
