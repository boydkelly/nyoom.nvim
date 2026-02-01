(import-macros {: use-package!} :macros)

;; standard completion for neovim
(use-package! :zbirenbaum/copilot.lua
              {:after completion.copilot :event :InsertEnter})
