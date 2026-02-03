(import-macros {: lz-package! : vim-pack-spec!} :macros)

;; standard completion for neovim
(lz-package! :zbirenbaum/copilot.lua
              {:nyoom-module completion.copilot :event :InsertEnter})
