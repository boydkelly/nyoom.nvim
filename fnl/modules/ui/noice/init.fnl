(import-macros {: lz-package! : lz-trigger-load! : vim-pack-spec!} :macros)

; replacement for vim.notify

(lz-package! :folke/noice.nvim {:after ui.noice
                                :event :CmdlineEnter
                                :requires [(lz-trigger-load! :rcarriga/nvim-notify {:opt true})]})
