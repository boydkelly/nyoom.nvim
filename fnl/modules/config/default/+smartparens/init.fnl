(import-macros {: lz-package! : fake-module! : vim-pack-spec!} :macros)

;; Simple parenthesis matching
(lz-package! :windwp/nvim-autopairs {:fake-module config.default.+smartparens
                                     :event :InsertEnter})

; lua-based matchparen alternative
(lz-package! :monkoose/matchparen.nvim {:opt true
                                        :defer matchparen.nvim
                                        :call-setup matchparen})
