(import-macros {: lz-package! : vim-pack-spec!} :macros)

;; standard completion for neovim
(lz-package! :zbirenbaum/copilot.lua
              {:after completion.copilot :event :InsertEnter})
