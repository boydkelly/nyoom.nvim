(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :mvllow/modes.nvim
              {:event :InsertEnter :nyoom-module ui.nyoom.+modes})
