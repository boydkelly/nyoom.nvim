(import-macros {: lz-package! : vim-pack-spec!} :macros)

;; standard completion for neovim
(use-package! :zbirenbaum/copilot.lua
              {:after completion.copilot :event :InsertEnter})
