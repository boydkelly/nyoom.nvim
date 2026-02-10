(import-macros {: lz-package! : vim-pack-spec! : lz-pack!} :macros)

;; view bindings

(lz-package! "https://codeberg.org/andyg/leap.nvim"
             {:lazy false
              :nyoom-module config.default.+bindings
              :after :config.default.+bindings.keybinds
              :requires [(lz-pack! :tpope/vim-repeat)
                         (lz-pack! :ggandor/leap-ast.nvim {:opt true})]})

