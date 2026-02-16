(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

;; standard completion for neovim
(lz-package! :zbirenbaum/copilot.lua
             {:nyoom-module completion.copilot :event :InsertEnter})
