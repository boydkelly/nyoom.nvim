(import-macros {: use-package!} :macros)

(lz-package! :mvllow/modes.nvim
              {:event :InsertEnter :after ui.nyoom.+modes})
