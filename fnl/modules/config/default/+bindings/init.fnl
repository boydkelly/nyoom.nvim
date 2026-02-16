(import-macros {: lz-package! : build-pack-table : build-before-all-hook}
               :macros)

;; view bindings
(lz-package! "https://codeberg.org/andyg/leap.nvim"
             {:lazy false
              :nyoom-module config.default.+bindings
              :requires [:tpope/vim-repeat [:ggandor/leap-ast.nvim :packadd]]})

