(import-macros {: lz-package! : vim-pack-spec! : lz-trigger-load!} :macros)

;; view bindings

(lz-package! "https://codeberg.org/andyg/leap.nvim"
             {:lazy false
              :nyoom-module config.default.+bindings
              :requires [(lz-trigger-load! :tpope/vim-repeat)
                         (lz-trigger-load! :ggandor/leap-ast.nvim {:opt true})]})
