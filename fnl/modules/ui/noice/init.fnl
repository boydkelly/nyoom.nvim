(import-macros {: lz-package! : lz-pack! : vim-pack-spec!} :macros)

; replacement for vim.notify

(lz-package! :folke/noice.nvim {:after ui.noice
                                :event :CmdlineEnter
                                :requires [(lz-pack! :rcarriga/nvim-notify {:opt true})]})
