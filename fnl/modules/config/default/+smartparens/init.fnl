(import-macros {: lz-package! : vim-pack-spec!} :macros)

;; Simple parenthesis matching
(lz-package! :windwp/nvim-autopairs
             {:nyoom-module config.default.+smartparens :event :InsertEnter})

; lua-based matchparen alternative
(lz-package! :monkoose/matchparen.nvim
             {:opt true :defer matchparen.nvim :call-setup matchparen})
