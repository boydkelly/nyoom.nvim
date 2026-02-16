(import-macros {: lz-package! : build-pack-table : build-before-all-hook}
               :macros)

;; Simple parenthesis matching
(lz-package! :windwp/nvim-autopairs
             {:nyoom-module config.default.+smartparens :event :InsertEnter})

; lua-based matchparen alternative
(lz-package! :monkoose/matchparen.nvim
             {:opt true :event :DeferredUIEnter :call-setup matchparen})

