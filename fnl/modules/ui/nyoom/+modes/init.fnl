(import-macros {: lz-package! : vim-pack-spec!} :macros)

(lz-package! :mvllow/modes.nvim
              {:event :InsertEnter :after ui.nyoom.+modes})
