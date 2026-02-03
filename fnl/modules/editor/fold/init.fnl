(import-macros {: fake-module! } :macros)

(fake-module! editor.fold)

; (lz-package! :kevinhwang91/nvim-ufo
;               {:after editor.fold
;                :after :nvim-treesitter
;                :requires [(pack :kevinhwang91/promise-async {:opt true})]})
