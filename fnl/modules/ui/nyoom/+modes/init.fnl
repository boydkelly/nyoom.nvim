(import-macros {: lz-package! : build-pack-table : build-before-all-hook} :macros)

(lz-package! :mvllow/modes.nvim
              {:event :InsertEnter :nyoom-module ui.nyoom.+modes})
