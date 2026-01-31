(import-macros {: use-package!} :macros)

(lz-package! :mvllow/modes.nvim
              {:event :InsertEnter :nyoom-module ui.nyoom.+modes})
