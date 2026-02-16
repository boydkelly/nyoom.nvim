(import-macros {: lz-package! : build-pack-table : build-before-all-hook}
               :macros)

; replacement for vim.notify

(lz-package! :folke/noice.nvim
             {:nyoom-module :ui.noice
              :event :CmdlineEnter
              :requires [:rcarriga/nvim-notify]})

