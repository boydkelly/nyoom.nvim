(import-macros {: lz-package! : vim-pack-spec! : lz-pack!} :macros)

;; view bindings

(lz-package! :https://codeberg.org/andyg/leap.nvim
              {:after config.default.+bindings
               :requires [(lz-pack! :tpope/vim-repeat)
                          (lz-pack! :ggandor/leap-ast.nvim {:opt true})]})
